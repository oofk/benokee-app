# Blaze Plan Upgrade - Stap voor Stap

## 📋 Stap 1: Upgrade naar Blaze Plan

1. Ga naar: https://console.firebase.google.com/project/benokee-44657/usage/details
2. Klik op **"Upgrade project"** of **"Modify plan"**
3. Selecteer **"Blaze (Pay as you go)"**
4. Volg de wizard:
   - Voer credit card gegevens in (alleen voor verificatie)
   - Bevestig de upgrade
5. Wacht 2-5 minuten tot de upgrade is voltooid

## ⏳ Wachten op Upgrade

Na de upgrade:
- Firebase moet APIs activeren (automatisch)
- Dit kan 2-5 minuten duren
- Je krijgt een bevestiging in Firebase Console

## ✅ Stap 2: Deploy Functions

**Na de upgrade** (wacht 5 minuten), voer uit:

### Optie A: Gebruik het deploy script
```powershell
cd C:\Users\olivi\cursor\benokee_app
.\deploy_functions.bat
```

Of PowerShell:
```powershell
.\deploy_functions.ps1
```

### Optie B: Handmatig
```powershell
cd C:\Users\olivi\cursor\benokee_app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Set project
firebase use benokee-44657

# Deploy
firebase deploy --only functions
```

## 🔑 Stap 3: Configureer Resend API Key

Na het deployen, zie: `CONFIGUREER_API_KEY.md`

## ⏱️ Tijdlijn

1. **Upgrade**: 2-5 minuten
2. **Wachten op APIs**: 2-5 minuten
3. **Deploy functions**: 2-5 minuten
4. **Configureren API key**: 1 minuut

**Totaal: ~10-15 minuten**

## 🆘 Problemen?

### "Quota exceeded"
- Wacht 1-2 minuten en probeer opnieuw
- Firebase heeft rate limiting

### "Blaze plan required"
- Check of upgrade is voltooid in Firebase Console
- Wacht nog 2-3 minuten

### "API not enabled"
- Firebase enabled APIs automatisch
- Wacht 2-5 minuten na upgrade

## ✅ Checklist

- [ ] Blaze plan upgrade gestart
- [ ] Credit card toegevoegd (alleen voor verificatie)
- [ ] Upgrade voltooid (5 minuten gewacht)
- [ ] Functions gedeployed
- [ ] Resend API key geconfigureerd
- [ ] App getest

## 💡 Budget Alert Instellen (Optioneel)

Na de upgrade, stel een budget alert in:

1. Ga naar: Firebase Console > Usage and Billing
2. Klik "Set budget alert"
3. Stel in: €1/maand (of wat je comfortabel vindt)
4. Krijg een waarschuwing als je boven budget gaat

**Onthoud**: Je betaalt alleen voor gebruik BOVEN de gratis limieten!
