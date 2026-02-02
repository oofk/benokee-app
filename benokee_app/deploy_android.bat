@echo off
REM Android Device Deployment Script

echo Android Device Deployment
echo =========================
echo.

echo Zoeken naar Android device...
echo Zorg dat:
echo   1. Device is ontgrendeld
echo   2. USB debugging is aan
echo   3. USB kabel is goed aangesloten
echo.

REM Check devices
flutter devices

echo.
echo Als je device online is, druk op een toets om door te gaan...
pause

echo.
echo Deploying app...
echo Dit kan 1-3 minuten duren...
echo.

flutter run -d HA1EYG0B

if %ERRORLEVEL% EQU 0 (
    echo.
    echo App succesvol gedeployed!
) else (
    echo.
    echo ERROR: Deploy gefaald
    echo Check de error messages hierboven
)

pause
