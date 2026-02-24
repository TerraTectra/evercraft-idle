$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$allPassed = $true

function Write-Check {
    param(
        [bool]$Condition,
        [string]$PassMessage,
        [string]$FailMessage
    )

    if ($Condition) {
        Write-Output "PASS: $PassMessage"
    } else {
        Write-Output "FAIL: $FailMessage"
        $script:allPassed = $false
    }
}

$indexPath = Join-Path $repoRoot "index.html"
$langPath = Join-Path $repoRoot "lang.js"
$ruPath = Join-Path $repoRoot "ru.js"
$speedPath = Join-Path $repoRoot "speed.js"

Write-Check (Test-Path $indexPath) "index.html exists" "index.html is missing"
Write-Check (Test-Path $langPath) "lang.js exists" "lang.js is missing"
Write-Check (Test-Path $ruPath) "ru.js exists" "ru.js is missing"
Write-Check (Test-Path $speedPath) "speed.js exists" "speed.js is missing"

$indexContent = ""
if (Test-Path $indexPath) {
    $indexContent = Get-Content -Raw $indexPath
}

$bundleScriptRegex = '<script[^>]+src=["'']\./index-[^"''>]+\.js["'']'
$langIncludeRegex = '<script[^>]+src=["'']\./lang\.js["'']'
$speedIncludeRegex = '<script[^>]+src=["'']\./speed\.js["'']'
$legacyChsRegex = '<script[^>]+src=["''](?:\./)?chs\.js["'']'
$legacyCoreRegex = '<script[^>]+src=["''](?:\./)?core\.js["'']'

Write-Check ([regex]::IsMatch($indexContent, $bundleScriptRegex, "IgnoreCase")) "hashed gameplay bundle include found in index.html" "missing hashed gameplay bundle include in index.html"
Write-Check ([regex]::IsMatch($indexContent, $langIncludeRegex, "IgnoreCase")) "lang.js include found in index.html" "lang.js include missing in index.html"
Write-Check ([regex]::IsMatch($indexContent, $speedIncludeRegex, "IgnoreCase")) "speed.js include found in index.html" "speed.js include missing in index.html"
Write-Check (-not [regex]::IsMatch($indexContent, $legacyChsRegex, "IgnoreCase")) "no legacy direct chs.js injection in index.html" "legacy chs.js injection found in index.html"
Write-Check (-not [regex]::IsMatch($indexContent, $legacyCoreRegex, "IgnoreCase")) "no legacy direct core.js injection in index.html" "legacy core.js injection found in index.html"

$langPos = $indexContent.IndexOf("./lang.js")
$speedPos = $indexContent.IndexOf("./speed.js")
$bundlePos = $indexContent.IndexOf("./index-")
$loaderOrderOk = ($langPos -ge 0) -and ($speedPos -ge 0) -and ($bundlePos -ge 0) -and ($langPos -lt $speedPos) -and ($speedPos -lt $bundlePos)
Write-Check ($loaderOrderOk) "script order lang.js -> speed.js -> index-*.js is correct" "script order must be lang.js -> speed.js -> index-*.js"

$langContent = ""
if (Test-Path $langPath) {
    $langContent = Get-Content -Raw $langPath
}

$localeKeyRegex = 'evercraft-locale'
$ruLoadRegex = 'loadScript\(["'']\./ru\.js["'']\)'
$enFallbackRegex = 'setLocale\(["'']en["'']\)'

Write-Check ([regex]::IsMatch($langContent, $localeKeyRegex, "IgnoreCase")) "lang.js contains locale storage key" "lang.js missing locale storage key"
Write-Check ([regex]::IsMatch($langContent, $ruLoadRegex, "IgnoreCase")) "lang.js loads ru.js through bootstrap path" "lang.js missing ru.js bootstrap load"
Write-Check ([regex]::IsMatch($langContent, $enFallbackRegex, "IgnoreCase")) "lang.js contains EN fallback path" "lang.js missing EN fallback path"

$speedContent = ""
if (Test-Path $speedPath) {
    $speedContent = Get-Content -Raw $speedPath
}

$speedKeyRegex = 'evercraft-speed-multiplier'
$speedApiRegex = 'window\.evercraftSpeed'

Write-Check ([regex]::IsMatch($speedContent, $speedKeyRegex, "IgnoreCase")) "speed.js contains speed storage key" "speed.js missing speed storage key"
Write-Check ([regex]::IsMatch($speedContent, $speedApiRegex, "IgnoreCase")) "speed.js exposes console control API" "speed.js missing console control API"

if ($allPassed) {
    Write-Output "PASS: RU compatibility structure OK"
    exit 0
}

Write-Output "FAIL: RU compatibility structure broken"
exit 1
