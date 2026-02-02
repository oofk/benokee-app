# Domain Verificatie - Stap voor Stap

## 🎯 Wat je nu moet doen (in de browser)

### Stap 1: Domain Toevoegen in Resend
1. Je bent al ingelogd in Resend ✅
2. Ga naar: https://resend.com/domains
3. Klik op **"Add Domain"** of **"Create Domain"**
4. Voer in: `okerckhoff.nl`
5. Klik op **"Add"** of **"Create"**

### Stap 2: DNS Records Kopiëren
Resend toont nu de DNS records die je moet toevoegen:
- **SPF Record** (1 record)
- **DKIM Records** (meestal 2-3 records)
- **DMARC Record** (optioneel, maar aanbevolen)

**Kopieer alle records** - je hebt ze nodig voor de volgende stap.

### Stap 3: DNS Records Toevoegen aan je Domain Provider
Ga naar waar je `okerckhoff.nl` beheert (bijv. GoDaddy, Namecheap, Cloudflare):
1. Ga naar DNS Management / DNS Records
2. Voeg alle records toe die Resend heeft gegeven
3. Wacht 5-30 minuten op DNS propagatie

### Stap 4: Check Verificatie Status
1. Ga terug naar Resend dashboard: https://resend.com/domains
2. Check of `okerckhoff.nl` een **groene vinkje** heeft
3. Als het groen is → domain is geverifieerd! ✅

## 🚀 Zodra Domain Geverifieerd Is

**Laat me weten wanneer het domain geverifieerd is**, dan voer ik automatisch uit:
1. ✅ Code aanpassen naar `noreply@okerckhoff.nl`
2. ✅ Functions redeployen
3. ✅ Testen

Of voer zelf uit:
```powershell
cd C:\Users\olivi\cursor\benokee_app
.\deploy_after_verification.bat
```

## ⏱️ Tijd Schatting

- **Domain toevoegen**: 2 minuten
- **DNS records toevoegen**: 5-10 minuten
- **DNS propagatie**: 5-30 minuten
- **Code aanpassen + deployen**: 2 minuten (ik doe dit)

**Totaal: ~15-45 minuten**

## ❓ Hulp Nodig?

Als je hulp nodig hebt bij het toevoegen van DNS records, laat me weten:
- Welke domain provider gebruik je? (GoDaddy, Namecheap, Cloudflare, etc.)
- Ik kan specifieke instructies geven!
