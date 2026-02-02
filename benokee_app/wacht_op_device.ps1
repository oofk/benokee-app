# Script om te wachten tot Android device online is en dan app te deployen

Write-Host "Android Device Deployment Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

$maxAttempts = 12
$attempt = 0
$deviceFound = $false

Write-Host "Zoeken naar Android device..." -ForegroundColor Yellow
Write-Host "Zorg dat:" -ForegroundColor Cyan
Write-Host "  1. Device is ontgrendeld" -ForegroundColor White
Write-Host "  2. USB debugging is aan (Developer options)" -ForegroundColor White
Write-Host "  3. USB kabel is goed aangesloten" -ForegroundColor White
Write-Host "  4. Je hebt de 'Allow USB debugging' popup geaccepteerd" -ForegroundColor White
Write-Host ""

while ($attempt -lt $maxAttempts -and -not $deviceFound) {
    $attempt++
    Write-Host "Poging $attempt/$maxAttempts..." -ForegroundColor Yellow
    
    $devices = flutter devices 2>&1
    $androidDevice = $devices | Select-String -Pattern "HA1EYG0B.*android.*\(mobile\)" -CaseSensitive:$false
    
    if ($androidDevice -and $androidDevice.ToString() -notmatch "offline") {
        Write-Host "✓ Android device gevonden en online!" -ForegroundColor Green
        $deviceFound = $true
        break
    }
    
    if ($attempt -lt $maxAttempts) {
        Write-Host "Device nog niet online, wachten 5 seconden..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}

if (-not $deviceFound) {
    Write-Host ""
    Write-Host "ERROR: Android device niet gevonden of nog offline" -ForegroundColor Red
    Write-Host ""
    Write-Host "Probeer:" -ForegroundColor Yellow
    Write-Host "  1. Ontkoppel en koppel USB kabel opnieuw aan" -ForegroundColor White
    Write-Host "  2. Ontgrendel je device" -ForegroundColor White
    Write-Host "  3. Accepteer de 'Allow USB debugging' popup" -ForegroundColor White
    Write-Host "  4. Check of USB debugging aan staat in Developer options" -ForegroundColor White
    Write-Host ""
    Write-Host "Zie: ANDROID_DEVICE_VERBINDEN.md voor gedetailleerde instructies" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "Deploying app naar Android device..." -ForegroundColor Green
Write-Host "Dit kan 1-3 minuten duren..." -ForegroundColor Cyan
Write-Host ""

# Deploy app
flutter run -d HA1EYG0B

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ App succesvol gedeployed!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "ERROR: Deploy gefaald" -ForegroundColor Red
    Write-Host "Check de error messages hierboven" -ForegroundColor Yellow
}
