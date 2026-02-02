@echo off
REM Firebase Functions Setup Script
REM Voer dit script uit NA firebase login

echo Firebase Functions Setup Script
echo ================================
echo.

REM Refresh PATH
set "PATH=%PATH%;%APPDATA%\npm"

REM Check if logged in
echo Checking Firebase login status...
firebase projects:list >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Je bent niet ingelogd op Firebase!
    echo Voer eerst uit: firebase_login.bat
    echo.
    pause
    exit /b 1
)

echo Firebase login OK
echo.

REM Set project
echo Setting Firebase project to benokee-app...
firebase use benokee-app
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Kon project niet instellen
    pause
    exit /b 1
)
echo Project ingesteld
echo.

REM Install dependencies (if not already done)
echo Checking functions dependencies...
if not exist "functions\node_modules" (
    echo Installing dependencies...
    cd functions
    call npm install
    cd ..
    echo Dependencies geinstalleerd
) else (
    echo Dependencies al geinstalleerd
)
echo.

REM Set Resend API key
echo Configuring Resend API key...
firebase functions:config:set resend.api_key="re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Kon API key niet instellen
    pause
    exit /b 1
)
echo Resend API key geconfigureerd
echo.

REM Deploy functions
echo Deploying Firebase Functions...
echo Dit kan even duren...
firebase deploy --only functions
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Deploy gefaald
    pause
    exit /b 1
)
echo Functions gedeployed
echo.

REM Remove hardcoded API key from code
echo Removing hardcoded API key from code...
if exist "functions\index.js" (
    REM This is a simple approach - PowerShell would be better for regex
    echo API key moet handmatig verwijderd worden uit functions\index.js
    echo Verwijder: || 're_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL'
) else (
    echo WARNING: functions\index.js niet gevonden
)
echo.

echo =================================
echo Setup voltooid!
echo =================================
echo.
echo Je kunt nu de app testen:
echo   flutter run
echo.
pause
