# Volgende Stappen voor Firebase Setup

## ✅ Wat is al gedaan:

1. ✅ **Stap 1-3**: Firebase project en Android app toegevoegd
2. ✅ **Stap 4**: Android configuratie (Google Services plugin)
3. ✅ **Stap 6**: Flutter dependencies geïnstalleerd (`flutter pub get`)
4. ✅ **Resend API key**: Opgeslagen in code (tijdelijk, moet naar Firebase config)

## 🔧 Wat je nog moet doen:

### Stap 1: Installeer Node.js en npm

1. Download Node.js van [nodejs.org](https://nodejs.org/) (LTS versie)
2. Installeer Node.js (npm wordt automatisch geïnstalleerd)
3. Verifieer installatie:
   ```powershell
   node --version
   npm --version
   ```

### Stap 2: Installeer Firebase CLI

```powershell
npm install -g firebase-tools
```

### Stap 3: Login op Firebase

```powershell
firebase login
```

### Stap 4: Initialiseer Firebase Functions (als nog niet gedaan)

```powershell
cd C:\Users\olivi\cursor\benokee_app
firebase init functions
```

Selecteer:
- **Use an existing project**: Selecteer je Firebase project
- **Language**: JavaScript
- **ESLint**: Yes
- **Install dependencies**: Yes

### Stap 5: Installeer Functions Dependencies

```powershell
cd functions
npm install
```

### Stap 6: Configureer Resend API Key

**Optie A: Via Firebase CLI (Aanbevolen)**
```powershell
cd C:\Users\olivi\cursor\benokee_app
firebase functions:config:set resend.api_key="re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL"
```

**Optie B: Via Firebase Console**
1. Ga naar [Firebase Console](https://console.firebase.google.com/)
2. Selecteer je project
3. Ga naar **Functions** > **Configuration**
4. Klik op **Add variable**
5. Key: `RESEND_API_KEY`
6. Value: `re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL`
7. Klik **Save**

### Stap 7: Deploy Firebase Functions

```powershell
cd C:\Users\olivi\cursor\benokee_app
firebase deploy --only functions
```

### Stap 8: Verwijder API Key uit Code (Security)

Na het deployen, verwijder de hardcoded API key uit `functions/index.js`:

```javascript
// Verwijder deze regel:
|| 're_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL'
```

Laat alleen staan:
```javascript
const resend = new Resend(process.env.RESEND_API_KEY || functions.config().resend?.api_key);
```

### Stap 9: Test de App

1. Build en run de app:
   ```powershell
   flutter run
   ```

2. Test introductie e-mail versturen tijdens onboarding

## 📋 Checklist

- [ ] Node.js en npm geïnstalleerd
- [ ] Firebase CLI geïnstalleerd
- [ ] Firebase login gedaan
- [ ] Firebase Functions geïnitialiseerd
- [ ] Dependencies geïnstalleerd (`npm install` in functions folder)
- [ ] Resend API key geconfigureerd in Firebase
- [ ] Firebase Functions gedeployed
- [ ] API key verwijderd uit code
- [ ] App getest

## ⚠️ Belangrijke Notities

1. **API Key Security**: De API key staat nu tijdelijk in de code voor development. Verwijder deze na het configureren in Firebase!

2. **Firebase Project**: Zorg dat je het juiste Firebase project selecteert (benokee-app)

3. **E-mail Domain**: Voor productie moet je je domain verifiëren in Resend. Voor testen kun je `onboarding@resend.dev` gebruiken.

4. **Gratis Limieten**:
   - Resend: 3.000 e-mails/maand
   - Firebase Functions: 2 miljoen invocations/maand
   - Ruim voldoende voor deze app

## 🆘 Troubleshooting

### "npm is not recognized"
- Installeer Node.js van nodejs.org
- Herstart PowerShell na installatie

### "firebase: command not found"
- Installeer Firebase CLI: `npm install -g firebase-tools`
- Herstart PowerShell

### "Functions deployment failed"
- Check of je ingelogd bent: `firebase login`
- Check of je in het juiste project zit: `firebase projects:list`
- Check of API key correct is geconfigureerd

### "Resend API key invalid"
- Check of de API key correct is gekopieerd
- Check of de key is ingesteld in Firebase Functions config
