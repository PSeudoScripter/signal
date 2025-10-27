<#
    .SYNOPSIS
        Links a new device to the current Signal account.

    .DESCRIPTION
        Generates a QR code for linking a new device to the current Signal account
        by sending a GET request to the '/v1/qrcodelink' endpoint. This function
        creates a linking QR code that can be scanned by the Signal mobile app
        on another device to establish a multi-device setup. The linked device
        will have access to the same Signal account and can send/receive messages.

    .PARAMETER DeviceName
        The name to assign to the new device in the linked devices list. This name
        helps identify the device in your Signal settings and is mandatory for
        the linking process.

    .EXAMPLE
        Link-SignalDevice -DeviceName "My Laptop"
        
        Generates a QR code for linking a laptop to the Signal account with the name "My Laptop".

    .EXAMPLE
        Link-SignalDevice -DeviceName "Work Computer"
        
        Creates a linking QR code for a work computer device.

    .EXAMPLE
        $qrCode = Link-SignalDevice -DeviceName "Tablet Device"
        Write-Host "Scan this QR code with your Signal app: $($qrCode.qr_code)"
        
        Generates a QR code and displays linking instructions.

    .OUTPUTS
        System.Object
        Returns a QR code and linking information that can be scanned by the Signal
        mobile app to complete the device linking process.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        The primary Signal account must be properly registered and authenticated.
        The QR code should be scanned using the Signal mobile app's "Link New Device" feature.
        Once linked, the device will synchronize messages and contacts from the primary device.
        Device names help distinguish between multiple linked devices in Signal settings.

    .LINK
        Get-SignalDevices
        Register-SignalDevice
        Unregister-SignalDevice
        Remove-SignalDevice
#>
function Link-SignalDevice {
	param (
		[Parameter(Mandatory = $true)]
		[string]$DeviceName
	)
	
        $encodedName = [uri]::EscapeDataString($DeviceName)
        $endpoint = "/v1/qrcodelink?device_name=$encodedName"
        Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint
}