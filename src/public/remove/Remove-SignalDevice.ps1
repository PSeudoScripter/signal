# Remove linked device
<#
	.SYNOPSIS
	    Unlinks a device from the Signal account.

	.DESCRIPTION
	    Sends a DELETE request to '/v1/devices/<number>/<deviceId>'
	    which removes the specified device from the account.

	.PARAMETER DeviceId
	    Identifier of the device to remove.

	.EXAMPLE
	    PS C:\> Remove-SignalDevice -DeviceId '123456789'
#>
function Remove-SignalDevice {
	    [CmdletBinding(ConfirmImpact = 'None',
	                            PositionalBinding = $false,
	                            SupportsPaging = $false,
	                            SupportsShouldProcess = $false)]
	    param (
	            [Parameter(Mandatory = $true)]
	            [string]$DeviceId
	    )

	    $Endpoint = '/v1/devices/{0}/{1}' -f [uri]::EscapeDataString($SignalConfig.RegistredNumber), [uri]::EscapeDataString($DeviceId)
	    Invoke-SignalApiRequest -Method 'DELETE' -Endpoint $Endpoint
}
