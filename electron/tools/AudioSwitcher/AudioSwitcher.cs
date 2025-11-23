using System;
using System.Runtime.InteropServices;

namespace AudioSwitcher
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 2)
            {
                Console.WriteLine("{\"error\":\"Usage: AudioSwitcher.exe <set-default|get-default> <deviceId>\"}");
                return;
            }

            string command = args[0].ToLower();
            
            try
            {
                if (command == "set-default")
                {
                    string deviceId = args[1];
                    bool success = SetDefaultAudioDevice(deviceId);
                    if (success)
                    {
                        Console.WriteLine("{\"success\":true}");
                    }
                    else
                    {
                        Console.WriteLine("{\"error\":\"Failed to set default device\"}");
                    }
                }
                else if (command == "get-default")
                {
                    string deviceId = GetDefaultAudioDevice();
                    Console.WriteLine("{\"deviceId\":\"" + deviceId + "\"}");
                }
                else
                {
                    Console.WriteLine("{\"error\":\"Unknown command\"}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("{\"error\":\"" + ex.Message.Replace("\"", "\\\"") + "\"}");
            }
        }

        static bool SetDefaultAudioDevice(string deviceId)
        {
            try
            {
                IPolicyConfig policyConfig = null;
                
                // Try Windows 10/11 interface first
                try
                {
                    policyConfig = new CPolicyConfig() as IPolicyConfig;
                }
                catch
                {
                    // Try Windows 7/8 interface
                    policyConfig = new CPolicyConfigVista() as IPolicyConfig;
                }

                if (policyConfig == null)
                    return false;

                // Set for all roles: Console (0), Multimedia (1), Communications (2)
                policyConfig.SetDefaultEndpoint(deviceId, ERole.eConsole);
                policyConfig.SetDefaultEndpoint(deviceId, ERole.eMultimedia);
                policyConfig.SetDefaultEndpoint(deviceId, ERole.eCommunications);

                Marshal.ReleaseComObject(policyConfig);
                return true;
            }
            catch
            {
                return false;
            }
        }

        static string GetDefaultAudioDevice()
        {
            // This would require MMDeviceEnumerator implementation
            return "";
        }
    }

    // Policy Config interfaces for Windows 10/11
    [ComImport, Guid("870af99c-171d-4f9e-af0d-e63df40c2bc9")]
    internal class CPolicyConfig
    {
    }

    // Policy Config interfaces for Windows 7/8
    [ComImport, Guid("294935CE-F637-4E7C-A41B-AB255460B862")]
    internal class CPolicyConfigVista
    {
    }

    internal enum ERole
    {
        eConsole = 0,
        eMultimedia = 1,
        eCommunications = 2
    }

    [Guid("f8679f50-850a-41cf-9c72-430f290290c8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    internal interface IPolicyConfig
    {
        [PreserveSig]
        int GetMixFormat(string pszDeviceName, IntPtr ppFormat);

        [PreserveSig]
        int GetDeviceFormat(string pszDeviceName, bool bDefault, IntPtr ppFormat);

        [PreserveSig]
        int ResetDeviceFormat(string pszDeviceName);

        [PreserveSig]
        int SetDeviceFormat(string pszDeviceName, IntPtr pEndpointFormat, IntPtr MixFormat);

        [PreserveSig]
        int GetProcessingPeriod(string pszDeviceName, bool bDefault, IntPtr pmftDefaultPeriod, IntPtr pmftMinimumPeriod);

        [PreserveSig]
        int SetProcessingPeriod(string pszDeviceName, IntPtr pmftPeriod);

        [PreserveSig]
        int GetShareMode(string pszDeviceName, IntPtr pMode);

        [PreserveSig]
        int SetShareMode(string pszDeviceName, IntPtr mode);

        [PreserveSig]
        int GetPropertyValue(string pszDeviceName, bool bFxStore, IntPtr key, IntPtr pv);

        [PreserveSig]
        int SetPropertyValue(string pszDeviceName, bool bFxStore, IntPtr key, IntPtr pv);

        [PreserveSig]
        int SetDefaultEndpoint(string pszDeviceName, ERole role);

        [PreserveSig]
        int SetEndpointVisibility(string pszDeviceName, bool bVisible);
    }
}

