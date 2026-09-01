# SPDX-FileCopyrightText: 2026 Nemi Prowse
# SPDX-License-Identifier: Apache-2.0
<#
.SYNOPSIS
Verifies a named PS-twin release archive against a SHA-256 manifest.

.DESCRIPTION
This helper reads a checksum manifest and compares the named archive's SHA-256 hash.
It does not extract the archive, run its contents, contact a network service, or
modify Git or any file.

.EXAMPLE
.\tools\Test-PS-twinRelease.ps1 `
  -ChecksumFile .\releases\v0.1.0-beta.1\SHA256SUMS.txt `
  -ReleaseAsset .\releases\v0.1.0-beta.1\ps-twin-0.1.0-beta.1-source.zip
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ChecksumFile,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ReleaseAsset
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ExpectedHash {
    param(
        [Parameter(Mandatory)][string]$ManifestPath,
        [Parameter(Mandatory)][string]$AssetName
    )

    foreach ($line in Get-Content -LiteralPath $ManifestPath) {
        if ($line -match '^\s*([A-Fa-f0-9]{64})\s+\*?(.+?)\s*$' -and $Matches[2] -eq $AssetName) {
            return $Matches[1].ToUpperInvariant()
        }
    }
    return $null
}

try {
    if (-not (Test-Path -LiteralPath $ChecksumFile -PathType Leaf)) {
        throw "Checksum manifest was not found: $ChecksumFile"
    }
    if (-not (Test-Path -LiteralPath $ReleaseAsset -PathType Leaf)) {
        throw "Release archive was not found: $ReleaseAsset"
    }

    $assetName = [IO.Path]::GetFileName($ReleaseAsset)
    $expectedHash = Get-ExpectedHash -ManifestPath $ChecksumFile -AssetName $assetName
    if (-not $expectedHash) {
        throw "Checksum manifest has no entry for release archive: $assetName"
    }
    $actualHash = (Get-FileHash -LiteralPath $ReleaseAsset -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualHash -ne $expectedHash) {
        throw "SHA-256 mismatch for release archive: $assetName"
    }

    Write-Output "SHA-256 verified: $assetName"
    Write-Output 'No archive, Git, network, or file change was made.'
} catch {
    Write-Error $_.Exception.Message
    exit 1
}
