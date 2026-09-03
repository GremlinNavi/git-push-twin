# SPDX-FileCopyrightText: 2026 Nemi Prowse
# SPDX-License-Identifier: Apache-2.0
<#
.SYNOPSIS
Configures a Git remote named `twin` for paired GitHub and GitLab publication.

.DESCRIPTION
This helper configures one selected Sovereign AI Demonstrator or other approved application checkout. It keeps `origin` as the
individual GitHub remote and `gitlab` as the individual GitLab remote. It creates a
third, composite remote named `twin`: GitHub is its fetch URL and GitHub plus GitLab
are its ordered push URLs. The current branch is configured to track `twin`, and the
repository-local push.default policy becomes `simple`. The standard paired publish
command is then `git push twin`.

The helper changes only local Git configuration. It never contacts a network service,
fetches, pulls, commits, tags, merges, rebases, resets, cleans, stashes, or pushes.
It refuses unapproved existing remote URLs rather than replacing them.

.PARAMETER RepositoryPath
Path to the Git checkout that should receive the `twin` remote. The default is the
current directory. The PS-twin repository itself is never an allowed target.

.PARAMETER GitHubUrl
Expected GitHub repository URL. Pass an explicit alternate pair only when deliberately
configuring a different pair of repositories.

.PARAMETER GitLabUrl
Expected GitLab repository URL paired with GitHubUrl.

.EXAMPLE
.\tools\Configure-TwinGitRemote.ps1 -RepositoryPath C:\work\sovereign-ai-framework

.EXAMPLE
.\tools\Configure-TwinGitRemote.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [ValidateNotNullOrEmpty()]
    [string]$RepositoryPath = (Get-Location).Path,

    [ValidateNotNullOrEmpty()]
    [string]$GitHubUrl = 'https://github.com/GremlinNavi/sovereign-ai-framework.git',

    [ValidateNotNullOrEmpty()]
    [string]$GitLabUrl = 'https://gitlab.com/GremlinNavi-group/sovereign-ai-framework.git'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)

    $output = & $script:gitExecutable @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "Git command failed: git $($Arguments -join ' ') (exit code $exitCode). $($output -join [Environment]::NewLine)"
    }
    return $output
}

function Get-NormalizedRemoteUrl {
    param([Parameter(Mandatory)][string]$RemoteUrl)

    $normalized = $RemoteUrl.Trim().TrimEnd('/')
    if ($normalized.EndsWith('.git', [StringComparison]::OrdinalIgnoreCase)) {
        $normalized = $normalized.Substring(0, $normalized.Length - 4)
    }
    return $normalized
}

function Test-SameRemoteUrl {
    param(
        [Parameter(Mandatory)][string]$Left,
        [Parameter(Mandatory)][string]$Right
    )

    return (Get-NormalizedRemoteUrl -RemoteUrl $Left).Equals(
        (Get-NormalizedRemoteUrl -RemoteUrl $Right),
        [StringComparison]::OrdinalIgnoreCase
    )
}

function Get-RemoteUrlOrNull {
    param([Parameter(Mandatory)][string]$RemoteName)

    $output = & $script:gitExecutable remote get-url $RemoteName 2>$null
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        return (($output | Select-Object -Last 1).ToString().Trim())
    }
    if ($exitCode -eq 2) {
        return $null
    }
    throw "Could not inspect Git remote '$RemoteName' (exit code $exitCode)."
}

function Resolve-ApprovedRemote {
    param(
        [Parameter(Mandatory)][string]$RemoteName,
        [Parameter(Mandatory)][string]$ExpectedUrl
    )

    $existingUrl = Get-RemoteUrlOrNull -RemoteName $RemoteName
    if ($null -eq $existingUrl) {
        return [pscustomobject]@{ Name = $RemoteName; Url = $ExpectedUrl; Exists = $false }
    }
    if (-not (Test-SameRemoteUrl -Left $existingUrl -Right $ExpectedUrl)) {
        throw "Remote '$RemoteName' does not match the expected URL. It was left unchanged. Supply the deliberate URL pair explicitly or correct the remote manually."
    }
    return [pscustomobject]@{ Name = $RemoteName; Url = $existingUrl; Exists = $true }
}

try {
    $script:gitExecutable = (Get-Command -Name 'git' -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $architectureRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')).TrimEnd([char]92, [char]47)
    $targetRoot = [IO.Path]::GetFullPath($RepositoryPath).TrimEnd([char]92, [char]47)
    if (-not (Test-Path -LiteralPath $targetRoot -PathType Container)) {
        throw "Target checkout was not found: $targetRoot"
    }
    if ($targetRoot.Equals($architectureRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Refusing to configure OSWAP Twin Transport itself. Supply the approved application checkout as RepositoryPath.'
    }

    Push-Location -LiteralPath $targetRoot
    try {
        $insideWorkTree = (Invoke-Git rev-parse --is-inside-work-tree | Select-Object -Last 1).ToString().Trim()
        if ($insideWorkTree -ne 'true') {
            throw 'RepositoryPath must be an existing Git checkout.'
        }

        # symbolic-ref also returns the configured initial branch before its first commit.
        $branchOutput = & $script:gitExecutable symbolic-ref --quiet --short HEAD 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $branchOutput) {
            throw 'Detached HEAD is not supported. Switch to a named branch before configuring the twin remote.'
        }
        $branch = ($branchOutput | Select-Object -Last 1).ToString().Trim()

        $github = Resolve-ApprovedRemote -RemoteName 'origin' -ExpectedUrl $GitHubUrl
        $gitlab = Resolve-ApprovedRemote -RemoteName 'gitlab' -ExpectedUrl $GitLabUrl
        $existingTwinUrl = Get-RemoteUrlOrNull -RemoteName 'twin'
        if ($null -ne $existingTwinUrl -and -not (Test-SameRemoteUrl -Left $existingTwinUrl -Right $github.Url)) {
            throw "Existing remote 'twin' does not match the expected GitHub fetch URL. It was left unchanged."
        }

        Write-Output 'OSWAP Twin Transport Git configuration'
        Write-Output "Target checkout: $targetRoot"
        Write-Output "Current branch: $branch"
        Write-Output "GitHub remote: origin ($($github.Url))"
        Write-Output "GitLab remote: gitlab ($($gitlab.Url))"
        Write-Output 'Composite remote: twin (fetches GitHub; pushes GitHub then GitLab)'
        Write-Output 'Policy: local Git configuration only; no fetch, pull, commit, tag, merge, rebase, reset, clean, stash, or push.'

        if (-not $PSCmdlet.ShouldProcess($targetRoot, 'configure the local twin remote and current branch tracking preference')) {
            Write-Output 'Twin setup preview complete; no Git configuration was changed.'
            return
        }

        if (-not $github.Exists) { Invoke-Git remote add origin $github.Url | Out-Null }
        if (-not $gitlab.Exists) { Invoke-Git remote add gitlab $gitlab.Url | Out-Null }
        if ($null -eq $existingTwinUrl) {
            Invoke-Git remote add twin $github.Url | Out-Null
        } else {
            Invoke-Git remote set-url twin $github.Url | Out-Null
        }

        # Replace only `twin`'s previous push target list with the approved pair.
        & $script:gitExecutable config --unset-all remote.twin.pushurl 2>$null
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 5) {
            throw "Could not clear existing twin push URLs (exit code $LASTEXITCODE)."
        }
        Invoke-Git config --add remote.twin.pushurl $github.Url | Out-Null
        Invoke-Git config --add remote.twin.pushurl $gitlab.Url | Out-Null
        Invoke-Git config --replace-all remote.twin.fetch '+refs/heads/*:refs/remotes/twin/*' | Out-Null
        Invoke-Git config push.default simple | Out-Null
        Invoke-Git config "branch.$branch.remote" twin | Out-Null
        Invoke-Git config "branch.$branch.merge" "refs/heads/$branch" | Out-Null

        Write-Output 'Twin remote configured locally. No network or remote repository changed.'
        Write-Output 'Preflight paired publication with: git push twin --dry-run'
        Write-Output 'Publish only when explicitly intended with: git push twin'
    } finally {
        Pop-Location
    }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}
