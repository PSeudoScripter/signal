<#
    .SYNOPSIS
        Retrieves the current Signal module configuration from the local configuration file.

    .DESCRIPTION
        Reads and returns the Signal module configuration from the local XML configuration file.
        This function provides access to the stored configuration settings including the sender
        number, Signal server URL, and other module settings. If no configuration file exists,
        the function will display a warning message with instructions on how to create a new
        configuration, unless the -Quiet parameter is used to suppress warnings.

    .PARAMETER Quiet
        Suppresses warning messages when the configuration file is missing or inaccessible.
        Use this parameter when you want to check for configuration existence without
        displaying warning messages to the user.

    .EXAMPLE
        Get-SignalLocalConfiguration
        
        Retrieves the current Signal configuration. If no configuration exists, displays
        a warning with instructions on how to create one.

    .EXAMPLE
        Get-SignalLocalConfiguration -Quiet
        
        Retrieves the current Signal configuration without displaying any warnings if
        the configuration file is missing.

    .EXAMPLE
        $config = Get-SignalLocalConfiguration -Quiet
        if ($config) {
            Write-Host "Signal is configured for: $($config.SenderNumber)"
        } else {
            Write-Host "No Signal configuration found."
        }
        
        Checks if a configuration exists and displays appropriate information without warnings.

    .OUTPUTS
        System.Object
        Returns the configuration object containing Signal module settings, or $null if
        no configuration file exists.

    .NOTES
        The configuration file is stored as an XML file in the user's profile directory.
        If no configuration exists, use New-SignalConfiguration to create a new configuration.
        This function is typically used internally by other Signal module functions to
        access configuration settings.

    .LINK
        New-SignalConfiguration
        Set-SignalConfiguration
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