<#
.SYNOPSIS
	Set Wallpaper and LockScreen in Windows 10 Enterprise.

.DESCRIPTION
	The purpose of this script is to set Wallpaper and LockScreen in Windows 10 with a SCCM package 
	deployed as a program or during OS Deployment.

	This script takes ownership and set permissions on the default folders in "SystemDrive\Windows\Web\*"
	it will replace the default images and set LockScreen settings in Registry.

.NOTES
	Version: 1.9.4.15
	Author: Sune Thomsen
	Creation date: 27-03-2019
	Last modified date: 15-04-2019

.LINK
	https://github.com/SuneThomsenDK
#>

	#=========================================================================================
	#	Requirements
	#=========================================================================================
	#Requires -Version 4
	#Requires -RunAsAdministrator

	#=========================================================================================
	#	Source and Destination Path
	#=========================================================================================
	$Source4K = "$PSScriptRoot\4K".ToLower()
	$SourceScreen = "$PSScriptRoot\Screen".ToLower()
	$SourceWallpaper = "$PSScriptRoot\Wallpaper".ToLower()
	$Destination4K = "$Env:SystemRoot\Web\4K\Wallpaper\Windows".ToLower()
	$DestinationScreen = "$Env:SystemRoot\Web\Screen".ToLower()
	$DestinationWallpaper = "$Env:SystemRoot\Web\Wallpaper\Windows".ToLower()

	#=========================================================================================
	#	Taking Ownership of the Files
	#=========================================================================================
	Write-Host "`n"
	Write-Host "=========================================================================================" -ForegroundColor "DarkGray"
	Write-Host "Taking ownership of the files"
	Write-Host "=========================================================================================" -ForegroundColor "DarkGray"
	TAKEOWN /f $Destination4K\*.*
	TAKEOWN /f $DestinationScreen\*.*
	TAKEOWN /f $DestinationWallpaper\*.*
	Write-Host "`n"
	Write-Host "`tAs every cat owner knows, nobody owns a cat ~ Ellen Perry Berkeley" -ForegroundColor "DarkGray"
	Write-Host "`n"

	#=========================================================================================
	#	Set Permissions for SYSTEM Account
	#=========================================================================================
	Write-Host "=========================================================================================" -ForegroundColor "DarkGray"
	Write-Host "Set permissions for SYSTEM account"
	Write-Host "=========================================================================================" -ForegroundColor "DarkGray"
	ICACLS $Destination4K\*.* /Grant 'System:(F)'
	ICACLS $DestinationScreen\*.* /Grant 'System:(F)'
	ICACLS $DestinationWallpaper\*.* /Grant 'System:(F)'
	Write-Host "`n"

	#=========================================================================================
	#	Delete Destination Files
	#=========================================================================================
	Remove-Item $Destination4K\*.*
	Remove-Item $DestinationScreen\*.*
	Remove-Item $DestinationWallpaper\*.*

	#=========================================================================================
	#	Mirror Files from Source to Destination
	#=========================================================================================
	Write-Host "=========================================================================================" -ForegroundColor "DarkGray"
	Write-Host "Mirror files from source to destination"
	Write-Host "=========================================================================================" -ForegroundColor "DarkGray"
	Robocopy $Source4K $Destination4K /MIR /R:120 /W:60 /NP /NS /NC /NDL /NJH
	Robocopy $SourceScreen $DestinationScreen /MIR /R:120 /W:60 /NP /NS /NC /NDL /NJH
	Robocopy $SourceWallpaper $DestinationWallpaper /MIR /R:120 /W:60 /NP /NS /NC /NDL /NJH

	#=========================================================================================
	#	Set Registry Settings
	#=========================================================================================
	Write-Host "=========================================================================================" -ForegroundColor "DarkGray"
	Write-Host "Set registry settings"
	Write-Host "=========================================================================================" -ForegroundColor "DarkGray"
	$Reg01 = "HKLM:\Software\Policies\Microsoft\Windows\Personalization"
	$Reg02 = "HKCU:\Control Panel\Desktop"
	$Name01 = "LockScreenImage"
	$Name02 = "NoChangingLockScreen"
	$Name03 = "TranscodedImageCache"
	$Name04 = "TranscodedImageCount"
	$Name05 = "Wallpaper"
	$Value01 = "$DestinationScreen\img100.jpg"
	$Value02 = "1"
	$Value03 = "$DestinationWallpaper\img0.jpg"
	$Type01 = "String"
	$Type02 = "DWORD"

		Try {
			if (!(Test-Path $Reg01)) {
				New-Item -Path $Reg01 -Force | Out-Null
				New-ItemProperty -Path $Reg01 -Name $Name01 -PropertyType $Type01 -Value $Value01 -Force | Out-Null
				New-ItemProperty -Path $Reg01 -Name $Name02 -PropertyType $Type02 -Value $Value02 -Force | Out-Null
				Write-Host "Attention: $Reg01 did not exist but were created." -ForegroundColor "Cyan"
				Write-Host "Information: $Name01 were created in registry with the following value $Value01" -ForegroundColor "Green"
				Write-Host "Information: $Name02 were created in registry with the following value $Value02" -ForegroundColor "Green"
			}
			else {
				New-ItemProperty -Path $Reg01 -Name $Name01 -PropertyType $Type01 -Value $Value01 -Force | Out-Null
				New-ItemProperty -Path $Reg01 -Name $Name02 -PropertyType $Type02 -Value $Value02 -Force | Out-Null
				Write-Host "Information: Registry value $Value01 were set on $Reg01\$Name01" -ForegroundColor "Green"
				Write-Host "Information: Registry value $Value02 were set on $Reg01\$Name02" -ForegroundColor "Green"
			}
			if ((Test-Path $Reg02)) {
				Remove-ItemProperty -Path $Reg02 -Name $Name03 -Force -ErrorAction SilentlyContinue | Out-Null
				Remove-ItemProperty -Path $Reg02 -Name $Name04 -Force -ErrorAction SilentlyContinue | Out-Null
				New-ItemProperty -Path $Reg02 -Name $Name05 -PropertyType $Type01 -Value $Value03 -Force | Out-Null
				Write-Host "Information: $Reg02\$Name03 were deleted in registry" -ForegroundColor "Green"
				Write-Host "Information: $Reg02\$Name04 were deleted in registry" -ForegroundColor "Green"
				Write-Host "Information: Registry value $Value03 were set on $Reg02\$Name05" -ForegroundColor "Green"
			}
			else {
				Write-Host "Attention: $Reg02 did not exist in registry." -ForegroundColor "Cyan"
			}
		}
		Catch {
			Write-Host "Warning: Something went wrong while setting registry settings." -ForegroundColor "Yellow"
			Return $Null
		}