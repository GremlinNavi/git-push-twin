Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$files = Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Filter '*.ps1' |
    Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }

$failed = $false

foreach ($file in $files) {
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $file.FullName,
        [ref]$tokens,
        [ref]$errors
    )

    if ($errors.Count -gt 0) {
        $failed = $true
        Write-Host "Syntax errors in $($file.FullName):"
        foreach ($error in $errors) {
            Write-Host "  line $($error.Extent.StartLineNumber): $($error.Message)"
        }
    }
    else {
        Write-Host "OK: $($file.FullName)"
    }
}

if ($failed) {
    exit 1
}

Write-Host "Parsed $($files.Count) PowerShell file(s) successfully."
