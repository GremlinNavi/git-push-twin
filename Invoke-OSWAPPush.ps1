# SPDX-License-Identifier: Apache-2.0
#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Command,
    [switch]$Execute
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-ExpressionId([string]$Expression) {
    $id = ($Expression -replace '\s+', '')
    $map = @{ '+'='p'; '-'='m'; '*'='x'; '/'='d'; '^'='e'; '('='l'; ')'='r'; '.'='q' }
    foreach ($key in $map.Keys) { $id = $id.Replace($key, $map[$key]) }
    return $id
}

function Resolve-OSWAPExpression([string]$Expression) {
    $normalized = ($Expression -replace '\s+', '')
    if ([string]::IsNullOrWhiteSpace($normalized)) { throw 'Expression is empty.' }
    if ($normalized -notmatch '^[0-9+\-*/^().]+$') { throw 'Expression contains characters outside the OSWAP arithmetic grammar.' }

    $matches = [regex]::Matches($normalized, '(?:\d+(?:\.\d+)?|\.\d+)|[+\-*/^()]')
    $tokens = @($matches | ForEach-Object { $_.Value })
    if (($tokens -join '') -ne $normalized) { throw 'Expression tokenization failed.' }
    $script:tokens = $tokens
    $script:pos = 0

    function Peek {
        if ($script:pos -lt $script:tokens.Count) { return $script:tokens[$script:pos] }
        return $null
    }
    function Take {
        $token = Peek
        if ($null -ne $token) { $script:pos++ }
        return $token
    }
    function Primary {
        $token = Take
        if ($null -eq $token) { throw 'Unexpected end of expression.' }
        if ($token -eq '(') {
            $value = Expression
            if ((Take) -ne ')') { throw 'Missing closing parenthesis.' }
            return [double]$value
        }
        $number = 0.0
        if (-not [double]::TryParse($token, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$number)) {
            throw "Expected number, got '$token'."
        }
        return $number
    }
    function Power {
        $left = Primary
        if ((Peek) -eq '^') {
            [void](Take)
            $right = Unary
            return [Math]::Pow([double]$left, [double]$right)
        }
        return $left
    }
    function Unary {
        $token = Peek
        if ($token -eq '+') { [void](Take); return Unary }
        if ($token -eq '-') { [void](Take); return -(Unary) }
        return Power
    }
    function Term {
        $value = Unary
        while ((Peek) -in @('*','/')) {
            $operator = Take
            $rhs = Unary
            if ($operator -eq '*') { $value *= $rhs }
            else {
                if ([Math]::Abs([double]$rhs) -lt 1e-15) { throw 'Division by zero.' }
                $value /= $rhs
            }
        }
        return $value
    }
    function Expression {
        $value = Term
        while ((Peek) -in @('+','-')) {
            $operator = Take
            $rhs = Term
            if ($operator -eq '+') { $value += $rhs } else { $value -= $rhs }
        }
        return $value
    }

    $value = [double](Expression)
    if ($script:pos -ne $script:tokens.Count) { throw "Unexpected token '$((Peek))'." }
    if ([double]::IsNaN($value) -or [double]::IsInfinity($value)) { throw 'Expression result is not finite.' }
    if ($value -lt 1.0 -or $value -gt 1024.0) { throw 'Twin replication factor must be between 1 and 1024.' }

    $guaranteed = [int64][Math]::Floor($value)
    $fraction = $value - [double]$guaranteed
    if ([Math]::Abs($fraction) -lt 1e-12) { $fraction = 0.0 }

    return [pscustomobject]@{
        raw_expression = $Expression
        normalized_expression = $normalized
        expression_id = ConvertTo-ExpressionId $normalized
        replication_factor = [Math]::Round($value, 12)
        guaranteed_copies = $guaranteed
        extra_copy_probability = [Math]::Round($fraction, 12)
        max_possible_copies = [int64][Math]::Ceiling($value)
    }
}

function Get-CryptoRandomUInt32 {
    $bytes = New-Object byte[] 4
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    return [BitConverter]::ToUInt32($bytes, 0)
}

function Get-CryptoRandomIndex([int]$MaxExclusive) {
    if ($MaxExclusive -lt 1) { throw 'Random selection requires a positive upper bound.' }
    return [int](([uint64](Get-CryptoRandomUInt32)) % [uint64]$MaxExclusive)
}

function Get-CryptoRandomUnit {
    return ([double](Get-CryptoRandomUInt32)) / 4294967296.0
}

function Get-TwinUrls {
    $urls = @(& git remote get-url --push --all twin 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $urls) { throw "Git remote 'twin' has no configured push URLs." }
    return @($urls | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Select-Destinations([string[]]$Urls, $Resolution) {
    if ($Resolution.max_possible_copies -gt $Urls.Count) {
        throw "Replication factor $($Resolution.replication_factor) may require $($Resolution.max_possible_copies) destinations; only $($Urls.Count) are configured."
    }

    $count = [int]$Resolution.guaranteed_copies
    if ($Resolution.extra_copy_probability -gt 0 -and (Get-CryptoRandomUnit) -lt [double]$Resolution.extra_copy_probability) { $count++ }

    $pool = New-Object 'System.Collections.Generic.List[string]'
    foreach ($url in $Urls) { [void]$pool.Add($url) }
    for ($i = $pool.Count - 1; $i -gt 0; $i--) {
        $j = Get-CryptoRandomIndex ($i + 1)
        $tmp = $pool[$i]
        $pool[$i] = $pool[$j]
        $pool[$j] = $tmp
    }
    return @($pool | Select-Object -First $count)
}

$text = (($Command | Where-Object { $_ -ne $null }) -join ' ').Trim()
if ($text -in @('twin','push twin')) {
    $expression = $null
} elseif ($text -match '^(?:push\s+)?twin=(.+)$') {
    $expression = $Matches[1]
} else {
    throw 'Usage: Invoke-OSWAPPush.ps1 push twin=<OSWAP-ARITHMETIC> [-Execute]'
}

$resolution = $null
if ($expression) {
    $resolution = Resolve-OSWAPExpression $expression
    Write-Output ($resolution | ConvertTo-Json -Compress)
    if (-not $Execute) {
        Write-Host 'Expression resolved in preview mode. Add -Execute to inspect the destination pool, select destinations, and request publication.'
        return
    }
}

& git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { throw 'OSWAP twin publication must run inside a Git work tree.' }
$branch = (& git branch --show-current | Select-Object -Last 1).Trim()
if ([string]::IsNullOrWhiteSpace($branch)) { throw 'Detached HEAD is not supported.' }

$urls = Get-TwinUrls
if ($resolution -and $resolution.max_possible_copies -gt $urls.Count) {
    throw "Configured destination pool cannot satisfy factor $($resolution.replication_factor)."
}

Write-Host "Branch: $branch"
Write-Host 'Eligible twin destinations:'
$urls | ForEach-Object { Write-Host " - $_" }
if ($resolution) {
    Write-Host "Replication factor: $($resolution.replication_factor)"
    Write-Host "Guaranteed whole copies: $($resolution.guaranteed_copies)"
    Write-Host "Additional whole-copy probability: $([Math]::Round(100 * $resolution.extra_copy_probability, 6))%"
} else {
    Write-Host "Replication factor: all configured destinations ($($urls.Count))"
}

if (-not $Execute) {
    Write-Host 'Preview only. Add -Execute to request publication to all configured destinations.'
    return
}

$selected = if ($resolution) { Select-Destinations $urls $resolution } else { @($urls) }
Write-Host 'Selected destinations:'
$selected | ForEach-Object { Write-Host " - $_" }

$confirmation = Read-Host 'Type TWIN to publish the current committed state to these destinations'
if ($confirmation -cne 'TWIN') { throw 'Publication cancelled.' }

foreach ($url in $selected) {
    & git push $url "HEAD:refs/heads/$branch"
    if ($LASTEXITCODE -ne 0) { throw "Push failed for $url with exit code $LASTEXITCODE." }
    $verify = @(& git ls-remote $url "refs/heads/$branch" 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $verify) { throw "Post-push verification failed for $url" }
}

Write-Host "OSWAP twin publication completed across $($selected.Count) destination(s)."
