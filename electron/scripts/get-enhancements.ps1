param(
    [Parameter(Mandatory=$true)]
    [string]$DeviceId
)

# Get audio enhancements for a specific device
# Audio enhancements are stored in the registry

try {
    # Clean up the device ID for registry path
    $cleanDeviceId = $DeviceId -replace '[{}]', ''
    
    # Registry path for audio device properties
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\{$cleanDeviceId}\FxProperties"
    
    $enhancements = @{
        bassBoost = $false
        virtualSurround = $false
        roomCorrection = $false
        loudnessEqualization = $false
        available = $false
    }
    
    if (Test-Path $regPath) {
        $enhancements.available = $true
        
        # Try to read enhancement settings
        # These are example registry values - actual values may vary
        try {
            $fxProperties = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
            
            # Check for various enhancement properties
            if ($fxProperties.PSObject.Properties.Name -contains '{fc52a749-4be9-4510-896e-966ba6525980},3') {
                $enhancements.bassBoost = $true
            }
            if ($fxProperties.PSObject.Properties.Name -contains '{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},5') {
                $enhancements.virtualSurround = $true
            }
            if ($fxProperties.PSObject.Properties.Name -contains '{c18e2f7e-933d-4965-b7d1-1eef228d2af3},3') {
                $enhancements.roomCorrection = $true
            }
            if ($fxProperties.PSObject.Properties.Name -contains '{fc52a749-4be9-4510-896e-966ba6525980},5') {
                $enhancements.loudnessEqualization = $true
            }
        }
        catch {
            # If we can't read specific properties, just mark as available
        }
    }
    
    $enhancements | ConvertTo-Json -Compress
}
catch {
    Write-Output '{"available": false, "error": "' + $_.Exception.Message + '"}'
}

