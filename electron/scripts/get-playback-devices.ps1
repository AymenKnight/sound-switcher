# Get playback audio devices using COM API
try {
    # Get the path to the helper script
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $helperScript = Join-Path (Split-Path -Parent $scriptPath) "tools\GetAudioDevices.ps1"

    if (-not (Test-Path $helperScript)) {
        @{error = "Helper script not found at: $helperScript"} | ConvertTo-Json -Compress
        exit 1
    }

    # Call the helper script
    $result = & $helperScript -Type "Playback" 2>&1

    # Output the result
    Write-Output $result
} catch {
    @{error = $_.Exception.Message} | ConvertTo-Json -Compress
}

