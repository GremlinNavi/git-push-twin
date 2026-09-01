[CmdletBinding()]
param(
    [switch] $DryRun,
    [switch] $NoFollowTags
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
    throw 'Run Invoke-GitPushTwin.ps1 from inside the Git repository you want to publish.'
}

$branchResult = Invoke-Git -Arguments @('symbolic-ref', '--quiet', '--short', 'HEAD') -AllowFailure
if ($branchResult.ExitCode -ne 0) {
    throw 'Detached HEAD detected. Check out a branch before using git-push-twin.'
}

$branch = $branchResult.Output[-1].ToString().Trim()
$head = (Invoke-Git -Arguments @('rev-parse', 'HEAD')).Output[-1].ToString().Trim()

$pushSpecResult = Invoke-Git -Arguments @('config', '--get', 'remote.twin.push') -AllowFailure
if ($pushSpecResult.ExitCode -ne 0) {
    throw 'The twin remote has no pinned push refspec. Re-run Install-GitPushTwin.ps1.'
}
$pushSpec = $pushSpecResult.Output[-1].ToString().Trim()
if ($pushSpec -notmatch '^HEAD:refs/heads/(.+)$') {
    throw "Unsupported twin push refspec '$pushSpec'. Re-run Install-GitPushTwin.ps1."
}
$configuredBranch = $Matches[1]
if ($configuredBranch -ne $branch) {
    throw "git-push-twin is configured for branch '$configuredBranch', but the current branch is '$branch'. Re-run the installer intentionally before changing the mirrored branch."
}

$urlsResult = Invoke-Git -Arguments @('remote', 'get-url', '--push', '--all', 'twin') -AllowFailure
if ($urlsResult.ExitCode -ne 0) {
    throw 'No twin remote is configured. Run Install-GitPushTwin.ps1 first.'
}

$urls = @($urlsResult.Output | ForEach-Object { $_.ToString().Trim() } | Where-Object { $_ })
if ($urls.Count -lt 1) {
    throw 'The twin remote has no push URLs.'
}

$pushArgs = @('push', 'twin')
if (-not $NoFollowTags) {
    $pushArgs += '--follow-tags'
}
if ($DryRun) {
    $pushArgs += '--dry-run'
}

Write-Host "git-push-twin: pushing $head on branch '$branch' to $($urls.Count) destination(s)..."
$push = Invoke-Git -Arguments $pushArgs -AllowFailure
$push.Output | ForEach-Object { Write-Host $_ }

if ($push.ExitCode -ne 0) {
    throw "git push twin failed with exit code $($push.ExitCode). Because multi-host pushes are not atomic, run verification before retrying."
}

if ($DryRun) {
    Write-Host 'git-push-twin: dry run complete; remote verification skipped.'
    exit 0
}

$failures = New-Object System.Collections.Generic.List[string]

foreach ($url in $urls) {
    $probe = Invoke-Git -Arguments @('ls-remote', $url, "refs/heads/$branch") -AllowFailure

    if ($probe.ExitCode -ne 0) {
        $failures.Add("$url (unreachable or unauthorized)")
        continue
    }

    $line = @($probe.Output | ForEach-Object { $_.ToString().Trim() } | Where-Object { $_ }) | Select-Object -First 1
    if ([string]::IsNullOrWhiteSpace($line)) {
        $failures.Add("$url (branch refs/heads/$branch not found)")
        continue
    }

    $remoteSha = ($line -split '\s+')[0]
    if ($remoteSha -ne $head) {
        $failures.Add("$url (remote $remoteSha != local $head)")
        continue
    }

    Write-Host "verified: $url -> $head"
}

if ($failures.Count -gt 0) {
    Write-Error ("git-push-twin verification failed:`n  - " + ($failures -join "`n  - "))
    exit 5
}

Write-Host "git-push-twin: all $($urls.Count) destination(s) verified at $head."
