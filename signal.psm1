# Signal.psm1

# Documentation for signal cli REST API
# https://bbernhard.github.io/signal-cli-rest-api/
#
# Docker image from bbernhard
# bbernhard/signal-cli-rest-api:latest
#
# Git repository from bbernhard
# https://github.com/bbernhard/signal-cli-rest-api

Write-verbose "Loading signal module..."

# Dot-Source-Funktionen
$Public = @(Get-ChildItem -Recurse -Path $PSScriptRoot\src\public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\src\private\*.ps1 -ErrorAction SilentlyContinue)

# Load global variabels
if (Test-Path $PSScriptRoot\src\private\global.ps1) {
	. $PSScriptRoot\src\private\global.ps1
}


$ErrorActionPreference = 'Stop'
# Dot-Source öffentliche Funktionen
ForEach ($import In $Public) {
	Try {
		. $import.fullname
	} Catch {
		Write-Error -Message "Failed to import function $($import.fullname): $_"
	}
}

# Dot-Source private Funktionen
ForEach ($import In $Private) {
	Try {
		. $import.fullname
	} Catch {
		Write-Error -Message "Failed to import function $($import.fullname): $_"
	}
}

Export-ModuleMember -Function $Public.Basename 
Export-ModuleMember -Function $Public.Basename -Alias *
$SignalConfig = Get-SignalLocalConfiguration -Quiet
write-verbose "Signal module loaded."