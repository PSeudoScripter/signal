<#
.SYNOPSIS
    Retrieves information about the currently registered account.

.DESCRIPTION
    Calls /v1/accounts on the REST API and returns account metadata,
    including linked devices.
#>

function Get-SignalAccount {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	
	$Endpoint = "/v1/accounts"
	Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint
}