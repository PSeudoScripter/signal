<#
    .SYNOPSIS
        Retrieves Signal group information for the configured account.

    .DESCRIPTION
        Retrieves Signal group metadata by sending a GET request to the Signal API.
        When no GroupId is specified, the function returns information about all groups
        associated with the configured account. When a specific GroupId is provided,
        only that group's information is returned.

    .PARAMETER GroupId
        Optional ID of a specific Signal group to retrieve. If omitted, information
        about all groups associated with the account will be returned.

    .EXAMPLE
        Get-SignalGroup
        
        Retrieves information about all Signal groups associated with the configured account.

    .EXAMPLE
        Get-SignalGroup -GroupId "group123"
        
        Retrieves information about a specific Signal group with the ID "group123".

    .OUTPUTS
        System.Object
        Returns group metadata including group ID, name, members, and other group properties.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        The authenticated user must have access to view the requested group(s).
        Group information includes metadata such as group name, member list, and group settings.

    .LINK
        New-SignalGroup
        Set-SignalGroup
        Remove-SignalGroups
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