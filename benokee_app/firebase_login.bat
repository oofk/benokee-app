@echo off
REM Firebase Login Batch Script
REM Dit werkt zonder execution policy problemen

echo Firebase Login Script
echo =====================
echo.

REM Refresh PATH
echo Refreshing PATH...
set "PATH=%PATH%;%APPDATA%\npm"

REM Check if firebase exists
where firebase >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Firebase CLI niet gevonden!
    echo.
    echo Probeer het volledige pad:
    echo   "%APPDATA%\npm\firebase.cmd" login
    echo.
    pause
    exit /b 1
)

echo Firebase CLI gevonden
echo.
echo Starting Firebase login...
echo Dit opent een browser waar je moet inloggen.
echo.

REM Run firebase login
firebase login

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Login succesvol!
    echo.
    echo Je kunt nu het setup script uitvoeren:
    echo   setup_firebase.bat
) else (
    echo.
    echo ERROR: Login gefaald
    pause
    exit /b 1
)

pause
