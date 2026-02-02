# Waarom werkt resend@okerckhoff.nl wel en andere adressen niet?

## 🔍 Het Probleem

**Resend's test domain** (`onboarding@resend.dev`) heeft een belangrijke beperking:

### ✅ Wat WEL werkt:
- **`resend@okerckhoff.nl`** - Dit is het e-mailadres waarmee je Resend account is aangemaakt
- Resend's test domain kan **alleen** naar dit geregistreerde adres sturen

### ❌ Wat NIET werkt:
- **Andere e-mailadressen** zoals `test_benokee@okerckhoff.nl`, `info@okerckhoff.nl`, etc.
- Deze vereisen **domain verificatie** voordat ze kunnen ontvangen

## 🎯 Waarom deze beperking?

Resend heeft deze beperking om:
1. **Spam te voorkomen** - Voorkomt dat test domains worden misbruikt
2. **Beveiliging** - Zorgt dat alleen geverifieerde domains kunnen versturen
3. **Kwaliteit** - Garandeert betere e-mail deliverability

## ✅ Oplossing: Domain Verificatie

Om naar **alle** e-mailadressen op `okerckhoff.nl` te kunnen sturen:

### Stap 1: Verifieer Domain in Resend
1. Ga naar: https://resend.com/domains
2. Klik op **"Add Domain"**
3. Voer in: `okerckhoff.nl`
4. Resend geeft je DNS records die je moet toevoegen

### Stap 2: Voeg DNS Records Toe
Voeg deze records toe aan je domain provider (waar je `okerckhoff.nl` beheert):

**SPF Record:**
```
Type: TXT
Name: @ (of okerckhoff.nl)
Value: v=spf1 include:resend._spf.resend.com ~all
```

**DKIM Records:**
Resend geeft je specifieke DKIM records (meestal 2-3 records)

**DMARC Record (optioneel):**
```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=none;
```

### Stap 3: Wacht op Verificatie
- DNS records kunnen 5-30 minuten duren om te propageren
- Resend controleert automatisch
- Je ziet in het dashboard wanneer het domain geverifieerd is (groene vinkje)

### Stap 4: Update Code
Nadat het domain geverifieerd is, pas `functions/index.js` aan:

**Zoek:**
```javascript
const fromAddress = process.env.RESEND_FROM_ADDRESS || 'Benokee <onboarding@resend.dev>';
```

**Verander naar:**
```javascript
const fromAddress = process.env.RESEND_FROM_ADDRESS || 'Benokee <noreply@okerckhoff.nl>';
```

### Stap 5: Redeploy Functions
```powershell
cd C:\Users\olivi\cursor\benokee_app
firebase deploy --only functions
```

## 🧪 Test Na Verificatie

Na verificatie kun je naar **ELK e-mailadres** sturen (niet alleen adressen op `okerckhoff.nl`):
- ✅ `test_benokee@okerckhoff.nl`
- ✅ `contact@gmail.com`
- ✅ `vriend@hotmail.com`
- ✅ `familie@yahoo.com`
- ✅ **Elk ander e-mailadres**

**Belangrijk:** Domain verificatie is alleen nodig voor het **"from" adres**. Na verificatie kun je naar **alle** e-mailadressen sturen, ongeacht het domain.

## 📋 Huidige Status

- ✅ **Test domain werkt**: `resend@okerckhoff.nl` ontvangt e-mails
- ⏳ **Domain verificatie nodig**: Voor andere adressen
- ✅ **Setup is correct**: Zodra domain geverifieerd is, werkt alles

## 💡 Alternatief (Voor Testen)

Als je snel wilt testen zonder domain verificatie:
- Gebruik tijdelijk `resend@okerckhoff.nl` als test adres
- Dit bevestigt dat de setup correct werkt
- Verifieer daarna het domain voor productie gebruik

## ⚠️ Belangrijk

- **Domain verificatie is verplicht** voor productie gebruik
- **Test domain is alleen** voor ontwikkeling/testen
- **DNS propagatie** kan 5-30 minuten duren
- **Check Resend dashboard** voor verificatie status
