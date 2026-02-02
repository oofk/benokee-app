# Firebase Setup - Snelle Instructies

## ✅ Wat is al gedaan:

1. ✅ Node.js geïnstalleerd (v24.13.0)
2. ✅ npm geïnstalleerd (v11.6.2)
3. ✅ Firebase CLI geïnstalleerd (v15.4.0)
4. ✅ Functions dependencies geïnstalleerd
5. ✅ Configuratiebestanden aangemaakt

## 🔐 Stap 1: Firebase Login (Eénmalig)

**Optie A: Gebruik het login script (Aanbevolen)**

Open PowerShell en voer uit:

```powershell
cd C:\Users\olivi\cursor\benokee_app
.\firebase_login.ps1
```

Dit script refresht automatisch de PATH en voert firebase login uit.

**Optie B: Handmatig (als script niet werkt)**

Als je een foutmelding krijgt dat firebase niet wordt gevonden:

```powershell
cd C:\Users\olivi\cursor\benokee_app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Of gebruik volledige pad
& "$env:APPDATA\npm\firebase.cmd" login
```

**Optie C: Herstart PowerShell**

Soms helpt het om PowerShell te sluiten en opnieuw te openen, dan is de PATH automatisch vernieuwd.

Dit opent een browser waar je moet inloggen met je Google account. Na het inloggen kun je de PowerShell window sluiten.

## 🚀 Stap 2: Voer Setup Script Uit

Na het inloggen, voer dit script uit:

```powershell
cd C:\Users\olivi\cursor\benokee_app
.\setup_firebase.ps1
```

Dit script doet automatisch:
- ✅ Checkt of je ingelogd bent
- ✅ Stelt Firebase project in (benokee-app)
- ✅ Configureert Resend API key
- ✅ Deployed Firebase Functions
- ✅ Verwijdert hardcoded API key uit code

## 📋 Alternatief: Handmatige Stappen

Als je het script niet wilt gebruiken, voer deze commando's handmatig uit:

```powershell
# 1. Login (eénmalig)
firebase login

# 2. Set project
cd C:\Users\olivi\cursor\benokee_app
firebase use benokee-app

# 3. Configureer API key
firebase functions:config:set resend.api_key="re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL"

# 4. Deploy functions
firebase deploy --only functions

# 5. Verwijder hardcoded API key uit functions/index.js
# (Open het bestand en verwijder: || 're_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL')
```

## ✅ Na Setup

Na het deployen kun je de app testen:

```powershell
cd C:\Users\olivi\cursor\benokee_app
flutter run
```

## 🆘 Troubleshooting

### "Failed to authenticate"
- Voer `firebase login` uit en log in met je Google account

### "Project not found"
- Check of je project "benokee-app" heet in Firebase Console
- Of pas `.firebaserc` aan met je project ID

### "Functions deployment failed"
- Check of je ingelogd bent: `firebase projects:list`
- Check of API key correct is: `firebase functions:config:get`

### "Permission denied"
- Zorg dat je admin rechten hebt op het Firebase project
