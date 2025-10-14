# List linked devices
<#
	.SYNOPSIS
	    Lists devices linked to the configured account.

	.DESCRIPTION
	    Calls '/v1/devices/<number>' to return all devices that are
	    associated with the registered phone number. If a DeviceId is
	    provided only that specific device is returned.

	.PARAMETER DeviceId
	    Optional device identifier to fetch a single device.

	.EXAMPLE
	    PS C:\> Get-SignalDevices
	    Returns all linked devices.
#>
function Get-SignalDevices {
	    [CmdletBinding(ConfirmImpact = 'None',
	                            PositionalBinding = $false,
	                            SupportsPaging = $false,
	                            SupportsShouldProcess = $false)]
	    param (
	            [string]$DeviceId
	    )

	    $Endpoint = '/v1/devices/{0}' -f [uri]::EscapeDataString($SignalConfig.RegistredNumber)
	    if ($DeviceId) {
	            $Endpoint += '/' + [uri]::EscapeDataString($DeviceId)
	    }
	    Invoke-SignalApiRequest -Method 'GET' -Endpoint $Endpoint
}