@echo off
setlocal enabledelayedexpansion

set APP_NAME=no.watn.magnus.smartcardsignapp
set SCRIPT_NAME=smartcardsignapp.py
set WRAPPER_SCRIPT=smartcardsignapp.bat

:question
echo Install for Chrome, Firefox, or both?
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

@rem Test if virtualenv in path
where virtualenv.exe >nul 2>&1
if %errorlevel% NEQ 0 (
    echo ERR: Could not find virtualenv. It must exist in your path
    exit /B 1
)

@rem Look for the PKCS11 lib in known locations
set PKCS11_LIB=None
for %%F in ("%PROGRAMFILES%\Fujitsu\ActiveSecurity MyClient\Cryptoki.dll" "%WINDIR%\System32\opensc-pkcs11.dll") do (
    dir %%F >nul 2>&1
    if !errorlevel! == 0 (
        set PKCS11_LIB=%%F
    )
)
if %PKCS11_LIB% == None (
    echo ERR: Could not find a PKCS11 library
    exit /B 1
)
echo Installing using %PKCS11_LIB%

@rem Creating a virtualenv with PyKCS11
virtualenv.exe %~dp0virtualenv
%~dp0virtualenv\Scripts\pip.exe install PyKCS11

@rem Creating a bat-file to run the script
echo @echo off > %~dp0%WRAPPER_SCRIPT%
echo %~dp0virtualenv\Scripts\Python.exe %~dp0%SCRIPT_NAME% >> %~dp0%WRAPPER_SCRIPT%

@rem Update the path to the PKCS11 library in the Python script
for /F "delims=æøå usebackq" %%A in ("%~dp0%SCRIPT_NAME%") do (
    set line=%%A
    set modified=!line:PKCS11_LIB=%PKCS11_LIB%!
    echo !modified! >> %~dp0TEMP
)
del %~dp0%SCRIPT_NAME%
rename %~dp0TEMP %SCRIPT_NAME%

@rem Update path to the script in the Chrome manifest
for /F "delims=æøå usebackq" %%A in ("%~dp0%APP_NAME%-chrome.json") do (
    set line=%%A
    set modified=!line:"HOST_PATH"="%WRAPPER_SCRIPT%"!
    echo !modified! >> %~dp0TEMP
)
del %~dp0%APP_NAME%-chrome.json
rename %~dp0TEMP %APP_NAME%-chrome.json

@rem Update path to the script in the Firefox manifest
for /F "delims=æøå usebackq" %%A in ("%~dp0%APP_NAME%-firefox.json") do (
    set line=%%A
    set modified=!line:"HOST_PATH"="%WRAPPER_SCRIPT%"!
    echo !modified! >> %~dp0TEMP
)
del %~dp0%APP_NAME%-firefox.json
rename %~dp0TEMP %APP_NAME%-firefox.json

@rem Install in HKLM if running as admin, otherwise HKCU
if %CH% == true (
    echo Installing for Chrome
    net session >nul 2>&1
    if !errorlevel! == 0 (
        REG ADD "HKLM\Software\Google\Chrome\NativeMessagingHosts\%APP_NAME%" /ve /t REG_SZ /d "%~dp0%APP_NAME%-chrome.json" /f
    ) else (
        REG ADD "HKCU\Software\Google\Chrome\NativeMessagingHosts\%APP_NAME%" /ve /t REG_SZ /d "%~dp0%APP_NAME%-chrome.json" /f
    )
)

if %FF% == true (
    echo Installing for Firefox
    net session >nul 2>&1
    if !errorlevel! == 0 (
        REG ADD "HKLM\Software\Mozilla\NativeMessagingHosts\%APP_NAME%" /ve /t REG_SZ /d "%~dp0%APP_NAME%-firefox.json" /f
    ) else (
        REG ADD "HKCU\Software\Mozilla\NativeMessagingHosts\%APP_NAME%" /ve /t REG_SZ /d "%~dp0%APP_NAME%-firefox.json" /f
    )
)

echo %APP_NAME% has been installed
pause
