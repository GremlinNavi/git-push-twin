<#
.SYNOPSIS
Enables the literal `git pull twin` command in PowerShell.

.DESCRIPTION
Native Git owns the built-in `pull` subcommand and cannot be overridden by a normal Git alias.
This script installs a PowerShell function named `git` for the current session. The function intercepts only:

    git pull twin
    git pull twin <branch>
    git pull twin --dry-run
    git pull twin <branch> --dry-run

Those forms are dispatched to Invoke-GitPullTwin.ps1. Every other Git command is delegated unchanged to the real Git executable.

Use -Persist to write the dispatcher into the current user's PowerShell profile so it is restored in future sessions.
The persistent block is marked and replaced idempotently if this installer is run again.

.PARAMETER Persist
Persist the dispatcher in the current user's current-host PowerShell profile.

.EXAMPLE
.\Enable-GitPullTwin.ps1

git pull twin

.EXAMPLE
.\Enable-GitPullTwin.ps1 -Persist

git pull twin main
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Persist
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$pullScriptPath = Join-Path $PSScriptRoot 'Invoke-GitPullTwin.ps1'
if (-not (Test-Path -LiteralPath $pullScriptPath -PathType Leaf)) {
    throw "Required twin pull engine was not found: $pullScriptPath"
}

$gitCommand = Get-Command git -CommandType Application -ErrorAction Stop | Select-Object -First 1
$gitExecutable = $gitCommand.Source

function ConvertTo-SingleQuotedLiteral {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    return $Value.Replace("'", "''")
}

$escapedGitExecutable = ConvertTo-SingleQuotedLiteral -Value $gitExecutable
$escapedPullScriptPath = ConvertTo-SingleQuotedLiteral -Value $pullScriptPath

$bodyTemplate = @'
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$GitArguments
)

if ($GitArguments.Count -ge 2 -and $GitArguments[0] -eq 'pull' -and $GitArguments[1] -eq 'twin') {
    $branch = $null
    $whatIf = $false

    if ($GitArguments.Count -gt 2) {
        foreach ($argument in @($GitArguments[2..($GitArguments.Count - 1)])) {
            if ($argument -eq '--dry-run' -or $argument -eq '-WhatIf') {
                $whatIf = $true
                continue
            }

            if ($argument -eq '--ff-only') {
                # Twin pull is always fast-forward-only, so this explicit request is accepted.
                continue
            }

            if ($argument.StartsWith('-')) {
                throw "Unsupported git pull twin option: $argument"
            }

            if ($null -ne $branch) {
                throw 'git pull twin accepts at most one branch argument.'
            }

            $branch = $argument
        }
    }

    $parameters = @{}
    if ($null -ne $branch) {
        $parameters['Branch'] = $branch
    }
    if ($whatIf) {
        $parameters['WhatIf'] = $true
    }

    & '__PULL_SCRIPT__' @parameters
    return
}

& '__GIT_EXECUTABLE__' @GitArguments
'@

$functionBody = $bodyTemplate.Replace('__PULL_SCRIPT__', $escapedPullScriptPath).Replace('__GIT_EXECUTABLE__', $escapedGitExecutable)
$scriptBlock = [ScriptBlock]::Create($functionBody)
Set-Item -Path Function:\global:git -Value $scriptBlock -Force

Write-Host 'Enabled PowerShell twin pull dispatcher for this session.'
Write-Host 'Use: git pull twin'
Write-Host 'Use: git pull twin <branch>'
Write-Host 'Use: git pull twin --dry-run'

if ($Persist) {
    $profilePath = $PROFILE.CurrentUserCurrentHost
    $profileDirectory = Split-Path -Parent $profilePath

    if (-not (Test-Path -LiteralPath $profileDirectory)) {
        New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
    }

    $startMarker = '# >>> OSWAP git pull twin >>>'
    $endMarker = '# <<< OSWAP git pull twin <<<'

    $existing = ''
    if (Test-Path -LiteralPath $profilePath -PathType Leaf) {
        $existing = Get-Content -LiteralPath $profilePath -Raw
    }

    $pattern = '(?ms)^' + [regex]::Escape($startMarker) + '.*?^' + [regex]::Escape($endMarker) + '\r?\n?'
    $existing = [regex]::Replace($existing, $pattern, '').TrimEnd()

    $persistentFunction = "function global:git {`r`n$functionBody`r`n}"
    $block = $startMarker + "`r`n" + $persistentFunction + "`r`n" + $endMarker

    if ([string]::IsNullOrWhiteSpace($existing)) {
        $newProfileContent = $block + "`r`n"
    }
    else {
        $newProfileContent = $existing + "`r`n`r`n" + $block + "`r`n"
    }

    Set-Content -LiteralPath $profilePath -Value $newProfileContent -Encoding UTF8
    Write-Host "Persisted dispatcher to: $profilePath"
}
