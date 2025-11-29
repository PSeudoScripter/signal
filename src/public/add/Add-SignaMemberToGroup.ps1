<#
    .SYNOPSIS
        Adds members to a Signal group.

    .DESCRIPTION
        Adds one or more members to an existing Signal group. Members can be added
        as regular members or as group administrators.

    .PARAMETER GroupId
        The ID of the Signal group to add members to. This parameter is mandatory.

    .PARAMETER Members
        An array of member identifiers (phone numbers or Signal IDs) to add to the group.
        This parameter is mandatory and accepts multiple values.

    .PARAMETER isAdmin
        Switch parameter. When specified, the members will be added as group administrators
        instead of regular members.

    .EXAMPLE
        Add-SignaMemberToGroup -GroupId "group123" -Members "+1234567890"
        
        Adds a single member to the specified group as a regular member.

    .EXAMPLE
        Add-SignaMemberToGroup -GroupId "group123" -Members @("+1234567890", "+0987654321")
        
        Adds multiple members to the specified group as regular members.

    .EXAMPLE
        Add-SignaMemberToGroup -GroupId "group123" -Members "+1234567890" -isAdmin
        
        Adds a member to the specified group as a group administrator.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        The authenticated user must have administrative privileges in the target group
        to add new members or administrators.
#>
function Add-SignaMemberToGroup {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$GroupId,
		[Parameter(Mandatory = $true)]
		[string[]]$Members,
		[switch]$isAdmin
	)
	
	$permission = "members"
	if ($isAdmin.IsPresent) {
		$permission = "admins"
	}
	$body = @{$permission= [array]$Members}
	
	$Endpoint = "/v1/groups/{0}/{1}/{2}" -f [uri]::EscapeDataString($SignalConfig.RegistredNumber), [uri]::EscapeDataString($GroupId), $permission
	
	Invoke-SignalApiRequest -Method 'POST' -Endpoint $Endpoint -Body $body
}