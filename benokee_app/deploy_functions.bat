@echo off
REM Firebase Functions Deploy Script
REM Voer dit uit NA de Blaze upgrade

echo Firebase Functions Deploy
echo ========================
echo.

REM Refresh PATH
set "PATH=%PATH%;%APPDATA%\npm"

REM Check if logged in
echo Checking Firebase login...
firebase projects:list >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Je bent niet ingelogd!
    echo Voer uit: firebase login
    pause
    exit /b 1
)
echo Firebase login OK
echo.

REM Set project
echo Setting project to benokee-44657...
firebase use benokee-44657
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Kon project niet instellen
    pause
    exit /b 1
)
echo Project ingesteld
echo.

REM Deploy functions
echo Deploying Firebase Functions...
echo Dit kan 2-5 minuten duren...
echo.

firebase deploy --only functions

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =================================
    echo Functions succesvol gedeployed!
    echo =================================
    echo.
    echo Volgende stap: Configureer Resend API key
    echo Zie: CONFIGUREER_API_KEY.md
) else (
    echo.
    echo ERROR: Deploy gefaald
    echo.
    echo Mogelijke oorzaken:
    echo 1. Blaze upgrade nog niet voltooid - wacht 5 minuten
    echo 2. Quota error - wacht 1 minuut en probeer opnieuw
    echo 3. Check Firebase Console voor errors
)

pause
