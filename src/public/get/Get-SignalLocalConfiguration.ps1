<#
	.SYNOPSIS
	    Returns the current Signal module configuration.

	.DESCRIPTION
	    Reads the configuration XML file and returns its contents. When no
	    configuration exists, a warning is shown unless -Quiet is used.

	.PARAMETER Quiet
	    Suppresses warnings when the configuration file is missing.
#>

function Get-SignalLocalConfiguration {
	[CmdletBinding(PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	[OutputType([object])]
	param
	(
		[switch]$Quiet
	)
	
	if (Test-Path $SignalConfigFile.Fullname) {
		return import-clixml -Path $SignalConfigFile.Fullname -ErrorAction Stop
	}
	if (!$Quiet.IsPresent) {
		Write-Warning "No configuration file found. Path: $($SignalConfigFile.Fullname)"
		Write-Warning "Run New-SignalConfiguration -SenderNumber +491223345 -SignalServerURL 'http://mysignaldocker.local:8080'"
	}
}

if (!(Test-Path $SignalConfigFile.Fullname)) {
	Write-Warning "Signal is not configured. Run Get-SignalConfiguration to find out more."
}

if (!(Test-Path $SignalConfigFile.DirectoryName)) {
	New-Item -Path $SignalConfigFile.DirectoryName -ItemType Directory -Force
}
#endregion