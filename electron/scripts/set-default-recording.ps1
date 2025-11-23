param(
    [Parameter(Mandatory=$true)]
    [string]$DeviceId
)

try {
    # Get the path to AudioSwitcher.exe
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $audioSwitcher = Join-Path (Split-Path -Parent $scriptPath) "tools\AudioSwitcher.exe"

    if (-not (Test-Path $audioSwitcher)) {
        @{error = "AudioSwitcher.exe not found at: $audioSwitcher"} | ConvertTo-Json -Compress
        exit 1
    }

    # Call AudioSwitcher.exe to set the default device
    $result = & $audioSwitcher "set-default" $DeviceId 2>&1

    # Output the result
    Write-Output $result
}
catch {
    @{error = $_.Exception.Message} | ConvertTo-Json -Compress
    exit 1
}

