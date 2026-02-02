# E-mails naar elk adres sturen (Gmail, Hotmail, etc.)

## ✅ Goed Nieuws!

**Na domain verificatie kun je naar ELK e-mailadres sturen**, niet alleen adressen op het geverifieerde domain!

## 🔍 Hoe het werkt

### Domain Verificatie = "From" Adres, niet "To" Adres

**Domain verificatie is alleen nodig voor:**
- Het **"from" adres** (wie verstuurt) - bijv. `noreply@okerckhoff.nl`

**Domain verificatie is NIET nodig voor:**
- Het **"to" adres** (wie ontvangt) - kan elk adres zijn!

### Voorbeeld

**Na verificatie van `okerckhoff.nl`:**
- ✅ Verstuur vanaf: `noreply@okerckhoff.nl` (geverifieerd)
- ✅ Naar: `contact@gmail.com` ← **Werkt!**
- ✅ Naar: `vriend@hotmail.com` ← **Werkt!**
- ✅ Naar: `familie@yahoo.com` ← **Werkt!**
- ✅ Naar: `test@okerckhoff.nl` ← **Werkt!**
- ✅ Naar: **Elk ander e-mailadres** ← **Werkt!**

## 🎯 Oplossing: Verifieer één domain

**Stappen:**
1. Verifieer `okerckhoff.nl` in Resend (éénmalig, 5-30 minuten)
2. Update `functions/index.js` om `noreply@okerckhoff.nl` te gebruiken
3. Redeploy functions

**Resultaat:**
- ✅ Gebruikers kunnen naar **ELK e-mailadres** sturen
- ✅ Gmail, Hotmail, Yahoo, etc. - alles werkt!
- ✅ Geen beperkingen meer op ontvangers

## 📧 Wat betekent dit?

**Voor gebruikers:**
- Ze kunnen elk e-mailadres invullen (Gmail, Hotmail, etc.)
- Alle e-mails werken
- E-mails komen wel van `noreply@okerckhoff.nl`, maar dat is normaal

**Voor jou:**
- Je hoeft maar **één domain** te verifiëren
- Geen meerdere domains nodig
- Eénmalige setup

## ⚠️ Belangrijk

- **Domain verificatie is verplicht** voor betrouwbare e-mail levering
- Dit is een beveiligingsmaatregel (voorkomt spam)
- Na verificatie: **geen beperkingen** op ontvangers

## 🚀 Volgende Stap

Verifieer `okerckhoff.nl` in Resend en je kunt direct naar alle e-mailadressen sturen!
