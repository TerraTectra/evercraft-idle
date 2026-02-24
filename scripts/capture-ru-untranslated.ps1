param(
    [int]$Port = 8765,
    [int]$CaptureSeconds = 60,
    [switch]$NoBrowser,
    [switch]$ForceManual
)
$ErrorActionPreference = "Stop"


$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$url = "http://127.0.0.1:$Port/"
$logDir = Join-Path $repoRoot "logs\ru-untranslated"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $logDir "ru-untranslated-$timestamp.log"

New-Item -ItemType Directory -Force -Path $logDir | Out-Null

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $logFile -Value $line -Encoding UTF8
    Write-Host $line
}

function Test-Server {
    param([string]$TargetUrl)
    try {
        $response = Invoke-WebRequest -UseBasicParsing -TimeoutSec 4 $TargetUrl
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
    } catch {
        return $false
    }
}

function Start-ServerIfNeeded {
    param([string]$TargetUrl, [int]$TargetPort)
    if (Test-Server $TargetUrl) {
        Write-Log "Local server already available at $TargetUrl"
        return
    }

    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        Write-Log "Python not found. Cannot auto-start local server."
        return
    }

    $serverCmd = "cd /d `"$repoRoot`" && python -m http.server $TargetPort"
    $proc = Start-Process -FilePath cmd.exe -ArgumentList "/c", $serverCmd -WindowStyle Minimized -PassThru
    Start-Sleep -Seconds 2

    if (Test-Server $TargetUrl) {
        Write-Log "Started local static server in separate process (pid=$($proc.Id)) on port $TargetPort"
    } else {
        Write-Log "Attempted to start local server (pid=$($proc.Id)) but URL still unavailable."
    }
}

function Try-AutoCaptureWithPlaywright {
    param([string]$TargetUrl, [int]$Seconds, [string]$OutputFile)

    $npx = Get-Command npx.cmd -ErrorAction SilentlyContinue
    if (-not $npx) {
        Write-Log "npx.cmd not found. Skipping automated console capture."
        return $false
    }

    $tempScript = Join-Path $env:TEMP "ru_capture_console_$timestamp.cjs"
    $captureScript = @'
const { chromium } = require('playwright');

async function run() {
  const url = process.argv[2];
  const seconds = Number(process.argv[3] || '60');
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();
  const lines = [];

  page.on('console', msg => {
    const txt = msg.text();
    lines.push(`[console:${msg.type()}] ${txt}`);
  });

  await page.addInitScript(() => {
    localStorage.setItem('evercraft-locale', 'ru');
    localStorage.setItem('evercraft-ru-debug-untranslated', '1');
  });

  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(seconds * 1000);

  for (const line of lines) console.log(line);
  await browser.close();
}

run().catch(err => {
  console.error(String(err && err.stack ? err.stack : err));
  process.exit(1);
});
'@

    Set-Content -Path $tempScript -Value $captureScript -Encoding UTF8

    try {
        Write-Log "Attempting automated console capture via Playwright for $Seconds seconds..."
        $output = & npx.cmd -y -p playwright node $tempScript $TargetUrl $Seconds 2>&1
        $exitCode = $LASTEXITCODE

        Add-Content -Path $OutputFile -Value "----- AUTO CAPTURE START -----" -Encoding UTF8
        if ($output) {
            Add-Content -Path $OutputFile -Value ($output -join [Environment]::NewLine) -Encoding UTF8
        }
        Add-Content -Path $OutputFile -Value "----- AUTO CAPTURE END -----" -Encoding UTF8

        if ($exitCode -eq 0) {
            Write-Log "Automated console capture completed."
            return $true
        }

        Write-Log "Automated capture failed with exit code $exitCode."
        return $false
    } catch {
        Write-Log "Automated capture exception: $($_.Exception.Message)"
        return $false
    } finally {
        if (Test-Path $tempScript) {
            Remove-Item -Force $tempScript
        }
    }
}

Write-Log "RU untranslated capture started."
Write-Log "Repository root: $repoRoot"
Write-Log "Target URL: $url"
Write-Log "Log file: $logFile"

Start-ServerIfNeeded -TargetUrl $url -TargetPort $Port

if (-not $NoBrowser) {
    try {
        Start-Process $url | Out-Null
        Write-Log "Opened game URL in default browser."
    } catch {
        Write-Log "Could not auto-open browser: $($_.Exception.Message)"
    }
} else {
    Write-Log "Browser auto-open disabled by -NoBrowser."
}

Write-Log "Operator reminder: enable RU debug mode in browser console:"
Write-Log 'localStorage.setItem("evercraft-ru-debug-untranslated", "1"); localStorage.setItem("evercraft-locale", "ru"); location.reload();'

$captured = $false
if (-not $ForceManual) {
    $captured = Try-AutoCaptureWithPlaywright -TargetUrl $url -Seconds $CaptureSeconds -OutputFile $logFile
} else {
    Write-Log "Manual mode forced; skipping automated capture."
}

if (-not $captured) {
    Write-Log "Manual capture method:"
    Write-Log "1) Open DevTools Console on $url"
    Write-Log "2) Enable RU debug mode (command above)"
    Write-Log "3) Play/observe late-game screens"
    Write-Log "4) Filter for marker: untranslated debug entries"
    Write-Log "5) Copy relevant lines and append to this log file"
}

Write-Log "Capture session completed."
Write-Output "Log saved to: $logFile"
