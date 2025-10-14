#region SignalConfiguration function

<#
	.SYNOPSIS
		Creates or overwrites the Signal module configuration file.
	
	.DESCRIPTION
		Stores the REST API URL and the registered sender number in an XML file that
		is loaded automatically by the module.
	
	.PARAMETER SenderNumber
		Phone number in E.164 format used as sender.
	
	.PARAMETER SignalServerURL
		URL of the signal-cli REST API instance, e.g. http://mysignaldocker.local:8080
	
	.PARAMETER Force
		overwrite existing configuration
	
	.EXAMPLE
		PS C:\> New-SignalConfiguration -SenderNumber '+491234567890' -SignalServerURL 'http://mysignaldocker.local:8080'
		Creates the configuration file for the module.
	
	.NOTES
		Additional information about the function.
#>
function New-SignalConfiguration {
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidatePattern('\+[1-9]{1}[0-9]{9,12}')]
		[string]$SenderNumber,
		[Parameter(Mandatory = $true)]
		[string]$SignalServerURL,
		[switch]$Force
	)
	
	$SignalConfig = [pscustomobject]@{
		"ServerURL"	      = $SignalServerURL;
		"RegistredNumber" = $SenderNumber
	}

	$dynamicParameters = @{"NoClobber"=$true}
	
	if ($Force.IsPresent) { $dynamicParameters = @{"force" = $true}}
	
	Export-Clixml -Path $SignalConfigFile.Fullname -InputObject $SignalConfig @dynamicParameters
	Import-Module $PSCommandPath -force -DisableNameChecking
}
