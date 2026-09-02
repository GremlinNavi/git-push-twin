[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $RemoteName,

    [Parameter(Position = 1)]
    [string] $RemoteUrl
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

function Test-ExcludedPath {
    param(
        [string] $Path,
        [string[]] $Patterns
    )

    foreach ($pattern in $Patterns) {
        if ($Path -like $pattern) {
            return $true
        }
    }
    return $false
}

function Test-ProbablyBinary {
    param([string] $Path)

    try {
        $stream = [System.IO.File]::OpenRead($Path)
        try {
            $limit = [Math]::Min(8192, [int]$stream.Length)
            if ($limit -eq 0) {
                return $false
            }

            $buffer = New-Object byte[] $limit
            [void]$stream.Read($buffer, 0, $limit)
            for ($i = 0; $i -lt $limit; $i++) {
                if ($buffer[$i] -eq 0) {
                    return $true
                }
            }
        }
        finally {
            $stream.Dispose()
        }
    }
    catch {
        return $true
    }

    return $false
}

$repoRoot = (Invoke-Git -Arguments @('rev-parse', '--show-toplevel')).Output[-1].ToString().Trim()
$gitDir = (Invoke-Git -Arguments @('rev-parse', '--git-dir')).Output[-1].ToString().Trim()
if (-not [System.IO.Path]::IsPathRooted($gitDir)) {
    $gitDir = Join-Path $repoRoot $gitDir
}

$currentBranchResult = Invoke-Git -Arguments @('symbolic-ref', '--quiet', '--short', 'HEAD') -AllowFailure
if ($currentBranchResult.ExitCode -ne 0) {
    Write-Error 'PS-twin blocked this push because HEAD is detached.'
    exit 2
}
$currentBranch = $currentBranchResult.Output[-1].ToString().Trim()

$pushSpecResult = Invoke-Git -Arguments @('config', '--get', 'remote.twin.push') -AllowFailure
if ($pushSpecResult.ExitCode -eq 0) {
    $pushSpec = $pushSpecResult.Output[-1].ToString().Trim()
    if ($pushSpec -match '^HEAD:refs/heads/(.+)$') {
        $configuredBranch = $Matches[1]
        if ($configuredBranch -ne $currentBranch) {
            Write-Error "PS-twin is configured for branch '$configuredBranch', but the current branch is '$currentBranch'. Re-run the installer intentionally before changing the publication branch."
            exit 2
        }
    }
}

$status = Invoke-Git -Arguments @('status', '--porcelain=v1', '--untracked-files=no')
if ($status.Output.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace(($status.Output -join ''))) {
    Write-Error @'
PS-twin blocked this push because tracked files do not match the current commit.
Commit, stash, or discard tracked changes first so the SHA-256 manifest describes exactly the commit being published.
'@
    exit 2
}

$config = @{
    excludePaths        = @()
    extraSecretPatterns = @()
    maxScanFileBytes    = 5242880
}

$canonicalConfigPath = Join-Path $repoRoot '.ps-twin.json'
$legacyConfigPath = Join-Path $repoRoot '.git-push-twin.json'
$canonicalExists = Test-Path -LiteralPath $canonicalConfigPath -PathType Leaf
$legacyExists = Test-Path -LiteralPath $legacyConfigPath -PathType Leaf

if ($canonicalExists -and $legacyExists) {
    Write-Error 'Both .ps-twin.json and legacy .git-push-twin.json exist. Migrate settings into .ps-twin.json and remove the legacy file to avoid ambiguous policy.'
    exit 3
}

$configPath = $null
if ($canonicalExists) {
    $configPath = $canonicalConfigPath
}
elif ($legacyExists) {
    $configPath = $legacyConfigPath
    Write-Warning 'Using legacy .git-push-twin.json. Rename it to .ps-twin.json after confirming its contents.'
}

if ($null -ne $configPath) {
    try {
        $parsed = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
        $propertyNames = @($parsed.PSObject.Properties.Name)

        if ($propertyNames -contains 'excludePaths' -and $null -ne $parsed.excludePaths) {
            $config.excludePaths = @($parsed.excludePaths | ForEach-Object { $_.ToString() })
        }

        if ($propertyNames -contains 'extraSecretPatterns' -and $null -ne $parsed.extraSecretPatterns) {
            $config.extraSecretPatterns = @($parsed.extraSecretPatterns | ForEach-Object { $_.ToString() })
        }

        if ($propertyNames -contains 'maxScanFileBytes' -and $null -ne $parsed.maxScanFileBytes) {
            $config.maxScanFileBytes = [int64]$parsed.maxScanFileBytes
        }
    }
    catch {
        Write-Error "Invalid $([IO.Path]::GetFileName($configPath)): $($_.Exception.Message)"
        exit 3
    }
}

$defaultPatterns = @(
    '(?i)-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    '(?i)\bAKIA[0-9A-Z]{16}\b',
    '(?i)\bgh[pousr]_[A-Za-z0-9_]{20,}\b',
    '(?i)\b(?:api[_-]?key|access[_-]?token|auth[_-]?token|client[_-]?secret|password)\b\s*[:=]\s*["'']?[A-Za-z0-9_\-\/+=.]{12,}'
)

$patterns = @($defaultPatterns + $config.extraSecretPatterns)
$tracked = (Invoke-Git -Arguments @('-c', 'core.quotepath=false', 'ls-files')).Output |
    ForEach-Object { $_.ToString() } |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

$findings = New-Object System.Collections.Generic.List[string]

foreach ($relative in $tracked) {
    if (Test-ExcludedPath -Path $relative -Patterns $config.excludePaths) {
        continue
    }

    $full = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        continue
    }

    $item = Get-Item -LiteralPath $full
    if ($item.Length -gt $config.maxScanFileBytes) {
        continue
    }

    if (Test-ProbablyBinary -Path $full) {
        continue
    }

    $content = Get-Content -LiteralPath $full -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) {
        continue
    }

    foreach ($pattern in $patterns) {
        if ($content -match $pattern) {
            $findings.Add($relative)
            break
        }
    }
}

if ($findings.Count -gt 0) {
    Write-Error ("PS-twin scrub gate found possible sensitive material in tracked files:`n  - " + (($findings | Sort-Object -Unique) -join "`n  - "))
    Write-Error 'Review the files before publishing. Add only deliberate false-positive paths to .ps-twin.json excludePaths.'
    exit 4
}

$head = (Invoke-Git -Arguments @('rev-parse', 'HEAD')).Output[-1].ToString().Trim()
$checksumDir = Join-Path $gitDir 'ps-twin/checksums'
New-Item -ItemType Directory -Force -Path $checksumDir | Out-Null

$manifestPath = Join-Path $checksumDir "$head.sha256"
$manifestLines = New-Object System.Collections.Generic.List[string]

foreach ($relative in ($tracked | Sort-Object)) {
    $full = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        continue
    }

    $hash = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLowerInvariant()
    $manifestLines.Add("$hash  $relative")
}

[System.IO.File]::WriteAllLines(
    $manifestPath,
    $manifestLines,
    (New-Object System.Text.UTF8Encoding($false))
)

Write-Host "PS-twin: scrub gate passed."
Write-Host "PS-twin: SHA-256 manifest: $manifestPath"
Write-Host "PS-twin: commit: $head"

exit 0
