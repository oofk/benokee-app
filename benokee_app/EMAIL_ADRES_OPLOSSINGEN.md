# Hoe gebruikers elk e-mailadres kunnen gebruiken

## 🔍 Huidige Situatie

**Probleem:** Alleen `resend@okerckhoff.nl` werkt omdat Resend's test domain (`onboarding@resend.dev`) alleen naar het geregistreerde e-mailadres kan sturen.

## ✅ Oplossingen

### Optie 1: Domain Verificatie (AANBEVOLEN) ⭐

**Hoe het werkt:**
- Verifieer **één domain** in Resend (bijv. `okerckhoff.nl`)
- Na verificatie kun je naar **alle e-mailadressen op dat domain** sturen
- Bijvoorbeeld: `test@okerckhoff.nl`, `info@okerckhoff.nl`, `contact@okerckhoff.nl`, etc.

**Voordelen:**
- ✅ **Gratis** (Resend gratis tier: 3.000 e-mails/maand)
- ✅ **Eénmalige setup** (DNS records toevoegen)
- ✅ **Alle adressen op dat domain** werken automatisch
- ✅ **Goede deliverability** (geverifieerde domain = betrouwbaarder)

**Nadelen:**
- ⚠️ Werkt alleen voor adressen op het geverifieerde domain
- ⚠️ Andere domains (bijv. `@gmail.com`, `@hotmail.com`) werken nog steeds niet

**Stappen:**
1. Verifieer `okerckhoff.nl` in Resend
2. Voeg DNS records toe (SPF, DKIM)
3. Update `functions/index.js` om `noreply@okerckhoff.nl` te gebruiken
4. Redeploy functions

**Resultaat:** Alle gebruikers kunnen naar **ELK e-mailadres** sturen (Gmail, Hotmail, Yahoo, etc.). De e-mails komen wel van `noreply@okerckhoff.nl`, maar kunnen naar elk adres gestuurd worden.

---

### Optie 2: Meerdere Domains Verifiëren

**Hoe het werkt:**
- Verifieer meerdere domains in Resend (bijv. `okerckhoff.nl`, `gmail.com`, `hotmail.com`)
- Voor elk domain kun je naar alle adressen op dat domain sturen

**Voordelen:**
- ✅ Werkt voor meerdere domains
- ✅ Gebruikers kunnen adressen op verschillende domains gebruiken

**Nadelen:**
- ❌ **Je kunt alleen je eigen domains verifiëren** (niet `gmail.com`, `hotmail.com`, etc.)
- ❌ Je moet eigenaar zijn van elk domain
- ❌ Complexere setup (meerdere DNS configuraties)

**Conclusie:** Dit werkt **NIET** voor algemene e-mailproviders zoals Gmail, Hotmail, etc. Je kunt alleen je eigen domains verifiëren.

---

### Optie 3: Andere E-mail Service (MailerSend)

**Hoe het werkt:**
- Schakel over naar MailerSend (12.000 e-mails/maand gratis)
- MailerSend heeft **minder strikte beperkingen** voor test domains
- Of gebruik een service met "catch-all" functionaliteit

**Voordelen:**
- ✅ Mogelijk meer flexibiliteit
- ✅ Meer gratis e-mails (12.000/maand)

**Nadelen:**
- ⚠️ Nog steeds domain verificatie nodig voor betrouwbaarheid
- ⚠️ Code moet aangepast worden
- ⚠️ Test domains hebben meestal nog steeds beperkingen

**Conclusie:** Dit lost het probleem niet op - alle e-mailservices hebben domain verificatie nodig voor betrouwbare levering.

---

### Optie 4: SMTP via Gebruiker (Niet Aanbevolen)

**Hoe het werkt:**
- Gebruikers geven hun eigen e-mailwachtwoord op
- App verstuurt via hun eigen SMTP server
- Werkt naar elk adres

**Voordelen:**
- ✅ Werkt naar elk e-mailadres
- ✅ Geen domain verificatie nodig

**Nadelen:**
- ❌ Gebruikers moeten wachtwoord opgeven (beveiligingsrisico)
- ❌ Complexe setup voor gebruikers
- ❌ Niet gebruiksvriendelijk
- ❌ Gmail vereist "App Password" (2FA nodig)

**Conclusie:** Niet aanbevolen vanwege beveiliging en gebruiksvriendelijkheid.

---

## 🎯 Aanbeveling: Domain Verificatie

**Voor deze app is de beste oplossing:**

### Stap 1: Verifieer `okerckhoff.nl` in Resend
- Dit is eenmalig (5-30 minuten)
- Voeg DNS records toe
- Wacht op verificatie

### Stap 2: Update Code
- Verander `from` adres naar `noreply@okerckhoff.nl`
- Redeploy functions

### Stap 3: Resultaat
- ✅ Alle gebruikers kunnen naar **ELK e-mailadres** sturen (Gmail, Hotmail, Yahoo, etc.)
- ✅ Geen beperkingen meer op ontvangers
- ✅ Betrouwbare e-mail levering
- ✅ E-mails komen van `noreply@okerckhoff.nl` maar kunnen naar elk adres

---

## ❓ Belangrijk: Domain Verificatie = Naar Elk Adres Sturen

**Belangrijke verduidelijking:**
- Domain verificatie is alleen nodig voor het **"from" adres** (wie verstuurt)
- Na verificatie kun je naar **ELK e-mailadres** sturen (Gmail, Hotmail, Yahoo, etc.)
- Je hoeft **niet** elk domain te verifiëren waar je naartoe wilt sturen
- Eén domain verificatie is genoeg om naar alle adressen te kunnen sturen

**Voorbeeld:**
- Verifieer `okerckhoff.nl` → verstuur vanaf `noreply@okerckhoff.nl`
- Nu kun je sturen naar:
  - ✅ `contact@gmail.com`
  - ✅ `vriend@hotmail.com`
  - ✅ `familie@yahoo.com`
  - ✅ `test@okerckhoff.nl`
  - ✅ **Elk ander e-mailadres**

---

## 📋 Conclusie

**Kort antwoord:**
- ✅ **Verifieer één domain** (`okerckhoff.nl`) → alle adressen op dat domain werken
- ❌ **Meerdere domains toevoegen** werkt alleen voor je eigen domains (niet voor Gmail, etc.)
- ✅ **Domain verificatie is de standaard** voor alle professionele e-mailservices

**Voor productie:** Domain verificatie is **verplicht** voor betrouwbare e-mail levering. Dit is niet alleen een Resend beperking, maar een industrie-standaard beveiligingsmaatregel.

**Belangrijk:** Na verificatie van één domain (bijv. `okerckhoff.nl`) kun je naar **ELK e-mailadres** sturen, niet alleen adressen op dat domain. De verificatie is alleen nodig om te bewijzen dat jij de eigenaar bent van het "from" adres, niet voor de ontvangers.
