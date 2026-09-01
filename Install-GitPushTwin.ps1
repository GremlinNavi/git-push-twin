[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]] $RepositoryUrl,

    [string] $Branch,

    [switch] $SkipHook
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Arguments,
        [switch] $AllowFailure
    )

    $output = & git @Arguments 2>&1
    $exitCode = $LASTEXITCODE

    if (-not $AllowFailure -and $exitCode -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $exitCode.`n$($output -join [Environment]::NewLine)"
    }

    [pscustomobject]@{
        ExitCode = $exitCode
        Output   = @($output)
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git was not found on PATH.'
}

$inside = Invoke-Git -Arguments @('rev-parse', '--is-inside-work-tree') -AllowFailure
if ($inside.ExitCode -ne 0 -or ($inside.Output -join '').Trim() -ne 'true') {
    throw 'Run Install-GitPushTwin.ps1 from inside the Git repository you want to configure.'
}

$repoRoot = (Invoke-Git -Arguments @('rev-parse', '--show-toplevel')).Output[-1].ToString().Trim()
if ([string]::IsNullOrWhiteSpace($Branch)) {
    $branchResult = Invoke-Git -Arguments @('symbolic-ref', '--quiet', '--short', 'HEAD') -AllowFailure
    if ($branchResult.ExitCode -ne 0) {
        throw 'Detached HEAD detected. Supply -Branch explicitly after checking out the branch you intend to mirror.'
    }
    $Branch = $branchResult.Output[-1].ToString().Trim()
}

if ($RepositoryUrl.Count -lt 1) {
    throw 'At least one repository URL is required.'
}

$normalized = @()
foreach ($url in $RepositoryUrl) {
    if ([string]::IsNullOrWhiteSpace($url)) {
        throw 'Repository URLs cannot be blank.'
    }

    $trimmed = $url.Trim()

    if ($trimmed -match '(?i)(https?|ssh)://[^/\s]+:[^@\s]+@') {
        throw "Refusing a repository URL that appears to contain inline credentials: $trimmed"
    }

    if ($normalized -notcontains $trimmed) {
        $normalized += $trimmed
    }
}

$existing = Invoke-Git -Arguments @('remote', 'get-url', 'twin') -AllowFailure
if ($existing.ExitCode -eq 0) {
    Invoke-Git -Arguments @('remote', 'remove', 'twin') | Out-Null
}

Invoke-Git -Arguments @('remote', 'add', 'twin', $normalized[0]) | Out-Null

foreach ($url in $normalized) {
    Invoke-Git -Arguments @('remote', 'set-url', '--add', '--push', 'twin', $url) | Out-Null
}

Invoke-Git -Arguments @('config', '--local', '--replace-all', 'remote.twin.push', "HEAD:refs/heads/$Branch") | Out-Null
Invoke-Git -Arguments @('config', '--local', '--replace-all', 'remote.twin.skipDefaultUpdate', 'true') | Out-Null

if (-not $SkipHook) {
    $gitDir = (Invoke-Git -Arguments @('rev-parse', '--git-dir')).Output[-1].ToString().Trim()
    if (-not [System.IO.Path]::IsPathRooted($gitDir)) {
        $gitDir = Join-Path $repoRoot $gitDir
    }

    $hooksDir = Join-Path $gitDir 'hooks'
    $supportDir = Join-Path $gitDir 'git-push-twin'
    New-Item -ItemType Directory -Force -Path $hooksDir, $supportDir | Out-Null

    $sourcePrePush = Join-Path $PSScriptRoot 'scripts/pre-push.ps1'
    if (-not (Test-Path -LiteralPath $sourcePrePush -PathType Leaf)) {
        throw "Missing bundled pre-push script: $sourcePrePush"
    }

    $targetPrePush = Join-Path $supportDir 'pre-push.ps1'
    Copy-Item -LiteralPath $sourcePrePush -Destination $targetPrePush -Force

    $hookPath = Join-Path $hooksDir 'pre-push'
    $hook = @'
#!/bin/sh
set -eu

repo_root="$(git rev-parse --show-toplevel)"
git_dir="$(git rev-parse --git-dir)"

case "$git_dir" in
  /*) ;;
  *) git_dir="$repo_root/$git_dir" ;;
esac

script="$git_dir/git-push-twin/pre-push.ps1"

if command -v pwsh >/dev/null 2>&1; then
  exec pwsh -NoLogo -NoProfile -File "$script" "$@"
elif command -v powershell.exe >/dev/null 2>&1; then
  exec powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$script" "$@"
elif command -v powershell >/dev/null 2>&1; then
  exec powershell -NoLogo -NoProfile -File "$script" "$@"
else
  echo "git-push-twin: PowerShell is required for the pre-push safety hook." >&2
  exit 1
fi
'@

    [System.IO.File]::WriteAllText($hookPath, $hook, (New-Object System.Text.UTF8Encoding($false)))

    $isWindowsPlatform = ($env:OS -eq 'Windows_NT')
    if (-not $isWindowsPlatform -and (Get-Command chmod -ErrorAction SilentlyContinue)) {
        & chmod +x $hookPath
    }
}

Write-Host ''
Write-Host "git-push-twin configured for branch '$Branch'."
Write-Host 'Push destinations:'
foreach ($url in $normalized) {
    Write-Host "  - $url"
}
Write-Host ''
Write-Host 'Use:'
Write-Host '  git push twin'
Write-Host ''
Write-Host 'For post-push remote verification, run Invoke-GitPushTwin.ps1 from this tool repository.'
