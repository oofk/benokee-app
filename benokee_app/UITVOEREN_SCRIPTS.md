# Hoe PowerShell Scripts Uitvoeren

## ⚠️ Probleem: "Script kan niet worden uitgevoerd"

PowerShell blokkeert standaard het uitvoeren van scripts. Hier zijn de oplossingen:

## ✅ Oplossing 1: Script direct uitvoeren (Aanbevolen)

Gebruik de `-File` parameter:

```powershell
cd C:\Users\olivi\cursor\benokee_app
powershell -ExecutionPolicy Bypass -File .\firebase_login.ps1
```

Of:

```powershell
cd C:\Users\olivi\cursor\benokee_app
.\firebase_login.ps1
```

Als dat niet werkt, probeer:

```powershell
cd C:\Users\olivi\cursor\benokee_app
& ".\firebase_login.ps1"
```

## ✅ Oplossing 2: Execution Policy tijdelijk aanpassen

Voer dit uit in PowerShell (als Administrator):

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Dan kun je scripts normaal uitvoeren:

```powershell
cd C:\Users\olivi\cursor\benokee_app
.\firebase_login.ps1
```

## ✅ Oplossing 3: Commando's direct uitvoeren (Zonder script)

Als scripts niet werken, voer de commando's direct uit:

### Firebase Login:
```powershell
cd C:\Users\olivi\cursor\benokee_app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Firebase login
firebase login
```

### Na login, deploy functions:
```powershell
cd C:\Users\olivi\cursor\benokee_app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Set project
firebase use benokee-app

# Configureer API key
firebase functions:config:set resend.api_key="re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL"

# Deploy
firebase deploy --only functions
```

## 📋 Stap-voor-stap (Zonder scripts)

### Stap 1: Open PowerShell
Open PowerShell (niet als Administrator nodig, tenzij je execution policy wilt aanpassen)

### Stap 2: Ga naar project folder
```powershell
cd C:\Users\olivi\cursor\benokee_app
```

### Stap 3: Refresh PATH
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### Stap 4: Firebase Login
```powershell
firebase login
```
Dit opent een browser waar je moet inloggen.

### Stap 5: Configureer en Deploy
```powershell
# Set project
firebase use benokee-app

# Configureer API key
firebase functions:config:set resend.api_key="re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL"

# Deploy functions
firebase deploy --only functions
```

## 🔍 Check Execution Policy

Om te zien wat je huidige policy is:

```powershell
Get-ExecutionPolicy
```

Mogelijke waarden:
- `Restricted` - Scripts zijn geblokkeerd (standaard)
- `RemoteSigned` - Lokale scripts mogen, externe moeten getekend zijn
- `Unrestricted` - Alles mag (niet aanbevolen)

## ⚙️ Execution Policy Aanpassen (Optioneel)

Als je scripts wilt kunnen uitvoeren zonder `-ExecutionPolicy Bypass`:

```powershell
# Alleen voor huidige gebruiker (veilig)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Dit vraagt om bevestiging. Type `Y` en druk Enter.

## 🎯 Snelle Commando's (Copy-paste)

**Firebase Login:**
```powershell
cd C:\Users\olivi\cursor\benokee_app; $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User"); firebase login
```

**Na login - Deploy:**
```powershell
cd C:\Users\olivi\cursor\benokee_app; $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User"); firebase use benokee-app; firebase functions:config:set resend.api_key="re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL"; firebase deploy --only functions
```
