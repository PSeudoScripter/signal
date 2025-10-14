# Get information about the REST API
<#
	.SYNOPSIS
	    Retrieves version information of the running Signal REST API.

	.DESCRIPTION
	    Calls '/v1/about' on the Signal REST API and returns details
	    about the service and the bundled signal-cli version.

	.EXAMPLE
	    PS C:\> Get-SignalAbout
	    Shows the REST API version.
#>
function Get-SignalAbout {
	    [CmdletBinding(ConfirmImpact = 'None',
	                            PositionalBinding = $false,
	                            SupportsPaging = $false,
	                            SupportsShouldProcess = $false)]
	    param ()

	    $Endpoint = '/v1/about'
	    Invoke-SignalApiRequest -Method 'GET' -Endpoint $Endpoint
}