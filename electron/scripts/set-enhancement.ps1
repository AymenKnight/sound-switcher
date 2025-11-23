param(
    [Parameter(Mandatory=$true)]
    [string]$DeviceId,
    
    [Parameter(Mandatory=$true)]
    [string]$Enhancement,
    
    [Parameter(Mandatory=$true)]
    [int]$Value
)

# Set audio enhancement for a specific device
# This requires administrator privileges for registry modification

try {
    # Remove the prefix and clean the device ID
    $cleanDeviceId = $DeviceId -replace '^\{0\.0\.[01]\.00000000\}\.', '' -replace '[{}]', ''
    
    # Try to find the device in the registry
    $renderPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render"
    $capturePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture"
    
    $fxPath = $null
    
    # Search in Render devices
    Get-ChildItem $renderPath -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.PSChildName -like "*$cleanDeviceId*") {
            $fxPath = Join-Path $_.PSPath "FxProperties"
        }
    }
    
    # If not found, search in Capture devices
    if (-not $fxPath) {
        Get-ChildItem $capturePath -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.PSChildName -like "*$cleanDeviceId*") {
                $fxPath = Join-Path $_.PSPath "FxProperties"
            }
        }
    }
    
    if (-not $fxPath -or -not (Test-Path $fxPath)) {
        throw "Device FxProperties path not found"
    }
    
    # Map enhancement names to registry property GUIDs
    $enhancementMap = @{
        'bassBoost' = '{fc52a749-4be9-4510-896e-966ba6525980},3'
        'virtualSurround' = '{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},5'
        'loudnessEqualization' = '{fc52a749-4be9-4510-896e-966ba6525980},5'
        'roomCorrection' = '{c18e2f7e-933d-4965-b7d1-1eef228d2af3},3'
        'speakerFill' = '{d3993a3f-99c2-4402-b5ec-a92a0367664b},5'
        'headphoneVirtualization' = '{d3993a3f-99c2-4402-b5ec-a92a0367664b},6'
    }
    
    # Check if it's a known enhancement or a GUID-based key
    $propertyName = $null
    if ($enhancementMap.ContainsKey($Enhancement)) {
        $propertyName = $enhancementMap[$Enhancement]
    }
    # If it starts with underscore, it's a GUID key - convert it back
    elseif ($Enhancement -match '^_(.+)__(\d+)$') {
        $guid = $matches[1] -replace '_', '-'
        $index = $matches[2]
        $propertyName = "{$guid},$index"
    }
    else {
        throw "Unknown enhancement: $Enhancement"
    }
    # Value is already 0 or 1
    $regValue = $Value
    
    # Try to set the registry value
    try {
        Set-ItemProperty -Path $fxPath -Name $propertyName -Value $regValue -Type DWord -ErrorAction Stop
        @{ success = $true } | ConvertTo-Json -Compress
    }
    catch {
        # If setting fails, it might be because the property doesn't exist
        # Try to create it
        New-ItemProperty -Path $fxPath -Name $propertyName -Value $regValue -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        @{ success = $true } | ConvertTo-Json -Compress
    }
}
catch {
    @{
        success = $false
        error = $_.Exception.Message
    } | ConvertTo-Json -Compress
    exit 1
}
