<#
    .SYNOPSIS
        Deletes a Signal group or quits from a group.

    .DESCRIPTION
        Removes a Signal group from the account by sending a DELETE request to the Signal API.
        When the -Quit switch is specified, the function will also quit from the group after
        deletion, which sends an additional POST request to leave the group gracefully.

    .PARAMETER GroupId
        The ID of the Signal group to delete. This parameter is mandatory.

    .PARAMETER Quit
        Switch parameter. When specified, the function will quit from the group after deletion.
        This performs a graceful exit from the group by sending a POST request to the quit endpoint.
        Alias: 'q'

    .EXAMPLE
        Remove-SignalGroups -GroupId "group123"
        
        Deletes the specified Signal group from the account.

    .EXAMPLE
        Remove-SignalGroups -GroupId "group123" -Quit
        
        Deletes the specified Signal group and quits from it gracefully.

    .EXAMPLE
        Remove-SignalGroups -GroupId "group123" -q
        
        Same as above, using the alias 'q' for the Quit parameter.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        The authenticated user must have appropriate permissions to delete the group.
        When using the -Quit parameter, two API calls are made: first to delete, then to quit.
#>
function Remove-SignalGroups {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$GroupId,
		[Alias('q')]
		[switch]$Quit
	)
	
	$Endpoint = "/v1/groups/{0}/{1}" -f [uri]::EscapeDataString($SignalConfig.RegistredNumber), [uri]::EscapeDataString($GroupId)
	
	Invoke-SignalApiRequest -Method 'DELETE' -Endpoint $Endpoint
	
	if ($Quit.IsPresent) {
		$EndpointQuit = "$Endpoint/quit"
		Invoke-SignalApiRequest -Method 'POST' -Endpoint $EndpointQuit
	}
}