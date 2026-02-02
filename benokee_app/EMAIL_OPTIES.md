# Opties voor Automatisch E-mail Versturen

## Vereisten
- Geen eigen backend service
- Geen kosten voor ontwikkelaar
- Kosten voor gebruiker zijn acceptabel
- Goedkeuring tijdens installatie is mogelijk
- E-mails moeten automatisch worden verstuurd zonder gebruikersbevestiging

## Opties

### 1. SMTP Direct vanuit App (AANBEVOLEN) ⭐
**Hoe het werkt:**
- Gebruiker geeft tijdens onboarding zijn e-mailadres en wachtwoord/app-wachtwoord op
- App verstuurt e-mails direct via SMTP (Simple Mail Transfer Protocol)
- Geen backend nodig, alles gebeurt in de app

**Voordelen:**
- ✅ Geen kosten voor ontwikkelaar
- ✅ Geen backend service nodig
- ✅ Gebruiker gebruikt zijn eigen e-mailaccount
- ✅ Volledig automatisch verzenden mogelijk
- ✅ Eénmalige setup tijdens onboarding

**Nadelen:**
- ⚠️ Gebruiker moet e-mailwachtwoord/app-wachtwoord opgeven
- ⚠️ Beveiliging: wachtwoord wordt lokaal opgeslagen (versleuteld)
- ⚠️ Gmail vereist "App Password" (2FA moet aan staan)
- ⚠️ Sommige providers blokkeren SMTP vanuit apps

**Implementatie:**
- Flutter package: `mailer` (https://pub.dev/packages/mailer)
- Ondersteunt SMTP met SSL/TLS
- Werkt op Android en iOS

**Geschikt voor:** ✅ Deze app - beste balans tussen functionaliteit en eenvoud

---

### 2. Firebase Functions (Gratis Tier)
**Hoe het werkt:**
- Firebase Functions draaien op Google's servers
- App roept Firebase Function aan
- Function verstuurt e-mail via SendGrid/Mailgun API

**Voordelen:**
- ✅ Gratis tier: 2 miljoen invocations/maand
- ✅ Geen wachtwoord opslag in app nodig
- ✅ Betrouwbaar en schaalbaar

**Nadelen:**
- ⚠️ Vereist Firebase project setup
- ⚠️ E-mailservice (SendGrid/Mailgun) heeft gratis tier maar beperkt
- ⚠️ Complexere implementatie
- ⚠️ Vereist internetverbinding

**Implementatie:**
- Firebase Functions (Node.js/Python)
- E-mailservice API (SendGrid gratis: 100 emails/dag)

**Geschikt voor:** ⚠️ Deze app - mogelijk maar complexer

---

### 3. Gmail API met OAuth2
**Hoe het werkt:**
- Gebruiker geeft toestemming via OAuth2
- App krijgt toegang tot Gmail API
- App kan e-mails versturen via Gmail API

**Voordelen:**
- ✅ Geen wachtwoord opslag nodig
- ✅ Gebruiker geeft expliciete toestemming
- ✅ Werkt alleen met Gmail accounts
- ✅ Gratis (binnen Gmail limieten)

**Nadelen:**
- ⚠️ Alleen Gmail accounts
- ⚠️ Complexe OAuth2 implementatie
- ⚠️ Gebruiker moet Google account hebben
- ⚠️ Vereist Google Cloud project setup

**Implementatie:**
- Google Sign-In package
- Gmail API package
- OAuth2 flow

**Geschikt voor:** ⚠️ Deze app - alleen als alle gebruikers Gmail hebben

---

### 4. E-mailservice API Direct (SendGrid/Mailgun)
**Hoe het werkt:**
- Gebruiker maakt eigen account bij e-mailservice
- Gebruiker geeft API key aan app
- App verstuurt e-mails via API

**Voordelen:**
- ✅ Geen wachtwoord opslag
- ✅ Betrouwbaar
- ✅ Werkt met alle e-mailproviders

**Nadelen:**
- ⚠️ Gebruiker moet account maken bij service
- ⚠️ Gratis tier beperkt (100-300 emails/dag)
- ⚠️ Complex voor eindgebruiker

**Geschikt voor:** ❌ Deze app - te complex voor doelgroep

---

## Aanbeveling: SMTP Direct vanuit App

**Waarom:**
1. **Eenvoudig voor gebruiker**: Eénmalige setup tijdens onboarding
2. **Geen kosten**: Gebruiker gebruikt zijn eigen e-mailaccount
3. **Geen backend nodig**: Alles gebeurt in de app
4. **Volledig automatisch**: E-mails worden direct verstuurd
5. **Werkt met alle providers**: Gmail, Outlook, Yahoo, etc.

**Implementatie stappen:**
1. Tijdens onboarding: vraag e-mailadres en wachtwoord/app-wachtwoord
2. Sla credentials veilig op (versleuteld met Flutter Secure Storage)
3. Gebruik `mailer` package om e-mails te versturen via SMTP
4. Automatisch verzenden zonder gebruikersinteractie

**Beveiliging:**
- Gebruik Flutter Secure Storage voor wachtwoord opslag
- Gebruik SSL/TLS voor SMTP verbinding
- Geef duidelijke uitleg over waarom wachtwoord nodig is
- Optioneel: alleen app-wachtwoord vragen (veiliger)

**Gmail App Password instructies:**
- Gebruiker moet 2FA aanzetten
- App Password genereren in Google Account instellingen
- Dit wachtwoord gebruiken in plaats van normaal wachtwoord

---

---

## Alternatieven naast E-mail

### 1. SMS (Tekstberichten) 📱
**Hoe het werkt:**
- Gebruiker geeft telefoonnummer van contactpersoon op
- App verstuurt SMS via telefoon van gebruiker (native SMS intent)
- Of via SMS service API (gebruiker betaalt per SMS)

**Voordelen:**
- ✅ Direct en betrouwbaar
- ✅ Hoge open rate (bijna 100%)
- ✅ Werkt zonder internet
- ✅ Iedereen heeft telefoon

**Nadelen:**
- ⚠️ Kosten per SMS (gebruiker betaalt)
- ⚠️ Native SMS vereist handmatige bevestiging (niet volledig automatisch)
- ⚠️ SMS API services (Twilio) vereisen backend of kosten
- ⚠️ Beperkte lengte (160 tekens)

**Implementatie:**
- Native: `url_launcher` met `sms:` protocol (opent SMS app)
- API: Twilio (vereist backend), Nexmo, etc.

**Geschikt voor:** ⚠️ Als aanvulling op e-mail, niet als primaire methode

---

### 2. Telegram Bot 🤖
**Hoe het werkt:**
- Gebruiker maakt Telegram Bot aan (gratis)
- Gebruiker krijgt Bot Token
- Contactpersoon moet Telegram hebben en bot toevoegen
- App verstuurt berichten via Telegram Bot API

**Voordelen:**
- ✅ Volledig gratis
- ✅ Geen backend nodig (direct API calls)
- ✅ Automatisch verzenden mogelijk
- ✅ Betrouwbaar en snel

**Nadelen:**
- ⚠️ Contactpersoon moet Telegram hebben
- ⚠️ Contactpersoon moet bot toevoegen
- ⚠️ Minder universeel dan e-mail
- ⚠️ Extra setup voor gebruiker

**Implementatie:**
- Flutter package: `telegram_bot_api` of direct HTTP requests
- Telegram Bot API: https://core.telegram.org/bots/api

**Geschikt voor:** ⚠️ Alleen als contactpersoon Telegram heeft

---

### 3. WhatsApp (via WhatsApp Business API)
**Hoe het werkt:**
- Gebruiker maakt WhatsApp Business account
- App gebruikt WhatsApp Business API
- Berichten worden verstuurd via WhatsApp

**Voordelen:**
- ✅ Zeer populair in Nederland
- ✅ Hoge engagement
- ✅ Betrouwbaar

**Nadelen:**
- ❌ Vereist WhatsApp Business API (kosten)
- ❌ Vereist backend service
- ❌ Complexe setup
- ❌ Contactpersoon moet WhatsApp hebben

**Geschikt voor:** ❌ Niet geschikt zonder backend

---

### 4. Push Notificaties (naar andere app)
**Hoe het werkt:**
- Contactpersoon moet ook de app installeren
- App verstuurt push notificaties naar andere gebruikers
- Via Firebase Cloud Messaging (FCM) of Apple Push Notification Service (APNs)

**Voordelen:**
- ✅ Volledig gratis
- ✅ Direct en betrouwbaar
- ✅ Geen backend nodig (FCM is gratis)
- ✅ Automatisch verzenden

**Nadelen:**
- ❌ Contactpersoon moet app installeren
- ❌ Niet praktisch voor deze use case
- ❌ Beperkt bereik

**Geschikt voor:** ❌ Niet geschikt - contactpersoon moet app hebben

---

### 5. Webhook/HTTP Requests
**Hoe het werkt:**
- Gebruiker configureert webhook URL (bijv. IFTTT, Zapier, Make.com)
- App verstuurt HTTP POST request naar webhook
- Webhook service verstuurt bericht (e-mail, SMS, etc.)

**Voordelen:**
- ✅ Flexibel (gebruiker kiest service)
- ✅ Geen backend nodig
- ✅ Automatisch verzenden

**Nadelen:**
- ⚠️ Gebruiker moet webhook service account hebben
- ⚠️ Complex voor eindgebruiker
- ⚠️ Afhankelijk van externe service

**Implementatie:**
- Flutter package: `http` of `dio`
- Webhook services: IFTTT (gratis), Zapier (betaald), Make.com

**Geschikt voor:** ⚠️ Te complex voor deze doelgroep

---

### 6. Signal (Messaging App)
**Hoe het werkt:**
- Vergelijkbaar met Telegram
- Gebruiker maakt Signal account
- App verstuurt berichten via Signal API

**Voordelen:**
- ✅ Veilig en privé
- ✅ Gratis

**Nadelen:**
- ⚠️ Contactpersoon moet Signal hebben
- ⚠️ Minder populair dan Telegram
- ⚠️ Complexere API

**Geschikt voor:** ⚠️ Alleen als contactpersoon Signal heeft

---

### 7. In-App Notificaties (voor gebruiker zelf)
**Hoe het werkt:**
- App toont notificaties binnen de app zelf
- Alleen zichtbaar voor de gebruiker
- Niet voor contactpersonen

**Voordelen:**
- ✅ Volledig gratis
- ✅ Geen setup nodig
- ✅ Direct zichtbaar

**Nadelen:**
- ❌ Niet voor contactpersonen
- ❌ Alleen zichtbaar als app open is

**Geschikt voor:** ⚠️ Alleen als reminder voor gebruiker zelf (niet voor contacten)

---

## Vergelijking Alternatieven

| Optie | Automatisch | Geen Backend | Geen Kosten Dev | Universeel | Eenvoudig |
|-------|-------------|-------------|-----------------|------------|-----------|
| **SMTP E-mail** | ✅ | ✅ | ✅ | ✅ | ✅ |
| SMS (Native) | ❌ | ✅ | ✅ | ✅ | ⚠️ |
| SMS (API) | ✅ | ❌ | ❌ | ✅ | ⚠️ |
| Telegram Bot | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |
| WhatsApp | ✅ | ❌ | ❌ | ⚠️ | ❌ |
| Push Notificaties | ✅ | ✅ | ✅ | ❌ | ⚠️ |
| Webhook | ✅ | ✅ | ✅ | ⚠️ | ❌ |
| Signal | ✅ | ✅ | ✅ | ❌ | ⚠️ |

---

## Aanbeveling: Combinatie van Opties

**Primaire optie: SMTP E-mail** (zoals eerder beschreven)
- Universeel, automatisch, geen backend nodig

**Secundaire optie (optioneel): SMS via Native Intent**
- Als fallback wanneer e-mail niet werkt
- Gebruiker opent SMS app en bevestigt verzending
- Geen extra kosten voor ontwikkelaar

**Implementatie combinatie:**
1. Probeer eerst automatisch e-mail te versturen via SMTP
2. Als e-mail faalt, toon optie om SMS te versturen (native intent)
3. Gebruiker bevestigt SMS verzending in SMS app

Dit geeft:
- Automatische e-mail (primair)
- SMS fallback (secundair, met gebruikersbevestiging)
- Geen backend nodig
- Geen kosten voor ontwikkelaar

---

---

## Opties wanneer Contactpersoon ook de App installeert 🎯

Als beide partijen (gebruiker en contactpersoon) de app hebben geïnstalleerd, zijn er veel betere opties beschikbaar:

### 1. Firebase Cloud Messaging (FCM) - Push Notificaties ⭐
**Hoe het werkt:**
- Elke gebruiker krijgt unieke FCM token bij installatie
- Gebruiker deelt zijn token met contactpersonen (of via e-mail/QR code)
- App verstuurt push notificatie direct naar contactpersoon's app
- Contactpersoon ontvangt notificatie op telefoon

**Voordelen:**
- ✅ Volledig gratis (Firebase gratis tier)
- ✅ Geen backend nodig (Firebase is de backend)
- ✅ Volledig automatisch verzenden
- ✅ Direct en betrouwbaar
- ✅ Werkt zelfs als app gesloten is
- ✅ Geen e-mailwachtwoord nodig
- ✅ Betere gebruikerservaring

**Nadelen:**
- ⚠️ Contactpersoon moet app installeren
- ⚠️ Beide gebruikers moeten FCM token delen
- ⚠️ Vereist Firebase project setup (gratis)

**Implementatie:**
- Flutter package: `firebase_messaging`
- Firebase project aanmaken (gratis)
- FCM tokens opslaan per gebruiker
- Berichten versturen via FCM API

**Geschikt voor:** ✅ **BESTE OPTIE** als contactpersoon app heeft

---

### 2. Firebase Realtime Database - In-App Messaging
**Hoe het werkt:**
- Berichten worden opgeslagen in Firebase Realtime Database
- Beide gebruikers lezen berichten uit database
- Real-time updates zonder polling
- Berichten blijven beschikbaar in app

**Voordelen:**
- ✅ Volledig gratis (Firebase gratis tier)
- ✅ Real-time synchronisatie
- ✅ Berichtgeschiedenis bewaren
- ✅ Werkt offline (sync bij verbinding)
- ✅ Geen e-mailwachtwoord nodig

**Nadelen:**
- ⚠️ Contactpersoon moet app installeren
- ⚠️ Vereist Firebase project setup
- ⚠️ Beide gebruikers moeten account hebben

**Implementatie:**
- Flutter package: `firebase_database`
- Firebase Realtime Database
- Gebruikers identificeren via e-mail of unieke ID

**Geschikt voor:** ✅ Goed voor berichtgeschiedenis en real-time updates

---

### 3. Firebase Firestore - Gestructureerde Berichten
**Hoe het werkt:**
- Vergelijkbaar met Realtime Database
- Maar met gestructureerde data (NoSQL)
- Betere query mogelijkheden
- Offline support

**Voordelen:**
- ✅ Volledig gratis (Firebase gratis tier)
- ✅ Gestructureerde data
- ✅ Krachtige queries
- ✅ Offline support
- ✅ Real-time updates

**Nadelen:**
- ⚠️ Contactpersoon moet app installeren
- ⚠️ Complexer dan Realtime Database
- ⚠️ Vereist Firebase project setup

**Implementatie:**
- Flutter package: `cloud_firestore`
- Firebase Firestore database

**Geschikt voor:** ✅ Als je complexere data structuur nodig hebt

---

### 4. Peer-to-Peer via WebRTC (Geavanceerd)
**Hoe het werkt:**
- Directe verbinding tussen twee apparaten
- Via WebRTC protocol
- Geen server nodig voor berichten

**Voordelen:**
- ✅ Volledig peer-to-peer
- ✅ Geen server nodig
- ✅ Zeer snel

**Nadelen:**
- ❌ Complexe implementatie
- ❌ Beide apparaten moeten online zijn
- ❌ NAT traversal problemen
- ❌ Niet geschikt voor deze app

**Geschikt voor:** ❌ Te complex voor deze use case

---

### 5. Hybride Aanpak: FCM + E-mail Fallback ⭐⭐⭐
**Hoe het werkt:**
- **Primair**: Probeer FCM push notificatie (als contactpersoon app heeft)
- **Fallback**: Stuur e-mail via SMTP (als contactpersoon geen app heeft)
- App detecteert automatisch of contactpersoon app heeft

**Voordelen:**
- ✅ Beste van beide werelden
- ✅ Werkt altijd (app of e-mail)
- ✅ Automatische fallback
- ✅ Geen verlies van berichten

**Implementatie:**
1. Check of contactpersoon FCM token heeft
2. Als ja: stuur FCM push notificatie
3. Als nee: stuur e-mail via SMTP
4. Optioneel: stuur beide (FCM + e-mail)

**Geschikt voor:** ✅ **BESTE OPTIE** - werkt voor iedereen

---

## Vergelijking: App-to-App vs E-mail

| Feature | FCM Push | SMTP E-mail | Hybride |
|---------|----------|-------------|---------|
| **Automatisch** | ✅ | ✅ | ✅ |
| **Geen Backend** | ⚠️ (Firebase) | ✅ | ⚠️ (Firebase) |
| **Geen Kosten Dev** | ✅ | ✅ | ✅ |
| **Universeel** | ❌ (app nodig) | ✅ | ✅ |
| **Snelheid** | ⚠️ (seconden) | ⚠️ (minuten) | ⚠️ (seconden) |
| **Betrouwbaarheid** | ✅ | ✅ | ✅✅ |
| **Setup Complexiteit** | ⚠️ | ✅ | ⚠️ |

---

## Aanbeveling: Hybride Aanpak

**Voor deze app: FCM Push Notificaties + SMTP E-mail Fallback**

**Waarom:**
1. **FCM voor contactpersonen met app**: Direct, snel, betere UX
2. **SMTP e-mail voor anderen**: Universeel, werkt altijd
3. **Automatische detectie**: App kiest beste methode
4. **Geen verlies**: Altijd een manier om contactpersoon te bereiken

**Implementatie strategie:**
1. Tijdens onboarding: vraag of contactpersoon app heeft
2. Als ja: vraag om FCM token of e-mailadres voor uitnodiging
3. Als nee: gebruik e-mailadres voor SMTP
4. Bij verzenden: probeer eerst FCM, dan e-mail

**Firebase Setup:**
- Firebase project aanmaken (gratis)
- Firebase Messaging configureren
- FCM tokens opslaan per contactpersoon
- Push notificaties versturen via FCM API

**Voordelen hybride:**
- ✅ Werkt voor iedereen (met of zonder app)
- ✅ Beste gebruikerservaring (FCM waar mogelijk)
- ✅ Betrouwbaar (e-mail als backup)
- ✅ Geen verlies van berichten

---

## Conclusie

**Beste optie voor deze app: Hybride Aanpak (FCM + SMTP)**

**Primair:**
- **FCM Push Notificaties** voor contactpersonen die app hebben
- Direct, snel, betere gebruikerservaring

**Secundair:**
- **SMTP E-mail** als fallback voor contactpersonen zonder app
- Universeel, werkt altijd

**Optionele aanvulling: SMS Native Intent als extra fallback**
- Wanneer e-mail niet werkt
- Gebruiker bevestigt SMS verzending
- Geen extra kosten voor ontwikkelaar

**Implementatie prioriteit:**
1. ✅ SMTP E-mail (werkt altijd)
2. ✅ FCM Push Notificaties (voor app gebruikers)
3. ⚠️ SMS Fallback (optioneel)
