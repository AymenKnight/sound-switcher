# Helper script to get audio devices with proper MMDevice IDs
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Playback", "Recording")]
    [string]$Type
)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

namespace AudioDevices
{
    public enum EDataFlow
    {
        eRender = 0,
        eCapture = 1,
        eAll = 2
    }

    public enum ERole
    {
        eConsole = 0,
        eMultimedia = 1,
        eCommunications = 2
    }

    public enum DEVICE_STATE
    {
        ACTIVE = 0x00000001,
        DISABLED = 0x00000002,
        NOTPRESENT = 0x00000004,
        UNPLUGGED = 0x00000008
    }

    [Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMDeviceEnumerator
    {
        int EnumAudioEndpoints(EDataFlow dataFlow, uint dwStateMask, out IMMDeviceCollection ppDevices);
        int GetDefaultAudioEndpoint(EDataFlow dataFlow, ERole role, out IMMDevice ppEndpoint);
        int GetDevice(string pwstrId, out IMMDevice ppDevice);
    }

    [Guid("0BD7A1BE-7A1A-44DB-8397-CC5392387B5E"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMDeviceCollection
    {
        int GetCount(out uint pcDevices);
        int Item(uint nDevice, out IMMDevice ppDevice);
    }

    [Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMDevice
    {
        int Activate(ref Guid iid, uint dwClsCtx, IntPtr pActivationParams, out IntPtr ppInterface);
        int OpenPropertyStore(uint stgmAccess, out IPropertyStore ppProperties);
        int GetId([MarshalAs(UnmanagedType.LPWStr)] out string ppstrId);
        int GetState(out uint pdwState);
    }

    [Guid("886d8eeb-8cf2-4446-8d02-cdba1dbdcf99"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IPropertyStore
    {
        int GetCount(out uint cProps);
        int GetAt(uint iProp, out PropertyKey pkey);
        int GetValue(ref PropertyKey key, out PropVariant pv);
        int SetValue(ref PropertyKey key, ref PropVariant propvar);
        int Commit();
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct PropertyKey
    {
        public Guid fmtid;
        public uint pid;
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct PropVariant
    {
        [FieldOffset(0)] public ushort vt;
        [FieldOffset(8)] public IntPtr pwszVal;
    }

    [ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
    public class MMDeviceEnumeratorComObject
    {
    }

    public class DeviceEnumerator
    {
        public static string GetDevices(EDataFlow dataFlow)
        {
            try
            {
                var enumerator = (IMMDeviceEnumerator)new MMDeviceEnumeratorComObject();
                IMMDeviceCollection collection;
                enumerator.EnumAudioEndpoints(dataFlow, 1, out collection); // 1 = ACTIVE

                uint count;
                collection.GetCount(out count);

                IMMDevice defaultDevice;
                string defaultId = "";
                try
                {
                    enumerator.GetDefaultAudioEndpoint(dataFlow, ERole.eConsole, out defaultDevice);
                    defaultDevice.GetId(out defaultId);
                }
                catch { }

                string result = "[";
                for (uint i = 0; i < count; i++)
                {
                    IMMDevice device;
                    collection.Item(i, out device);

                    string id;
                    device.GetId(out id);

                    IPropertyStore props;
                    device.OpenPropertyStore(0, out props);

                    // Create PropertyKey for friendly name
                    PropertyKey pkey = new PropertyKey
                    {
                        fmtid = new Guid(0xa45c254e, 0xdf1c, 0x4efd, 0x80, 0x20, 0x67, 0xd1, 0x46, 0xa8, 0x50, 0xe0),
                        pid = 14
                    };

                    PropVariant nameVar;
                    props.GetValue(ref pkey, out nameVar);
                    string name = Marshal.PtrToStringUni(nameVar.pwszVal);

                    bool isDefault = (id == defaultId);

                    if (i > 0) result += ",";
                    result += "{";
                    result += "\"id\":\"" + id.Replace("\\", "\\\\") + "\",";
                    result += "\"name\":\"" + name.Replace("\"", "\\\"") + "\",";
                    result += "\"isDefault\":" + (isDefault ? "true" : "false") + ",";
                    result += "\"state\":1,";
                    result += "\"type\":\"" + (dataFlow == EDataFlow.eRender ? "playback" : "recording") + "\"";
                    result += "}";
                }
                result += "]";

                return result;
            }
            catch (Exception ex)
            {
                return "{\"error\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}";
            }
        }
    }
}
"@

try {
    $dataFlow = if ($Type -eq "Playback") { [AudioDevices.EDataFlow]::eRender } else { [AudioDevices.EDataFlow]::eCapture }
    $result = [AudioDevices.DeviceEnumerator]::GetDevices($dataFlow)
    Write-Output $result
} catch {
    @{error = $_.Exception.Message} | ConvertTo-Json -Compress
}

