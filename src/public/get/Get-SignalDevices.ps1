<#
    .SYNOPSIS
        Retrieves devices linked to the configured Signal account.

    .DESCRIPTION
        Retrieves information about devices associated with the configured Signal account
        by sending a GET request to the Signal API. When no DeviceId is specified, the
        function returns information about all linked devices. When a specific DeviceId
        is provided, only that device's information is returned. This is useful for
        managing multiple Signal installations across different devices.

    .PARAMETER DeviceId
        Optional ID of a specific device to retrieve. If omitted, information about
        all devices linked to the account will be returned.

    .EXAMPLE
        Get-SignalDevices
        
        Retrieves information about all devices linked to the configured Signal account.

    .EXAMPLE
        Get-SignalDevices -DeviceId "device123"
        
        Retrieves information about a specific device with the ID "device123".

    .OUTPUTS
        System.Object
        Returns device information including device ID, name, registration status, and other device properties.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        Device information includes metadata such as device name, registration date,
        and connection status. This function is useful for managing multi-device Signal setups.

    .LINK
        Link-SignalDevice
        Register-SignalDevice
        Unregister-SignalDevice
        Remove-SignalDevice
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