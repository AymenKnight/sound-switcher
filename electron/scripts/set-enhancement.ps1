param(
    [Parameter(Mandatory=$true)]
    [string]$DeviceId,
    
    [Parameter(Mandatory=$true)]
    [string]$Enhancement,
    
    [Parameter(Mandatory=$true)]
    [bool]$Value
)

# Set audio enhancement for a specific device
# This requires registry modification

try {
    # Clean up the device ID for registry path
    $cleanDeviceId = $DeviceId -replace '[{}]', ''
    
    # Registry path for audio device properties
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\{$cleanDeviceId}\FxProperties"
    
    if (-not (Test-Path $regPath)) {
        Write-Error "Device registry path not found"
        exit 1
    }
    
    # Map enhancement names to registry property GUIDs
    # Note: These are example GUIDs and may need to be adjusted based on actual Windows implementation
    $enhancementMap = @{
        'bassBoost' = '{fc52a749-4be9-4510-896e-966ba6525980},3'
        'virtualSurround' = '{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},5'
        'roomCorrection' = '{c18e2f7e-933d-4965-b7d1-1eef228d2af3},3'
        'loudnessEqualization' = '{fc52a749-4be9-4510-896e-966ba6525980},5'
    }
    
    if ($enhancementMap.ContainsKey($Enhancement)) {
        $propertyName = $enhancementMap[$Enhancement]
        
        # Set the registry value (1 for enabled, 0 for disabled)
        $regValue = if ($Value) { 1 } else { 0 }
        
        Set-ItemProperty -Path $regPath -Name $propertyName -Value $regValue -Type DWord
        
        Write-Output '{"success": true}'
    }
    else {
        Write-Error "Unknown enhancement: $Enhancement"
        exit 1
    }
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}

