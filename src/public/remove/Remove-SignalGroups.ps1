<#
	.SYNOPSIS
		Deletes a Signal group from the account.
	
	.DESCRIPTION
		Sends a DELETE request to '/v1/groups/<number>/<groupId>' to
		remove the specified group.
	
	.PARAMETER GroupId
		Identifier of the group to delete.
	
	.PARAMETER Quit
		Remove and Quit the specified Signal Group.
	
	.EXAMPLE
		PS C:\> Remove-SignalGroups -GroupId $id
	
	.NOTES
		Additional information about the function.
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