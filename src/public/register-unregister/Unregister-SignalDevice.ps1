# Unregister device
<#
	.SYNOPSIS
	    Removes the registration for a phone number from the Signal service.

	.DESCRIPTION
	    Allows deleting the registration and optionally the entire account on the
	    server. Local data can also be removed.

	.PARAMETER Number
	    Phone number in international format to unregister.

	.PARAMETER DeleteAccount
	    If set, the Signal account is permanently deleted on the server.

	.PARAMETER DeleteLocalData
	    Remove local data for the device as well.
#>
function Unregister-SignalDevice {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Number,
		[Alias('DA')]
		[switch]$DeleteAccount,
		[switch]$DeleteLocalData
	)
	
	$body = @{
		'delete_account'    = $DeleteAccount.IsPresent
		'delete_local_data' = $DeleteLocalData.IsPresent
	}
	
	$endpoint = "/v1/unregister/{0}" -f $Number
	Invoke-SignalApiRequest -Method 'POST' -Endpoint $endpoint -Body $body
}