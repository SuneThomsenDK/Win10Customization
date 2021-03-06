﻿Function Execute-TaskSequence {
	Param (
		[Parameter(Mandatory = $true)]
		[String]$TSName
	)

	Try {
		  $SoftwareCenter = New-Object -ComObject "UIResource.UIResourceMgr"
	}
	Catch {
		Exit 1
	}

	if (($SoftwareCenter)) {
		$TaskSequence = $SoftwareCenter.GetAvailableApplications() | Where {$_.PackageName -eq "$TSName"}
	
		if (($TaskSequence)) {
			$TaskSequenceProgramID = $TaskSequence.ID
			$TaskSequencePackageID = $TaskSequence.PackageID
			# Execute the task sequence
			Try {
				$SoftwareCenter.ExecuteProgram($TaskSequenceProgramID,$TaskSequencePackageID,$true)
			}
			Catch {
				Exit 1
			}
		}
	}
}

Execute-TaskSequence -TSName "Enter TS Name"

# Application Detection Method
$RegKey = "HKLM:\Software\Specify Name Here"
$RegName = "UpdateTime"
$RegValue = "1908"
$RegType = "String"

	if (!(Test-Path $RegKey)) {
		New-Item -Path $RegKey -Force | Out-Null
		New-ItemProperty -Path $RegKey -Name $RegName -PropertyType $RegType -Value $RegValue -Force | Out-Null
	}
	else {
		Set-ItemProperty -Path $RegKey -Name $RegName -Type $RegType -Value $RegValue -Force | Out-Null
	}
