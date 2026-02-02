@echo off
REM Script om code aan te passen en te deployen NA domain verificatie
REM Voer dit uit zodra okerckhoff.nl geverifieerd is in Resend

echo ========================================
echo Domain Verificatie - Code Update & Deploy
echo ========================================
echo.

REM Check of domain geverifieerd is
echo BELANGRIJK: Is okerckhoff.nl geverifieerd in Resend?
echo Check: https://resend.com/domains
echo Zie je een groene vinkje bij okerckhoff.nl?
echo.
set /p verified="Is het domain geverifieerd? (j/n): "
if /i not "%verified%"=="j" (
    echo.
    echo Domain is nog niet geverifieerd!
    echo Volg eerst de stappen in DOMAIN_VERIFICATIE_GUIDE.md
    pause
    exit /b 1
)

echo.
echo Code aanpassen naar geverifieerd domain...
echo.

REM Update functions/index.js
cd /d "%~dp0"
cd functions

REM Backup maken
copy index.js index.js.backup >nul 2>&1

REM Vervang onboarding@resend.dev met noreply@okerckhoff.nl
powershell -Command "(Get-Content index.js) -replace 'Benokee <onboarding@resend.dev>', 'Benokee <noreply@okerckhoff.nl>' | Set-Content index.js"

echo Code aangepast naar: noreply@okerckhoff.nl
echo.

cd ..

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
echo Deploying Firebase Functions met geverifieerd domain...
echo Dit kan 2-5 minuten duren...
echo.

firebase deploy --only functions

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =================================
    echo SUCCESS!
    echo =================================
    echo.
    echo Domain verificatie voltooid!
    echo E-mails worden nu verstuurd vanaf: noreply@okerckhoff.nl
    echo.
    echo Je kunt nu naar ELK e-mailadres sturen:
    echo - Gmail, Hotmail, Yahoo, etc.
    echo - Alle adressen op okerckhoff.nl
    echo.
    echo Test de app en probeer een e-mail te sturen!
) else (
    echo.
    echo ERROR: Deploy gefaald
    echo.
    echo Mogelijke oorzaken:
    echo 1. Domain nog niet volledig geverifieerd - wacht 5 minuten
    echo 2. Check Firebase Console voor errors
    echo 3. Check Resend dashboard voor verificatie status
)

pause
