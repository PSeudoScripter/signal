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