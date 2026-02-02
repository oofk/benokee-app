# Firebase Functions Deploy Script
# Voer dit uit NA de Blaze upgrade

Write-Host "Firebase Functions Deploy" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if logged in
Write-Host "Checking Firebase login..." -ForegroundColor Yellow
firebase projects:list | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Je bent niet ingelogd!" -ForegroundColor Red
    Write-Host "Voer uit: firebase login" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Firebase login OK" -ForegroundColor Green
Write-Host ""

# Set project
Write-Host "Setting project to benokee-44657..." -ForegroundColor Yellow
firebase use benokee-44657
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Kon project niet instellen" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Project ingesteld" -ForegroundColor Green
Write-Host ""

# Deploy functions
Write-Host "Deploying Firebase Functions..." -ForegroundColor Yellow
Write-Host "Dit kan 2-5 minuten duren..." -ForegroundColor Cyan
Write-Host ""

firebase deploy --only functions

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=================================" -ForegroundColor Green
    Write-Host "✓ Functions succesvol gedeployed!" -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Volgende stap: Configureer Resend API key" -ForegroundColor Cyan
    Write-Host "Zie: CONFIGUREER_API_KEY.md" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "ERROR: Deploy gefaald" -ForegroundColor Red
    Write-Host ""
    Write-Host "Mogelijke oorzaken:" -ForegroundColor Yellow
    Write-Host "1. Blaze upgrade nog niet voltooid - wacht 5 minuten en probeer opnieuw" -ForegroundColor White
    Write-Host "2. Quota error - wacht 1 minuut en probeer opnieuw" -ForegroundColor White
    Write-Host "3. Check Firebase Console voor errors" -ForegroundColor White
    exit 1
}
