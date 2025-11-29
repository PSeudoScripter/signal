<#
    .SYNOPSIS
        Removes members from a Signal group.

    .DESCRIPTION
        Removes one or more members from an existing Signal group. The function
        sends a DELETE request to the Signal API to update the group membership
        by removing the specified members.

    .PARAMETER GroupId
        The ID of the Signal group from which members will be removed. This parameter is mandatory.

    .PARAMETER Member
        An array of member identifiers (phone numbers or Signal IDs) to remove from the group.
        This parameter is mandatory and accepts multiple values.

    .EXAMPLE
        Remove-SignaMemberFromGroup -GroupId "group123" -Member "+1234567890"
        
        Removes a single member from the specified group.

    .EXAMPLE
        Remove-SignaMemberFromGroup -GroupId "group123" -Member @("+1234567890", "+0987654321")
        
        Removes multiple members from the specified group.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        The authenticated user must have administrative privileges in the target group
        to remove members from the group.
#>
function Remove-SignaMemberFromGroup {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$GroupId,
		[Parameter(Mandatory = $true)]
		[string[]]$Member
	)
	
	$body = @{
		members = [array]$Member
	}
	
	$Endpoint = "/v1/groups/{0}/{1}/members" -f [uri]::EscapeDataString($SignalConfig.RegistredNumber), [uri]::EscapeDataString($GroupId)
	
	Invoke-SignalApiRequest -Method 'DELETE' -Endpoint $Endpoint -Body $body
}
