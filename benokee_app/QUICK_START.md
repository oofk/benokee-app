# Quick Start - Firebase Setup

## ⚡ Snelle Start (2 stappen)

### Stap 1: Firebase Login
```powershell
cd C:\Users\olivi\cursor\benokee_app
.\firebase_login.ps1
```

### Stap 2: Deploy Functions
```powershell
.\setup_firebase.ps1
```

**Klaar!** 🎉

---

## 🐛 Probleem: "firebase is not recognized"

Als je deze fout krijgt, probeer dit:

### Oplossing 1: Gebruik het login script
```powershell
.\firebase_login.ps1
```

### Oplossing 2: Refresh PATH handmatig
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
firebase login
```

### Oplossing 3: Gebruik volledige pad
```powershell
& "$env:APPDATA\npm\firebase.cmd" login
```

### Oplossing 4: Herstart PowerShell
Sluit PowerShell en open opnieuw. De PATH wordt dan automatisch vernieuwd.

---

## 📋 Wat gebeurt er?

1. **firebase_login.ps1**: 
   - Refresht PATH
   - Controleert of Firebase CLI beschikbaar is
   - Voert `firebase login` uit

2. **setup_firebase.ps1**:
   - Configureert Resend API key
   - Deployed Firebase Functions
   - Verwijdert hardcoded API key

---

## ✅ Na Setup

Test de app:
```powershell
flutter run
```
