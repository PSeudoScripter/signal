# Join to existing group
<#
    .SYNOPSIS
        Join to existing Signal group for the configured account.

    .DESCRIPTION
        Become a member of a specifig signal group by providing the GroupId.

    .PARAMETER GroupId
        ID of a group to join.
#>
function Join-SignalGroup {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[string]$GroupId
	)
	
	$Endpoint = "/v1/groups/{0}/{1}/join" -f $SignalConfig.RegistredNumber,$GroupId

	Invoke-SignalApiRequest -Method 'POST' -Endpoint $endpoint -Verbose:$PSBoundParameters.ContainsKey("Verbose")
}