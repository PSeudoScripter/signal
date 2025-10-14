# List the REST API configuration.
<#
    .SYNOPSIS
        List the REST API configuration.

    .DESCRIPTION
        List the REST API configuration.

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