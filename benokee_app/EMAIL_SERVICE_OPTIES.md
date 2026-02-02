# Gratis E-mail Services als Backend Alternatief

## Overzicht
Dit document beschrijft gratis e-mailservices die je als backend kunt gebruiken, zodat gebruikers **geen SMTP-credentials hoeven in te vullen**.

## Belangrijk: Backend Vereist
⚠️ **Let op**: Deze services vereisen wel een backend (Firebase Functions, eigen server, etc.) om de API aan te roepen. De app kan niet direct naar deze services sturen zonder backend.

---

## Top Gratis Opties

### 1. Resend ⭐ (AANBEVOLEN)
**Gratis Tier:**
- ✅ **3.000 e-mails per maand** gratis
- ✅ **100 e-mails per dag** gratis
- ✅ Geen creditcard nodig
- ✅ Moderne API, goede documentatie
- ✅ Goede deliverability

**Kosten:**
- Gratis: 3.000/maand
- Betaald: $20/maand voor 50.000 e-mails

**Implementatie:**
- Firebase Functions (gratis tier)
- Of eigen Node.js/Python server
- API key in backend (niet in app)

**Geschikt voor:** ✅ **BESTE OPTIE** - ruim voldoende voor deze app

---

### 2. SendGrid
**Gratis Tier:**
- ✅ **100 e-mails per dag** gratis
- ✅ Geen creditcard nodig
- ✅ Betrouwbaar en populair

**Kosten:**
- Gratis: 100/dag
- Betaald: $19.95/maand voor 50.000 e-mails

**Implementatie:**
- Firebase Functions
- API key in backend

**Geschikt voor:** ✅ Goed, maar minder dan Resend

---

### 3. Mailgun
**Gratis Tier:**
- ✅ **5.000 e-mails per maand** gratis (eerste 3 maanden)
- ✅ Daarna: 1.000 e-mails/maand gratis
- ⚠️ Creditcard vereist (maar niet afgeschreven)

**Kosten:**
- Gratis: 1.000/maand (na 3 maanden)
- Betaald: $35/maand voor 50.000 e-mails

**Implementatie:**
- Firebase Functions
- API key in backend

**Geschikt voor:** ⚠️ Minder dan Resend na 3 maanden

---

### 4. MailerSend
**Gratis Tier:**
- ✅ **12.000 e-mails per maand** gratis
- ✅ Geen creditcard nodig
- ✅ Levenslang gratis

**Kosten:**
- Gratis: 12.000/maand
- Betaald: $15/maand voor 50.000 e-mails

**Implementatie:**
- Firebase Functions
- API key in backend

**Geschikt voor:** ✅ Zeer goed - meeste gratis e-mails

---

### 5. Gmail SMTP (via eigen account)
**Hoe het werkt:**
- Je maakt een Gmail account aan voor de app
- Je gebruikt dit account om alle e-mails te versturen
- Gebruikers hoeven niets in te vullen

**Limieten:**
- ✅ **500 e-mails per dag** gratis
- ⚠️ Alle e-mails komen van hetzelfde adres (bijv. benokee.app@gmail.com)

**Implementatie:**
- Firebase Functions met Gmail SMTP
- Of direct vanuit app met vaste credentials (minder veilig)

**Geschikt voor:** ⚠️ Werkt, maar alle e-mails van één adres

---

## Vergelijking

| Service | Gratis Tier | Creditcard | Backend | Aanbeveling |
|---------|-------------|------------|---------|-------------|
| **Resend** | 3.000/maand | ❌ | ✅ | ⭐⭐⭐ Beste balans |
| **MailerSend** | 12.000/maand | ❌ | ✅ | ⭐⭐⭐ Meeste e-mails |
| **SendGrid** | 100/dag | ❌ | ✅ | ⭐⭐ Goed |
| **Mailgun** | 1.000/maand | ✅ | ✅ | ⭐ Minder |
| **Gmail SMTP** | 500/dag | ❌ | ⚠️ | ⭐⭐ Werkt, maar één adres |

---

## Aanbeveling: Resend + Firebase Functions

**Waarom Resend:**
1. ✅ **3.000 e-mails/maand** gratis (ruim voldoende)
2. ✅ **Geen creditcard** nodig
3. ✅ **Moderne API** met goede documentatie
4. ✅ **Goede deliverability**
5. ✅ **Eenvoudige implementatie**

**Implementatie:**
1. Maak Resend account aan (gratis)
2. Haal API key op
3. Maak Firebase Function die Resend API aanroept
4. App roept Firebase Function aan (geen API key in app)
5. Gebruikers hoeven **niets** in te vullen

**Firebase Functions Kosten:**
- ✅ **Gratis tier**: 2 miljoen invocations/maand
- ✅ **Ruim voldoende** voor deze app

**Totale Kosten: €0/maand** 🎉

---

## Alternatief: MailerSend (meer e-mails)

Als je meer e-mails nodig hebt:
- **12.000 e-mails/maand** gratis
- Zelfde implementatie als Resend
- Ook geen creditcard nodig

---

## Implementatie Stappen

### Stap 1: Resend Account
1. Ga naar [resend.com](https://resend.com)
2. Maak gratis account aan
3. Haal API key op

### Stap 2: Firebase Function
```javascript
const functions = require('firebase-functions');
const { Resend } = require('resend');

const resend = new Resend('re_xxxxxxxxxxxxx'); // API key

exports.sendEmail = functions.https.onCall(async (data, context) => {
  const { to, subject, body } = data;
  
  await resend.emails.send({
    from: 'Benokee <noreply@benokee.app>', // Je eigen domain
    to: to,
    subject: subject,
    html: body,
  });
  
  return { success: true };
});
```

### Stap 3: App Code
```dart
// In Flutter app
final result = await FirebaseFunctions.instance
    .httpsCallable('sendEmail')
    .call({
      'to': contactEmail,
      'subject': subject,
      'body': body,
    });
```

---

## Voordelen van deze Aanpak

✅ **Gebruikers hoeven niets in te vullen**
✅ **Geen SMTP setup nodig**
✅ **Volledig gratis** (binnen limieten)
✅ **Betrouwbaar** (professionele service)
✅ **Goede deliverability**
✅ **Eenvoudig te implementeren**

---

## Nadelen

⚠️ **Vereist backend** (Firebase Functions)
⚠️ **Gratis limieten** (maar ruim voldoende voor deze app)
⚠️ **E-mails komen van één adres** (niet van gebruiker zelf)

---

## Conclusie

**Beste optie: Resend + Firebase Functions**

- ✅ 3.000 e-mails/maand gratis
- ✅ Geen creditcard nodig
- ✅ Gebruikers hoeven niets in te vullen
- ✅ Volledig gratis voor ontwikkelaar
- ✅ Eenvoudig te implementeren

Wil je dat ik dit implementeer?
