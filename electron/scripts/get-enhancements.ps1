param(
    [Parameter(Mandatory=$true)]
    [string]$DeviceId
)

# Get ALL audio enhancements for a specific device with their actual enabled/disabled state
# This reads the Windows audio enhancement settings from the registry

try {
    # Remove the prefix and clean the device ID
    $cleanDeviceId = $DeviceId -replace '^\{0\.0\.[01]\.00000000\}\.', '' -replace '[{}]', ''
    
    # Try to find the device in the registry
    $renderPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render"
    $capturePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture"
    
    $devicePath = $null
    $fxPath = $null
    $propsPath = $null
    
    # Search in Render devices
    Get-ChildItem $renderPath -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.PSChildName -like "*$cleanDeviceId*") {
            $devicePath = $_.PSPath
            $fxPath = Join-Path $_.PSPath "FxProperties"
            $propsPath = Join-Path $_.PSPath "Properties"
        }
    }
    
    # If not found, search in Capture devices
    if (-not $devicePath) {
        Get-ChildItem $capturePath -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.PSChildName -like "*$cleanDeviceId*") {
                $devicePath = $_.PSPath
                $fxPath = Join-Path $_.PSPath "FxProperties"
                $propsPath = Join-Path $_.PSPath "Properties"
            }
        }
    }
    
    $result = @{
        available = $false
        allDisabled = $false
        enhancements = @()
    }
    
    if (-not $devicePath) {
        $result | ConvertTo-Json -Compress
        return
    }
    
    # Check if all enhancements are disabled (global disable flag)
    if (Test-Path $propsPath) {
        try {
            $props = Get-ItemProperty -Path $propsPath -ErrorAction SilentlyContinue
            # Property {1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5 = 1 means all enhancements disabled
            if ($props.PSObject.Properties.Name -contains '{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5') {
                $disableValue = $props.'{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5'
                $result.allDisabled = ($disableValue -eq 1)
            }
        } catch {}
    }
    
    if (Test-Path $fxPath) {
        $result.available = $true
        
        try {
            # Get all FxProperties
            $fxProps = Get-ItemProperty -Path $fxPath -ErrorAction SilentlyContinue
            
            # Map of known enhancement GUIDs to friendly names
            # These are the standard Windows audio enhancement GUIDs
            $knownEnhancements = @{
                # Bass Boost
                '{fc52a749-4be9-4510-896e-966ba6525980},3' = @{ 
                    name = 'Bass Boost'
                    key = 'bassBoost'
                    description = 'Enhances low-frequency sounds'
                }
                # Loudness Equalization
                '{fc52a749-4be9-4510-896e-966ba6525980},5' = @{ 
                    name = 'Loudness Equalization'
                    key = 'loudnessEqualization'
                    description = 'Normalizes volume levels'
                }
                # Virtual Surround
                '{d04e05a6-594b-4fb6-a80d-01af5eed7d1d},5' = @{ 
                    name = 'Virtual Surround'
                    key = 'virtualSurround'
                    description = 'Creates surround sound effect'
                }
                # Room Correction
                '{c18e2f7e-933d-4965-b7d1-1eef228d2af3},3' = @{ 
                    name = 'Room Correction'
                    key = 'roomCorrection'
                    description = 'Adjusts audio for room acoustics'
                }
                # Speaker Fill
                '{d3993a3f-99c2-4402-b5ec-a92a0367664b},5' = @{ 
                    name = 'Speaker Fill'
                    key = 'speakerFill'
                    description = 'Fills all speakers with audio'
                }
                # Headphone Virtualization
                '{d3993a3f-99c2-4402-b5ec-a92a0367664b},6' = @{ 
                    name = 'Headphone Virtualization'
                    key = 'headphoneVirtualization'
                    description = 'Virtual surround for headphones'
                }
            }
            
            # Check each property in FxProperties
            foreach ($propName in $fxProps.PSObject.Properties.Name) {
                if ($propName -notlike 'PS*' -and $propName -match '\{[a-f0-9-]+\}') {
                    # Check if this is a known enhancement
                    if ($knownEnhancements.ContainsKey($propName)) {
                        $enhancement = $knownEnhancements[$propName]
                        
                        # Get the actual value to determine if it's enabled
                        # Value of 1 typically means enabled, 0 means disabled
                        # But for some properties, the presence itself means it's enabled
                        $propValue = $fxProps.$propName
                        $isEnabled = $true
                        
                        # Try to determine if it's actually enabled
                        if ($propValue -is [int]) {
                            $isEnabled = ($propValue -ne 0)
                        }
                        
                        $result.enhancements += @{
                            key = $enhancement.key
                            name = $enhancement.name
                            description = $enhancement.description
                            guid = $propName
                            enabled = $isEnabled -and (-not $result.allDisabled)
                        }
                    }
                }
            }
            
            # Sort enhancements by name for consistent display
            $result.enhancements = $result.enhancements | Sort-Object -Property name
        }
        catch {
            # If we can't read properties, still mark as available
        }
    }
    
    $result | ConvertTo-Json -Compress -Depth 10
}
catch {
    @{
        available = $false
        error = $_.Exception.Message
        enhancements = @()
    } | ConvertTo-Json -Compress
}
