# SPDX-License-Identifier: Apache-2.0
#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host 'Running PowerShell syntax checks...'
& (Join-Path $PSScriptRoot 'Parse-PowerShell.ps1')

Write-Host 'Running OSWAPSACW semantic documentation checks...'
& (Join-Path $PSScriptRoot 'Test-OSWAPSACWPluginSemantics.ps1')

Write-Host 'All OSWAP Twin Transport local checks passed.'
