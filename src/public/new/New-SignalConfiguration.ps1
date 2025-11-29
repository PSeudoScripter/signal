#region SignalConfiguration function

<#
    .SYNOPSIS
        Creates or overwrites the Signal module configuration file.

    .DESCRIPTION
        Creates a new configuration file for the Signal PowerShell module by storing
        the Signal server URL and registered phone number in an XML configuration file.
        This configuration is automatically loaded when the module is imported and is
        required for all Signal API operations. The function validates the phone number
        format and creates the configuration in the user's profile directory.

    .PARAMETER SenderNumber
        The phone number in E.164 international format (e.g., "+1234567890") that will
        be used as the sender for Signal messages. This must be a registered Signal number
        and is validated to ensure proper E.164 formatting with country code.

    .PARAMETER SignalServerURL
        The URL of the signal-cli REST API server instance. This should be the base URL
        including protocol and port (e.g., "http://mysignaldocker.local:8080"). This server hosts the Signal REST API that
        the module will communicate with.

    .PARAMETER Force
        Switch parameter to overwrite an existing configuration file without prompting.
        Use this parameter when you need to update an existing configuration or when
        automating configuration setup.

    .EXAMPLE
        New-SignalConfiguration -SenderNumber "+1234567890" -SignalServerURL "http://mysignaldocker.local:8080"
        
        Creates a new Signal configuration for a US phone number connecting to a local Signal server.

    .EXAMPLE
        New-SignalConfiguration -SenderNumber "+491234567890" -SignalServerURL "http://mysignaldocker.local:8080"
        
        Creates a configuration for a German phone number with a custom Docker-hosted Signal server.

    .EXAMPLE
        New-SignalConfiguration -SenderNumber "+1234567890" -SignalServerURL "http://mysignaldocker.local:8080" -Force
        
        Creates or overwrites the configuration file, forcing replacement of any existing configuration.

    .OUTPUTS
        None
        This function creates a configuration file but does not return output. The configuration
        is automatically loaded into the module for immediate use.

    .NOTES
        Requires a properly formatted E.164 phone number with country code.
        The phone number must be registered with Signal and have access to the specified server.
        Configuration is stored as XML in the user's profile directory.
        The module is automatically reloaded after configuration creation.
        Use Get-SignalLocalConfiguration to verify the configuration was created successfully.

    .LINK
        Get-SignalLocalConfiguration
        Set-SignalConfiguration
        Get-SignalConfiguration
#>
function New-SignalConfiguration {
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidatePattern('\+[1-9]{1}[0-9]{9,12}')]
		[string]$SenderNumber,
		[Parameter(Mandatory = $true)]
		[string]$SignalServerURL,
		[switch]$Force
	)
	
	$SignalConfig = [pscustomobject]@{
		"ServerURL"	      = $SignalServerURL;
		"RegistredNumber" = $SenderNumber
	}

	$dynamicParameters = @{"NoClobber"=$true}
	
	if ($Force.IsPresent) { $dynamicParameters = @{"force" = $true}}
	
	Export-Clixml -Path $SignalConfigFile.Fullname -InputObject $SignalConfig @dynamicParameters
	Import-Module $PSCommandPath -force -DisableNameChecking
}
