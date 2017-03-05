@echo off
setlocal enabledelayedexpansion

set APP_NAME=no.watn.magnus.smartcardsignapp
set SCRIPT_NAME=smartcardsignapp.py
set WRAPPER_SCRIPT=smartcardsignapp.bat

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

@rem Update path to the script in the manifest
for /F "delims=æøå usebackq" %%A in ("%~dp0%APP_NAME%.json") do (
    set line=%%A
    set modified=!line:"HOST_PATH"="%WRAPPER_SCRIPT%"!
    echo !modified! >> %~dp0TEMP
)
del %~dp0%APP_NAME%.json
rename %~dp0TEMP %APP_NAME%.json

@rem Install in Chrome
@rem Install in HKLM if running as admin, otherwise HKCU
net session >nul 2>&1
if %errorlevel% == 0 (
    REG ADD "HKLM\Software\Google\Chrome\NativeMessagingHosts\%APP_NAME%" /ve /t REG_SZ /d "%~dp0%APP_NAME%.json" /f
) else (
    REG ADD "HKCU\Software\Google\Chrome\NativeMessagingHosts\%APP_NAME%" /ve /t REG_SZ /d "%~dp0%APP_NAME%.json" /f
)

echo %APP_NAME% has been installed
pause
