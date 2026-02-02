# Firebase Login Script
# Dit script refresht de PATH en voert firebase login uit

Write-Host "Firebase Login Script" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""

# Refresh PATH to include npm global packages
Write-Host "Refreshing PATH..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if firebase is available
$firebaseCheck = Get-Command firebase -ErrorAction SilentlyContinue
if (-not $firebaseCheck) {
    Write-Host "ERROR: Firebase CLI niet gevonden!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Oplossing 1: Herstart PowerShell en probeer opnieuw" -ForegroundColor Yellow
    Write-Host "Oplossing 2: Gebruik volledige pad:" -ForegroundColor Yellow
    Write-Host '  & "$env:APPDATA\npm\firebase.cmd" login' -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Oplossing 3: Voeg handmatig toe aan PATH:" -ForegroundColor Yellow
    Write-Host '  $env:Path += ";$env:APPDATA\npm"' -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host "✓ Firebase CLI gevonden" -ForegroundColor Green
Write-Host ""
Write-Host "Starting Firebase login..." -ForegroundColor Yellow
Write-Host "Dit opent een browser waar je moet inloggen." -ForegroundColor Cyan
Write-Host ""

# Run firebase login
firebase login

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Login succesvol!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Je kunt nu het setup script uitvoeren:" -ForegroundColor Cyan
    Write-Host "  .\setup_firebase.ps1" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERROR: Login gefaald" -ForegroundColor Red
    exit 1
}
