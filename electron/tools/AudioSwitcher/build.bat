@echo off
echo Building AudioSwitcher.exe...

REM Try to find csc.exe (C# compiler)
set CSC_PATH=

REM Check common .NET Framework locations
if exist "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe" (
    set CSC_PATH=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe
) else if exist "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe" (
    set CSC_PATH=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe
)

if "%CSC_PATH%"=="" (
    echo ERROR: C# compiler (csc.exe) not found!
    echo Please install .NET Framework 4.0 or higher
    pause
    exit /b 1
)

echo Found C# compiler: %CSC_PATH%
echo.

REM Compile the C# code
"%CSC_PATH%" /target:exe /out:AudioSwitcher.exe /platform:anycpu AudioSwitcher.cs

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Build successful!
    echo AudioSwitcher.exe created
    echo ========================================
) else (
    echo.
    echo ========================================
    echo Build failed!
    echo ========================================
    pause
    exit /b 1
)

pause

