# Tests\Signal.Manifest.Tests.ps1

$manifestPath = Join-Path $PSScriptRoot '..\signal.psd1'
$manifest     = Test-ModuleManifest -Path $manifestPath
$moduleRoot   = Join-Path $PSScriptRoot '..'
$publicPath   = Join-Path $moduleRoot 'src\public'

Describe 'Signal Manifest' {
    It 'hat eine gültige Modulversion' {
        $manifest.Version.ToString() | Should -Match '^\d+\.\d+\.\d+\.\d+$'
    }

    It 'setzt das richtige RootModule' {
        $manifest.RootModule | Should -Be 'signal.psm1'
    }

    It 'lässt sich importieren' {
        { Import-Module $manifestPath -Force } | Should -Not -Throw
    }
}

Describe 'Signal Modul – Dateinamen-Validierung' {

    It 'keine PS1-Datei im Public-Ordner hat Leerzeichen zwischen Name und Extension' {
        $filesWithSpaces = Get-ChildItem -Path $publicPath -Filter '*.ps1' -Recurse |
            Where-Object { $_.Name -match '\s+\.ps1$' }
        
        if ($filesWithSpaces) {
            $fileNames = $filesWithSpaces | ForEach-Object { $_.FullName }
            $message = "Die folgenden Dateien haben Leerzeichen vor der .ps1-Erweiterung:`n$($fileNames -join "`n")"
            throw $message
        }
        
        $filesWithSpaces | Should -BeNullOrEmpty
    }
}

# Modul importieren
Import-Module $manifestPath -Force

# Erwartete Funktionen: alle *.ps1 Dateien im public-Ordner
$expectedFunctions = Get-ChildItem -Path $publicPath -Filter '*.ps1' |
    ForEach-Object {
        # Funktionsname = Dateiname ohne Extension
        $_.BaseName
    }

Describe 'Signal Modul – Exportierte Public Funktionen' {

    It 'alle erwarteten Funktionen existieren als FunctionsToExport im Manifest' {
        $manifest = Test-ModuleManifest -Path $manifestPath
        $manifest.FunctionsToExport |
            Should -ContainExactly $expectedFunctions
    }

    It 'alle erwarteten Funktionen sind nach Import verfügbar' {
        foreach ($func in $expectedFunctions) {
            Get-Command -Name $func -Module $manifest.Name |
                Should -Not -BeNullOrEmpty
        }
    }
}
