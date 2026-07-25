$configPath = 'D:\Scoop\persist\cliproxyapi\config.yaml'
if (-not (Test-Path -LiteralPath $configPath)) {
    throw "CLIProxyAPI configuration was not found: $configPath"
}

$tokenLine = Select-String -LiteralPath $configPath -Pattern '^\s*-\s*"?(claudex-[0-9a-f]+)"?\s*$' | Select-Object -First 1
if (-not $tokenLine) {
    throw 'The claudex client token is missing from CLIProxyAPI configuration.'
}

# default CPA proxy listens
$apiBase = 'http://127.0.0.1:8317'
$apiToken = $tokenLine.Matches[0].Groups[1].Value

function Test-ClaudexGateway {
    try {
        $catalog = Invoke-RestMethod -Uri "$apiBase/v1/models" -Headers @{ Authorization = "Bearer $apiToken" } -TimeoutSec 5
        return [bool]($catalog.data | Where-Object id -eq 'gpt-5.6-sol')
    } catch {
        return $false
    }
}

$clash = Get-NetTCPConnection -LocalPort 7890 -State Listen -ErrorAction SilentlyContinue
if (-not $clash) {
    Write-Warning 'Clash is not listening on 127.0.0.1:7890. Some upstream providers may not work without a proxy.'
}

$listener = Get-NetTCPConnection -LocalPort 8317 -State Listen -ErrorAction SilentlyContinue
if ($listener) {
    if (-not (Test-ClaudexGateway)) {
        throw 'Port 8317 is occupied by an unhealthy or differently configured gateway. Stop that process and run claudex again.'
    }
} else {
    $proxyExe = 'D:\Scoop\apps\cliproxyapi\current\cli-proxy-api.exe'
    if (-not (Test-Path -LiteralPath $proxyExe)) {
        throw "CLIProxyAPI was not found: $proxyExe"
    }

    $proxyProcess = Start-Process -FilePath $proxyExe -ArgumentList '--config', $configPath -WindowStyle Hidden -PassThru
    $gatewayReady = $false
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        if ($proxyProcess.HasExited) {
            throw "CLIProxyAPI exited during startup with code $($proxyProcess.ExitCode)."
        }
        if (Test-ClaudexGateway) {
            $gatewayReady = $true
            break
        }
        Start-Sleep -Milliseconds 250
    }
    if (-not $gatewayReady) {
        throw 'CLIProxyAPI started but did not become healthy within 7.5 seconds.'
    }
}

$env:ANTHROPIC_BASE_URL = $apiBase
$env:ANTHROPIC_AUTH_TOKEN = $apiToken
$env:CLAUDE_CONFIG_DIR = Join-Path $env:USERPROFILE '.claudex'
$env:CLAUDE_SECURESTORAGE_CONFIG_DIR = $env:CLAUDE_CONFIG_DIR
$env:ANTHROPIC_DEFAULT_FABLE_MODEL = 'locietta/claude-fable-5'
$env:ANTHROPIC_DEFAULT_FABLE_MODEL_NAME = 'Claude Fable 5 (Locietta)'
$env:ANTHROPIC_DEFAULT_FABLE_MODEL_DESCRIPTION = 'Claude Fable 5 via CPA'
$env:ANTHROPIC_DEFAULT_OPUS_MODEL = 'locietta/claude-opus-5'
$env:ANTHROPIC_DEFAULT_OPUS_MODEL_NAME = 'Claude Opus 5 (Locietta)'
$env:ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION = 'Claude Opus 5 via CPA'
$env:ANTHROPIC_DEFAULT_SONNET_MODEL = 'locietta/claude-sonnet-5'
$env:ANTHROPIC_DEFAULT_SONNET_MODEL_NAME = 'Claude Sonnet 5 (Locietta)'
$env:ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION = 'Claude Sonnet 5 via CPA'
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = 'locietta/claude-haiku-4-5-20251001'
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME = 'Claude Haiku 4.5 (Locietta)'
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION = 'Claude Haiku 4.5 via CPA'
$env:CLAUDE_CODE_SUBAGENT_MODEL = 'gpt-5.6-sol'
$env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = '1'
$env:CLAUDE_CODE_ALWAYS_ENABLE_EFFORT = '1'
$env:CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY = '3'
$env:ENABLE_TOOL_SEARCH = 'false'

$claude = Join-Path $env:USERPROFILE '.local\bin\claude-claudex.exe'
if (-not (Test-Path -LiteralPath $claude)) {
    throw "The claudex-pinned Claude Code binary was not found: $claude"
}
$claudeArgs = @()
$currentDirectory = [System.IO.Path]::GetFullPath((Get-Location).ProviderPath).TrimEnd('\', '/')
$homeDirectory = [System.IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\', '/')
if ([string]::Equals($currentDirectory, $homeDirectory, [System.StringComparison]::OrdinalIgnoreCase)) {
    $claudeArgs += @('--setting-sources', 'user')
}
$claudeArgs += $args

& $claude @claudeArgs
exit $LASTEXITCODE
