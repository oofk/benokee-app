# Resend API Key Configureren

Na het deployen van Firebase Functions, moet je de Resend API key configureren.

## 🔑 API Key
```
re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL
```

## ✅ Methode 1: Via Google Cloud Console (Aanbevolen)

1. Ga naar: https://console.cloud.google.com/functions/list?project=benokee-44657
2. Klik op je function (bijv. `sendEmail` of `sendIntroductionEmail`)
3. Klik op het tabblad **"Configuration"** of **"Variables and secrets"**
4. Klik op **"Add variable"** of **"Edit"**
5. Voeg toe:
   - **Name**: `RESEND_API_KEY`
   - **Value**: `re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL`
6. Klik **"Save"** of **"Deploy"**
7. Wacht 1-2 minuten tot de functions opnieuw zijn gedeployed

**Alternatief**: Via Firebase Console (als beschikbaar):
1. Ga naar: https://console.firebase.google.com/project/benokee-44657/functions
2. Klik op **"Config"** tab (als beschikbaar)
3. Of klik op een function en zoek naar **"Environment variables"** of **"Secrets"**

## ✅ Methode 2: Via Command Line

```powershell
cd C:\Users\olivi\cursor\benokee_app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Set secret (je wordt gevraagd om de waarde in te voeren)
firebase functions:secrets:set RESEND_API_KEY
```

Wanneer gevraagd, voer in: `re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL`

## ✅ Methode 3: Via Environment Variables (Nieuw)

Firebase Functions ondersteunt nu ook environment variables:

```powershell
cd C:\Users\olivi\cursor\benokee_app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Set environment variable
firebase functions:config:set resend.api_key="re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL"
```

**Let op**: Deze methode is deprecated, maar werkt nog wel. Gebruik bij voorkeur Methode 1 (Console).

## 🔍 Verificatie

Na het configureren, test of het werkt:

1. Open de app
2. Voer onboarding uit
3. Probeer introductie e-mail te versturen
4. Check of e-mail wordt ontvangen

## 🆘 Troubleshooting

### "API key not found"
- Check of de key correct is geconfigureerd in Firebase Console
- Wacht 1-2 minuten na het configureren (functions moeten opnieuw deployen)

### "Invalid API key"
- Check of de key correct is gekopieerd (zonder spaties)
- Check of de key nog geldig is in Resend dashboard

### E-mails worden niet verstuurd
- Check Firebase Functions logs: `firebase functions:log`
- Check Resend dashboard voor delivery status

## 📝 Na Configuratie

Na het configureren van de API key:

1. ✅ Verwijder hardcoded API key uit `functions/index.js` (als die er nog in staat)
2. ✅ Test de app
3. ✅ Check Firebase Functions logs voor errors

## 🔒 Security

De API key wordt veilig opgeslagen in Firebase en is niet zichtbaar in de app code. Dit is de veiligste manier om API keys te beheren.
