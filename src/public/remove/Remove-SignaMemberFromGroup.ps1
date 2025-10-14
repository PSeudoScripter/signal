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
		[string]$Member
	)
	$body = @{
		$permission = [array]$Members
	}
	
	$Endpoint = "/v1/groups/{0}/{1}/members" -f [uri]::EscapeDataString($SignalConfig.RegistredNumber), [uri]::EscapeDataString($GroupId)
	
	Invoke-SignalApiRequest -Method 'DELETE' -Endpoint $Endpoint -Body $body
}
