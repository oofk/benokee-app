# Domain Verificatie Stappen - Okerckhoff.nl

## 📋 Stap-voor-stap Instructies

### Stap 1: Ga naar Resend Dashboard
1. Open: https://resend.com/domains
2. Log in met je Resend account

### Stap 2: Voeg Domain Toe
1. Klik op **"Add Domain"** of **"Create Domain"**
2. Voer in: `okerckhoff.nl`
3. Klik op **"Add"**

### Stap 3: Voeg DNS Records Toe
Resend geeft je de volgende DNS records die je moet toevoegen aan je domain:

#### SPF Record
```
Type: TXT
Name: @ (of okerckhoff.nl)
Value: [Resend geeft je de exacte waarde]
TTL: 3600 (of automatisch)
```

#### DKIM Records
Resend geeft je **meerdere DKIM records** (meestal 2-3):
```
Type: TXT
Name: [Resend geeft je de naam, bijv. resend._domainkey]
Value: [Resend geeft je de waarde]
TTL: 3600
```

#### DMARC Record (Optioneel, maar aanbevolen)
```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=none; rua=mailto:resend@okerckhoff.nl
TTL: 3600
```

### Stap 4: Wacht op Verificatie
- DNS records kunnen 5-30 minuten duren om te propageren
- Resend controleert automatisch of de records correct zijn
- Je ziet in het dashboard wanneer het domain geverifieerd is (groene vinkje)

### Stap 5: Update Code
Nadat het domain geverifieerd is, pas `functions/index.js` aan:

**Zoek deze regels:**
```javascript
from: 'Benokee <onboarding@resend.dev>',
```

**Verander naar:**
```javascript
from: 'Benokee <noreply@okerckhoff.nl>',
```

**Of als je een subdomain wilt:**
```javascript
from: 'Benokee <noreply@mail.okerckhoff.nl>',
```

### Stap 6: Redeploy Functions
```powershell
cd C:\Users\olivi\cursor\benokee_app
firebase deploy --only functions
```

### Stap 7: Test
1. Voer onboarding uit in de app
2. Gebruik e-mail: `test_benokee@okerckhoff.nl`
3. Check of e-mail aankomt

## ⚠️ Belangrijk

- **DNS propagatie** kan 5-30 minuten duren
- **Check Resend dashboard** voor verificatie status
- **Gebruik exacte waarden** die Resend geeft voor DNS records
- **Test eerst** met `resend@okerckhoff.nl` om te bevestigen dat setup werkt

## 🔍 Waar Voeg Je DNS Records Toe?

Dit hangt af van waar je domain geregistreerd is:
- **GoDaddy**: DNS Management → Records
- **Namecheap**: Advanced DNS
- **Cloudflare**: DNS → Records
- **Andere providers**: Zoek naar "DNS Management" of "DNS Records"

## ✅ Verificatie Checklist

- [ ] Domain toegevoegd in Resend
- [ ] SPF record toegevoegd
- [ ] DKIM records toegevoegd (alle)
- [ ] DMARC record toegevoegd (optioneel)
- [ ] Wacht 5-30 minuten
- [ ] Check Resend dashboard - domain geverifieerd?
- [ ] Code aangepast naar eigen domain
- [ ] Functions gedeployed
- [ ] Test e-mail verstuurd en ontvangen
