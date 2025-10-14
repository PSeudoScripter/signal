# List available groups
<#
    .SYNOPSIS
        Lists Signal groups for the configured account.

    .DESCRIPTION
        Retrieves group metadata from '/v1/groups'. When a GroupId is provided
        only that specific group is returned.

    .PARAMETER GroupId
        Optional ID of a group to fetch. If omitted all groups are listed.
#>
function Get-SignalGroup {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[string]$GroupId
	)
	
	$Endpoint = "/v1/groups/{0}" -f $SignalConfig.RegistredNumber
	if ($GroupId) {
		$endpoint += "/$GroupId"
	}
	Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint -Verbose:$PSBoundParameters.ContainsKey("Verbose")
}