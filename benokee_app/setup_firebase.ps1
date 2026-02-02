# Firebase Functions Setup Script
# Voer dit script uit NA firebase login

Write-Host "Firebase Functions Setup Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Refresh PATH to include npm global packages
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if firebase is available
$firebaseCheck = Get-Command firebase -ErrorAction SilentlyContinue
if (-not $firebaseCheck) {
    Write-Host "ERROR: Firebase CLI niet gevonden in PATH!" -ForegroundColor Red
    Write-Host "Probeer PowerShell te herstarten, of voer uit:" -ForegroundColor Yellow
    Write-Host '  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")' -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Of gebruik het volledige pad:" -ForegroundColor Yellow
    Write-Host '  & "$env:APPDATA\npm\firebase.cmd" login' -ForegroundColor Cyan
    exit 1
}
Write-Host "✓ Firebase CLI gevonden" -ForegroundColor Green
Write-Host ""

# Check if logged in
Write-Host "Checking Firebase login status..." -ForegroundColor Yellow
$loginCheck = firebase projects:list 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Je bent niet ingelogd op Firebase!" -ForegroundColor Red
    Write-Host "Voer eerst uit: firebase login" -ForegroundColor Yellow
    Write-Host "Dan opnieuw dit script uitvoeren." -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Firebase login OK" -ForegroundColor Green
Write-Host ""

# Set project
Write-Host "Setting Firebase project to benokee-app..." -ForegroundColor Yellow
firebase use benokee-app
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Kon project niet instellen" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Project ingesteld" -ForegroundColor Green
Write-Host ""

# Install dependencies (if not already done)
Write-Host "Checking functions dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "functions\node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    Set-Location functions
    npm install
    Set-Location ..
    Write-Host "✓ Dependencies geïnstalleerd" -ForegroundColor Green
} else {
    Write-Host "✓ Dependencies al geïnstalleerd" -ForegroundColor Green
}
Write-Host ""

# Set Resend API key
Write-Host "Configuring Resend API key..." -ForegroundColor Yellow
firebase functions:config:set resend.api_key="re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Kon API key niet instellen" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Resend API key geconfigureerd" -ForegroundColor Green
Write-Host ""

# Deploy functions
Write-Host "Deploying Firebase Functions..." -ForegroundColor Yellow
Write-Host "Dit kan even duren..." -ForegroundColor Yellow
firebase deploy --only functions
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Deploy gefaald" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Functions gedeployed" -ForegroundColor Green
Write-Host ""

# Remove hardcoded API key from code
Write-Host "Removing hardcoded API key from code..." -ForegroundColor Yellow
$functionsFile = "functions\index.js"
if (Test-Path $functionsFile) {
    $content = Get-Content $functionsFile -Raw
    $content = $content -replace "|| 're_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL'", ""
    Set-Content $functionsFile -Value $content -NoNewline
    Write-Host "✓ Hardcoded API key verwijderd" -ForegroundColor Green
} else {
    Write-Host "WARNING: functions\index.js niet gevonden" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=================================" -ForegroundColor Green
Write-Host "Setup voltooid!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""
Write-Host "Je kunt nu de app testen:" -ForegroundColor Cyan
Write-Host "  flutter run" -ForegroundColor White
