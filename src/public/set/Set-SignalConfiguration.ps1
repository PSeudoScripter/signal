<#
    .SYNOPSIS
        Sets configuration for the Signal service. Currently, only the configuration of the logging level is possible.

    .DESCRIPTION
        Configures the logging level for the Signal docker container by sending a POST request
        to the Signal API configuration endpoint. This allows you to control the verbosity of
        log output from the Signal service, which is useful for debugging issues or reducing
        log noise in production environments.

    .PARAMETER LoggingLevel
        The logging level to set for the Signal service. Valid values are:
        - 'info': Standard informational logging (default level)
        - 'warn': Only warning and error messages
        - 'debug': Verbose debugging information (most detailed)

    .EXAMPLE
        Set-SignalConfiguration -LoggingLevel info
        
        Sets the Signal service logging level to 'info' for standard operational logging.

    .EXAMPLE
        Set-SignalConfiguration -LoggingLevel debug
        
        Enables debug logging for troubleshooting Signal service issues.

    .EXAMPLE
        Set-SignalConfiguration -LoggingLevel warn
        
        Sets logging to only show warnings and errors, reducing log verbosity.

    .OUTPUTS
        System.Object
        Returns the response from the Signal API indicating whether the configuration was successfully updated.

    .NOTES
        - Requires a valid Signal configuration and active Signal service.
        - Changes to the logging level take effect immediately.
        - Debug logging can generate significant log output and should be used carefully in production.
        - The logging configuration is persistent until changed or the service is restarted with different settings.

    .LINK
        Get-SignalConfiguration
        New-SignalConfiguration
#>
function Set-SignalConfiguration {
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateSet('info', 'warn', 'debug')]
		[string]$LoggingLevel
	)
	
	$body = @{
		"logging" = @{"level" = $LoggingLevel}
	}

	$Endpoint = "/v1/configuration"
	
	Invoke-SignalApiRequest -Method 'POST' -Endpoint $Endpoint -Body $body
}