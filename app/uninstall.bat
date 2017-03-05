@echo off

set APP_NAME=no.watn.magnus.smartcardsignapp

@rem Uninstall from HKLM if running as admin, otherwise HKCU
net session >nul 2>&1
if %errorlevel% == 0 (
    REG DELETE "HKLM\Software\Google\Chrome\NativeMessagingHosts\%APP_NAME%" /f
) else (
    REG DELETE "HKCU\Software\Google\Chrome\NativeMessagingHosts\%APP_NAME%" /f
)

echo %APP_NAME% has been uninstalled
pause
