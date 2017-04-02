@echo off

set APP_NAME=no.watn.magnus.smartcardsignapp

:question
echo Uninstall from Chrome, Firefox, or both?
echo.
echo 1 - Chrome
echo 2 - Firefox
echo 3 - Both
echo.
set /P choice=Choose 1, 2, or 3:

if not defined choice (
    goto question
)

if %choice%==1 (
    set CH=true
    set FF=false
) else if %choice%==2 (
    set CH=false
    set FF=true
) else if %choice%==3 (
    set CH=true
    set FF=true
) else (
    goto question
)

@rem Uninstall from HKLM if running as admin, otherwise HKCU
if %CH% == true (
    net session >nul 2>&1
    if !errorlevel! == 0 (
        REG DELETE "HKLM\Software\Google\Chrome\NativeMessagingHosts\%APP_NAME%" /f
    ) else (
        REG DELETE "HKCU\Software\Google\Chrome\NativeMessagingHosts\%APP_NAME%" /f
    )
)

if %FF% == true (
    net session >nul 2>&1
    if !errorlevel! == 0 (
        REG DELETE "HKLM\Software\Mozilla\NativeMessagingHosts\%APP_NAME%" /f
    ) else (
        REG DELETE "HKCU\Software\Mozilla\NativeMessagingHosts\%APP_NAME%" /f
    )
)

echo Uninstall completed. You can now delete the files.
pause
