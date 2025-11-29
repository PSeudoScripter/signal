<#
    .SYNOPSIS
        Retrieves information about the currently registered Signal account.

    .DESCRIPTION
        Retrieves detailed information about the currently registered Signal account
        by sending a GET request to the '/v1/accounts' endpoint. This function returns
        comprehensive account metadata including registration details, linked devices,
        account status, and other account-specific information. This is useful for
        verifying account registration and managing multi-device setups.

    .EXAMPLE
        Get-SignalAccount
        
        Retrieves information about the currently registered Signal account.

    .EXAMPLE
        $account = Get-SignalAccount
        Write-Host "Registered Number: $($account.number)"
        Write-Host "Device Count: $($account.devices.Count)"
        
        Retrieves account information and displays the registered phone number and device count.

    .OUTPUTS
        System.Object
        Returns account information including registered phone number, linked devices,
        registration status, and other account metadata.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        The account must be properly registered and authenticated with the Signal service.
        This function provides a comprehensive overview of the account status and associated devices.

    .LINK
        Register-SignalDevice
        Get-SignalDevices
        Get-SignalConfiguration
#>

function Get-SignalAccount {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	
	$Endpoint = "/v1/accounts"
	Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint
}