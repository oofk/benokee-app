# Firebase Blaze Plan - Kosten Uitleg

## ✅ Blaze Plan is GRATIS (binnen limieten)

Het Blaze plan heeft een **gratis tier** - je betaalt alleen voor gebruik **BOVEN** de gratis limieten.

## 💰 Gratis Limieten (per maand)

### Firebase Functions
- ✅ **2 miljoen invocations** - GRATIS
- ✅ **400.000 GB-seconden** compute tijd - GRATIS
- ✅ **200.000 CPU-seconden** - GRATIS
- ✅ **5 GB uitgaand verkeer** - GRATIS

### Resend E-mail
- ✅ **3.000 e-mails** - GRATIS

## 📊 Kosten Schatting voor Benokee App

### Scenario 1: Kleine app (10 gebruikers)
- Functions invocations: ~300/maand (check-ins, e-mails)
- E-mails: ~100/maand
- **Kosten: €0,00** ✅

### Scenario 2: Middelgrote app (100 gebruikers)
- Functions invocations: ~3.000/maand
- E-mails: ~1.000/maand
- **Kosten: €0,00** ✅

### Scenario 3: Grote app (1.000 gebruikers)
- Functions invocations: ~30.000/maand
- E-mails: ~10.000/maand
- **Kosten: €0,00** ✅ (nog steeds binnen gratis tier)

### Scenario 4: Zeer grote app (10.000 gebruikers)
- Functions invocations: ~300.000/maand
- E-mails: ~100.000/maand
- **Kosten: €0,00** ✅ (nog steeds binnen gratis tier)

### Scenario 5: Extreem groot (100.000 gebruikers)
- Functions invocations: ~3.000.000/maand
- E-mails: ~1.000.000/maand
- **Kosten: ~€5-10/maand** (boven gratis tier)

## 💡 Wanneer Betaal Je?

Je betaalt alleen als je **BOVEN** de gratis limieten gaat:

### Functions Kosten (boven 2 miljoen/maand)
- €0,40 per 1 miljoen invocations
- Voorbeeld: 3 miljoen invocations = €0,40

### E-mail Kosten (boven 3.000/maand)
- Resend: €20/maand voor 50.000 e-mails
- Of gebruik gratis alternatief (zie hieronder)

## 🎯 Conclusie

**Voor deze app: Volledig GRATIS** ✅

- Je hebt 2 miljoen function calls/maand gratis
- Je hebt 3.000 e-mails/maand gratis
- Voor een check-in app is dit ruim voldoende
- Zelfs met 1.000+ gebruikers blijft het gratis

## ⚠️ Budget Alert (Optioneel)

Je kunt een **budget alert** instellen in Firebase:
1. Ga naar Firebase Console > Usage and Billing
2. Stel een budget alert in (bijv. €5/maand)
3. Krijg een waarschuwing als je boven budget gaat

## 🔄 Alternatieven (Als je echt geen Blaze wilt)

### Optie 1: Gebruik alleen Resend (zonder Firebase Functions)
- Resend heeft gratis tier (3.000 e-mails/maand)
- Maar dan moet je een andere manier vinden om e-mails te versturen
- **Niet aanbevolen** - Firebase Functions maakt het veel makkelijker

### Optie 2: Eigen Backend Server
- Host je eigen server (bijv. Heroku, Railway, Render)
- **Kosten: €5-10/maand** (meer dan Blaze gratis tier)
- **Niet aanbevolen** - meer werk, meer kosten

### Optie 3: Serverless zonder Firebase
- Gebruik Vercel/Netlify Functions
- **Kosten: Gratis tier** (maar minder features)
- **Niet aanbevolen** - Firebase is beter geïntegreerd

## ✅ Aanbeveling

**Gebruik Blaze Plan** - Het is gratis voor jouw use case en je betaalt alleen als je echt groot wordt (wat een goed probleem is!).

## 📝 Budget Monitoring

Firebase toont altijd je gebruik en kosten:
- Firebase Console > Usage and Billing
- Je ziet precies hoeveel je gebruikt
- Je ziet precies wat het kost (meestal €0,00)

## 🎓 Meer Info

- [Firebase Pricing](https://firebase.google.com/pricing)
- [Cloud Functions Pricing](https://cloud.google.com/functions/pricing)
- [Resend Pricing](https://resend.com/pricing)
