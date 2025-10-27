<#
    .SYNOPSIS
        Joins an existing Signal group.

    .DESCRIPTION
        Joins the configured Signal account to an existing Signal group by sending a
        POST request to the Signal API. This function allows you to become a member
        of a Signal group when you have the group ID, typically obtained through an
        invitation link or from another group member. Once joined, you will be able
        to send and receive messages within the group.

    .PARAMETER GroupId
        The ID of the Signal group to join. This parameter is mandatory and must be
        a valid group identifier obtained from a group invitation or existing member.

    .EXAMPLE
        Join-SignalGroup -GroupId "group123"
        
        Joins the Signal group with ID "group123".

    .EXAMPLE
        $groupId = "abc123def456"
        Join-SignalGroup -GroupId $groupId
        
        Joins a Signal group using a group ID stored in a variable.

    .OUTPUTS
        System.Object
        Returns the result of the join operation, typically including confirmation
        of successful group membership.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        The group must exist and allow new members to join.
        You must have a valid group ID to join a group.
        After joining, you will receive group messages and be able to participate in conversations.

    .LINK
        New-SignalGroup
        Get-SignalGroup
        Remove-SignalGroups
        Add-SignaMemberToGroup
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