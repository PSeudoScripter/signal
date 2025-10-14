# Link device and generate QR code
function Link-SignalDevice {
    <#
    .SYNOPSIS
        Links another device to the current account.

    .DESCRIPTION
        Calls '/v1/qrcodelink' to generate a QR code that can be scanned by the
        Signal client on the device you want to link.

    .PARAMETER DeviceName
        Name of the new device shown in the linked devices list.
    #>
	param (
		[Parameter(Mandatory = $true)]
		[string]$DeviceName
	)
	
        $encodedName = [uri]::EscapeDataString($DeviceName)
        $endpoint = "/v1/qrcodelink?device_name=$encodedName"
        Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint
}