<#
    .SYNOPSIS
        Removes a linked device from the Signal account.

    .DESCRIPTION
        Unlinks a device from the configured Signal account by sending a DELETE request
        to the Signal API. This permanently removes the specified device from the account,
        and the device will no longer be able to send or receive Signal messages until
        it is re-connected. This is useful for removing devices that are no longer in use
        or for security purposes when a device is lost or stolen.

    .PARAMETER DeviceId
        The unique identifier of the device to remove from the Signal account.
        This can be obtained using the Get-SignalDevices function.

    .EXAMPLE
        Remove-SignalDevice -DeviceId "123456789"
        
        Removes the device with ID "123456789" from the Signal account.

    .EXAMPLE
        Get-SignalDevices | Where-Object { $_.name -eq "Old Phone" } | ForEach-Object { Remove-SignalDevice -DeviceId $_.deviceId }
        
        Finds and removes a device named "Old Phone" from the Signal account.

    .OUTPUTS
        None
        This function does not return any output upon successful execution.

    .NOTES
        - This action cannot be undone. The device will need to be re-connected to the account
          if you want to use it again for Signal messaging.
        - Requires a valid Signal configuration to be set up using New-SignalConfiguration.
        - The device ID can be obtained using the Get-SignalDevices function.

    .LINK
        Get-SignalDevices
        New-SignalConfiguration
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
