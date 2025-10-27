<#
    .SYNOPSIS
        Retrieves the current Signal REST API configuration.

    .DESCRIPTION
        Retrieves the current configuration settings from the Signal REST API server
        by sending a GET request to the '/v1/configuration' endpoint. This function
        returns server-side configuration information such as API version, supported
        features, and other operational settings. This is different from the local
        module configuration stored on the client machine.

    .EXAMPLE
        Get-SignalConfiguration
        
        Retrieves the current Signal REST API server configuration.

    .EXAMPLE
        $config = Get-SignalConfiguration
        Write-Host "API Version: $($config.version)"
        
        Retrieves the configuration and displays the API version information.

    .OUTPUTS
        System.Object
        Returns the Signal REST API server configuration object containing version
        information, supported features, and other server settings.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        This function retrieves server-side configuration, not the local module settings.
        For local module configuration, use Get-SignalLocalConfiguration instead.

    .LINK
        Get-SignalLocalConfiguration
        Set-SignalConfiguration
        New-SignalConfiguration
#>
function Get-SignalConfiguration {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	()
	
	$Endpoint = "/v1/configuration"
	Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint -Verbose:$PSBoundParameters.ContainsKey("Verbose")
}