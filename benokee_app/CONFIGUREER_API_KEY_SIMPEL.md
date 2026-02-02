# Resend API Key Configureren - Simpele Methode

## 🔑 API Key
```
re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL
```

## ✅ Methode 1: Via Command Line (Makkelijkst)

Voer dit uit in PowerShell:

```powershell
cd C:\Users\olivi\cursor\benokee_app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Set environment variable (nieuwe methode)
firebase functions:config:set resend.api_key="re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL"

# Redeploy functions om de config toe te passen
firebase deploy --only functions
```

## ✅ Methode 2: Via Google Cloud Console

1. Ga naar: https://console.cloud.google.com/functions/list?project=benokee-44657
2. Klik op een function (bijv. `sendEmail`)
3. Klik op **"Edit"** (bovenaan)
4. Scroll naar **"Runtime, build, connections and security settings"**
5. Klik op **"Runtime environment variables"**
6. Klik **"Add variable"**
7. Voeg toe:
   - **Name**: `RESEND_API_KEY`
   - **Value**: `re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL`
8. Klik **"Deploy"** (onderaan)
9. Wacht 2-3 minuten

## ✅ Methode 3: Via Secrets (Meest Veilig)

```powershell
cd C:\Users\olivi\cursor\benokee_app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Maak secret aan (je wordt gevraagd om de waarde)
firebase functions:secrets:set RESEND_API_KEY
```

Wanneer gevraagd, voer in: `re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL`

**Let op**: Je moet dan ook `functions/index.js` aanpassen om de secret te gebruiken.

## 🎯 Aanbeveling

**Gebruik Methode 1** (Command Line) - Dit is het makkelijkst en werkt direct.

## 🔍 Verificatie

Na het configureren:

1. Test de app
2. Probeer een introductie e-mail te versturen
3. Check of e-mail wordt ontvangen
4. Check Firebase Functions logs voor errors: `firebase functions:log`

## 🆘 Troubleshooting

### "Config not found"
- Zorg dat functions eerst zijn gedeployed
- Wacht 1-2 minuten na deploy

### "Invalid API key"
- Check of de key correct is gekopieerd (zonder spaties)
- Check Resend dashboard of key nog geldig is

### E-mails worden niet verstuurd
- Check logs: `firebase functions:log`
- Check of API key correct is geconfigureerd
- Check Resend dashboard voor delivery status
