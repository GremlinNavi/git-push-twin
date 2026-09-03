# SPDX-FileCopyrightText: 2026 Nemi Prowse
# SPDX-License-Identifier: Apache-2.0
<#
.SYNOPSIS
Read-only verification of an OSWAP Twin Transport `twin` Git remote configuration.

.DESCRIPTION
Checks the local remote URLs, ordered twin push URLs, current-branch tracking fields,
and repository-local simple push policy. It performs no network operation and makes no
Git configuration or working-tree change.

.EXAMPLE
.\tools\Test-TwinGitRemote.ps1 -RepositoryPath C:\work\sovereign-ai-framework
#>
[CmdletBinding()]
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

function Assert-SameRemoteUrl {
    param(
        [Parameter(Mandatory)][string]$Actual,
        [Parameter(Mandatory)][string]$Expected,
        [Parameter(Mandatory)][string]$Label
    )

    if (-not (Get-NormalizedRemoteUrl -RemoteUrl $Actual).Equals(
        (Get-NormalizedRemoteUrl -RemoteUrl $Expected),
        [StringComparison]::OrdinalIgnoreCase
    )) {
        throw "$Label does not match the expected URL. Actual: $Actual"
    }
}

try {
    $script:gitExecutable = (Get-Command -Name 'git' -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $targetRoot = [IO.Path]::GetFullPath($RepositoryPath)
    if (-not (Test-Path -LiteralPath $targetRoot -PathType Container)) {
        throw "Target checkout was not found: $targetRoot"
    }

    Push-Location -LiteralPath $targetRoot
    try {
        $insideWorkTree = (Invoke-Git rev-parse --is-inside-work-tree | Select-Object -Last 1).ToString().Trim()
        if ($insideWorkTree -ne 'true') { throw 'RepositoryPath must be an existing Git checkout.' }
        $branch = (Invoke-Git symbolic-ref --quiet --short HEAD | Select-Object -Last 1).ToString().Trim()

        $originUrl = (Invoke-Git remote get-url origin | Select-Object -Last 1).ToString().Trim()
        $gitlabUrl = (Invoke-Git remote get-url gitlab | Select-Object -Last 1).ToString().Trim()
        $twinFetchUrl = (Invoke-Git remote get-url twin | Select-Object -Last 1).ToString().Trim()
        $twinPushUrls = @(Invoke-Git remote get-url --all --push twin | ForEach-Object { $_.ToString().Trim() } | Where-Object { $_ })
        $pushDefault = (Invoke-Git config --get push.default | Select-Object -Last 1).ToString().Trim()
        $branchRemote = (Invoke-Git config --get "branch.$branch.remote" | Select-Object -Last 1).ToString().Trim()
        $branchMerge = (Invoke-Git config --get "branch.$branch.merge" | Select-Object -Last 1).ToString().Trim()

        Assert-SameRemoteUrl -Actual $originUrl -Expected $GitHubUrl -Label 'origin'
        Assert-SameRemoteUrl -Actual $gitlabUrl -Expected $GitLabUrl -Label 'gitlab'
        Assert-SameRemoteUrl -Actual $twinFetchUrl -Expected $GitHubUrl -Label 'twin fetch URL'
        if ($twinPushUrls.Count -ne 2) { throw "twin must have exactly two push URLs; found $($twinPushUrls.Count)." }
        Assert-SameRemoteUrl -Actual $twinPushUrls[0] -Expected $GitHubUrl -Label 'first twin push URL'
        Assert-SameRemoteUrl -Actual $twinPushUrls[1] -Expected $GitLabUrl -Label 'second twin push URL'
        if ($pushDefault -ne 'simple') { throw "Repository-local push.default must be 'simple'; found '$pushDefault'." }
        if ($branchRemote -ne 'twin') { throw "Current branch '$branch' must track 'twin'; found '$branchRemote'." }
        if ($branchMerge -ne "refs/heads/$branch") { throw "Current branch '$branch' has unexpected twin merge ref '$branchMerge'." }

        Write-Output 'Twin Git remote configuration is valid.'
        Write-Output "Target checkout: $targetRoot"
        Write-Output "Current branch: $branch"
        Write-Output "Twin fetch URL: $twinFetchUrl"
        Write-Output "Twin push URL 1: $($twinPushUrls[0])"
        Write-Output "Twin push URL 2: $($twinPushUrls[1])"
        Write-Output 'No network, Git configuration, or working-tree change was made.'
    } finally {
        Pop-Location
    }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}
