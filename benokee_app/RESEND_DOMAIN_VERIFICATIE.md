# Resend Domain Verificatie - Oplossing voor E-mail Probleem

## 🐛 Probleem

Resend's test domain `onboarding@resend.dev` kan **alleen** e-mails versturen naar:
- Het e-mailadres dat geregistreerd is bij je Resend account: `resend@okerckhoff.nl`

Voor andere e-mailadressen (zoals `test_benokee@okerckhoff.nl`) moet je een **domain verifiëren**.

## ✅ Oplossing: Domain Verificatie

### Stap 1: Verifieer Domain in Resend

1. Ga naar: https://resend.com/domains
2. Klik op **"Add Domain"**
3. Voer in: `okerckhoff.nl` (of je eigen domain)
4. Volg de instructies om DNS records toe te voegen:
   - SPF record
   - DKIM records (meerdere)
   - DMARC record (optioneel)

### Stap 2: Wacht op Verificatie

- DNS records kunnen 5-30 minuten duren om te propageren
- Resend verifieert automatisch
- Je krijgt een bevestiging wanneer het domain geverifieerd is

### Stap 3: Update Functions

Na verificatie, pas `functions/index.js` aan:

```javascript
from: 'Benokee <noreply@okerckhoff.nl>', // Je eigen geverifieerde domain
```

Of als je een subdomain wilt:
```javascript
from: 'Benokee <noreply@mail.okerckhoff.nl>', // Subdomain
```

### Stap 4: Redeploy Functions

```powershell
cd C:\Users\olivi\cursor\benokee_app
firebase deploy --only functions
```

## 🔄 Alternatief: Test Eerst met Geregistreerd E-mail

Om te testen of alles werkt, kun je tijdelijk testen met `resend@okerckhoff.nl`:

1. Voer onboarding uit
2. Gebruik e-mail: `resend@okerckhoff.nl`
3. Check of e-mail aankomt

Als dit werkt, dan werkt de setup correct en hoef je alleen het domain te verifiëren.

## 📋 DNS Records Voorbeeld

Voor `okerckhoff.nl` zou je deze records moeten toevoegen:

### SPF Record
```
Type: TXT
Name: @ (of okerckhoff.nl)
Value: v=spf1 include:resend._spf.resend.com ~all
TTL: 3600
```

### DKIM Records
Resend geeft je specifieke DKIM records die je moet toevoegen.

### DMARC Record (Optioneel)
```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=none;
TTL: 3600
```

## ⚠️ Belangrijk

- **Domain verificatie is verplicht** voor productie
- **Test domain werkt alleen** voor geregistreerd e-mailadres
- **DNS propagatie** kan 5-30 minuten duren
- **Check Resend dashboard** voor verificatie status

## 🎯 Snelle Test

**Test eerst met `resend@okerckhoff.nl`** om te bevestigen dat de setup werkt, dan verifieer je het domain voor andere e-mailadressen.
