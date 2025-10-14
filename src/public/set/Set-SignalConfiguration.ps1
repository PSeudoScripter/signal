<#
	.SYNOPSIS
		Set Logging level
	
	.DESCRIPTION
		Set logging level for docker container
	
	.PARAMETER LoggingLevel
		LoggingLevel
	
	.EXAMPLE
		PS C:\> Set-SignalConfiguration -LoggingLevel info
		Renames the group.
	
	.NOTES
		Additional information about the function.
#>
function Set-SignalConfiguration {
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidateSet('info', 'warn', 'debug')]
		[string]$LoggingLevel
	)
	
	$body = @{
		"logging" = @{"level" = $LoggingLevel}
	}

	$Endpoint = "/v1/configuration"
	
	Invoke-SignalApiRequest -Method 'POST' -Endpoint $Endpoint -Body $body
}