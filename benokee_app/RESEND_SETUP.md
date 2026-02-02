# Resend Setup Instructies

## Overzicht
Resend wordt gebruikt voor het automatisch versturen van e-mails via Firebase Functions. Gebruikers hoeven geen SMTP credentials in te vullen.

## Stap 1: Resend Account Aanmaken

1. Ga naar [resend.com](https://resend.com)
2. Klik op "Sign Up" en maak een gratis account aan
3. Bevestig je e-mailadres

## Stap 2: API Key Aanmaken

1. Log in op Resend
2. Ga naar "API Keys" in het menu
3. Klik op "Create API Key"
4. Geef een naam (bijv. "Benokee App")
5. Kopieer de API key (begint met `re_`)
6. **BELANGRIJK**: Bewaar deze key veilig, je ziet hem maar één keer!

## Stap 3: API Key Toevoegen aan Firebase

### Optie A: Via Firebase CLI (Aanbevolen)
```bash
firebase functions:config:set resend.api_key="re_xxxxxxxxxxxxx"
```

### Optie B: Via Firebase Console
1. Ga naar Firebase Console > Functions > Configuration
2. Klik op "Add variable"
3. Key: `RESEND_API_KEY`
4. Value: `re_xxxxxxxxxxxxx` (je API key)
5. Klik "Save"

## Stap 4: Domain Verificatie (Voor Productie)

### Voor Testen
Je kunt direct beginnen met Resend's test domain. E-mails worden verstuurd van `onboarding@resend.dev`.

### Voor Productie
1. Ga naar Resend > Domains
2. Klik "Add Domain"
3. Voer je domain in (bijv. `benokee.app`)
4. Voeg DNS records toe zoals aangegeven:
   - SPF record
   - DKIM records
   - DMARC record (optioneel)
5. Wacht op verificatie (kan enkele minuten duren)

## Stap 5: E-mail Afzender Aanpassen

In `functions/index.js`, pas de `from` adres aan:

```javascript
from: 'Benokee <noreply@benokee.app>', // Vervang met je eigen domain
```

Voor testen:
```javascript
from: 'Benokee <onboarding@resend.dev>', // Resend test domain
```

## Stap 6: Testen

1. Deploy Firebase Functions:
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

2. Test vanuit de app:
   - Voeg een contactpersoon toe
   - Verstuur introductie e-mail
   - Check of e-mail wordt ontvangen

## Kosten

- **Gratis tier**: 3.000 e-mails per maand
- **Betaald**: $20/maand voor 50.000 e-mails
- **Voor deze app**: Gratis tier is ruim voldoende

## Troubleshooting

### "Invalid API key"
- Check of de API key correct is ingesteld in Firebase
- Check of je de juiste API key hebt gekopieerd

### "Domain not verified"
- Voor productie: verifieer je domain in Resend
- Voor testen: gebruik `onboarding@resend.dev`

### "Rate limit exceeded"
- Gratis tier: 3.000 e-mails/maand
- Check je gebruik in Resend dashboard
- Upgrade naar betaald plan als nodig

## Voordelen

✅ **Gebruikers hoeven niets in te vullen**
✅ **Volledig gratis** (binnen limieten)
✅ **Betrouwbaar** en professioneel
✅ **Goede deliverability**
✅ **Eenvoudig te implementeren**
