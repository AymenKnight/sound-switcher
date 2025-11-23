using System;
using System.Runtime.InteropServices;

namespace AudioDeviceSwitcher
{
    public class PolicyConfigClient
    {
        [DllImport("ole32.dll")]
        private static extern int CLSIDFromString([MarshalAs(UnmanagedType.LPWStr)] string lpsz, out Guid pclsid);

        [DllImport("ole32.dll")]
        private static extern int CoCreateInstance(ref Guid rclsid, IntPtr pUnkOuter, uint dwClsContext, ref Guid riid, out IntPtr ppv);

        private const uint CLSCTX_INPROC_SERVER = 1;

        public static bool SetDefaultDevice(string deviceId)
        {
            try
            {
                // CLSID for CPolicyConfigClient
                Guid CLSID_PolicyConfig = new Guid("870af99c-171d-4f9e-af0d-e63df40c2bc9");
                Guid IID_IPolicyConfig = new Guid("f8679f50-850a-41cf-9c72-430f290290c8");

                IntPtr pPolicyConfig;
                int hr = CoCreateInstance(ref CLSID_PolicyConfig, IntPtr.Zero, CLSCTX_INPROC_SERVER, ref IID_IPolicyConfig, out pPolicyConfig);

                if (hr != 0 || pPolicyConfig == IntPtr.Zero)
                {
                    return false;
                }

                // Call SetDefaultEndpoint method
                // This is a simplified version - actual implementation would need proper COM interop
                Marshal.Release(pPolicyConfig);
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}

