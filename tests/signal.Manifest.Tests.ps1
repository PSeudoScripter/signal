# Tests\Signal.Manifest.Tests.ps1

$manifestPath = Join-Path $PSScriptRoot '..\signal.psd1'
$manifest     = Import-PowerShellDataFile -Path $manifestPath
$moduleRoot   = Join-Path $PSScriptRoot '..'
$publicPath   = Join-Path $moduleRoot 'src\public'

Describe 'Signal Manifest' {
    It 'has a valid module version' {
        $manifest.ModuleVersion | Should -Match '^\d+\.\d+\.\d+\.\d+$'
    }

    It 'sets the correct RootModule' {
        $manifest.RootModule | Should -Be 'signal.psm1'
    }

    It 'has a Description' {
        $manifest.Description | Should -Not -BeNullOrEmpty
    }

    It 'has a CompanyName' {
        $manifest.CompanyName | Should -Not -BeNullOrEmpty
    }

    It 'has a Author' {
        $manifest.Author | Should -Not -BeNullOrEmpty
    }

    It 'can be imported' {
        { Import-Module $manifestPath -Force } | Should -Not -Throw
    }
    
    It 'FunctionsToExport has more than 0 entries' {
        $manifest.FunctionsToExport.Count | Should -BeGreaterThan 0
    }

}

Describe 'Signal Modul - File name validation' {

    It 'keine PS1-Datei im Public-Ordner hat Leerzeichen zwischen Name und Extension' {
        $filesWithSpaces = Get-ChildItem -Path $publicPath -Filter '*.ps1' -Recurse |
            Where-Object { $_.Name -match '\s+\.ps1$' }
        
        if ($filesWithSpaces) {
            $fileNames = $filesWithSpaces | ForEach-Object { $_.FullName }
            $message = "The following files have spaces before the .ps1 extension:`n$($fileNames -join "`n")"
            throw $message
        }
        
        $filesWithSpaces | Should -BeNullOrEmpty
    }
}

# Modul importieren
Import-Module $manifestPath -Force

# Erwartete Funktionen: alle *.ps1 Dateien im public-Ordner
$files = Get-ChildItem -Path $publicPath -Filter '*.ps1' -File -Recurse
$expectedFunctions = foreach ($file in $files) {
    $content = Get-Content $file -Raw
    if ($content -match '^function\s+([a-zA-Z0-9\-_]+)') {
        $matches[1]
    }
    else {
        # Fallback: Dateiname als Funktionsname
        $file.BaseName
    }
} 

$manifest = Import-PowerShellDataFile -Path $manifestPath
Describe 'Signal Modul - Exported public functions' {

    It 'All expected functions exist as FunctionsToExport in the manifest.' {
        $manifest.FunctionsToExport |sort-object | Should -Be ($expectedFunctions|Sort-Object)
    }

    It 'All expected functions are available after import.' {
       (get-command -module Signal).name |sort-object | Should -Be ($expectedFunctions|Sort-Object)
    }
}
