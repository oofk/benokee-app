# App Deploy Status

## 📱 Huidige Status

**Device**: HA1EYG0B is **OFFLINE**

## 🔄 Automatische Deploy

Er draait een script dat:
1. ✅ Wacht tot het Android device online komt
2. ✅ Detecteert wanneer het device verbonden is
3. ✅ Deployt automatisch de app

## 📋 Wat Wordt Gedeployed

De laatste wijzigingen:
- ✅ **App versie nummer** zichtbaar in instellingen (onderaan)
- ✅ Dialog fix (sluit automatisch na check-in)
- ✅ Betere error handling voor e-mails
- ✅ Verbeterde logging

## 🔌 Device Verbinden

**Zorg dat**:
1. ✅ Android device is aangesloten via USB
2. ✅ Device is ontgrendeld
3. ✅ USB debugging is aan (Developer options)
4. ✅ "Allow USB debugging" popup is geaccepteerd
5. ✅ USB kabel is goed aangesloten

## ⏱️ Wachten

Het script wacht maximaal **60 seconden** (12 pogingen × 5 seconden).

**Zodra het device online komt**, wordt de app automatisch gedeployed!

## 📊 Versie Info

**Huidige versie**: `1.0.0+1`
**Zichtbaar in**: Instellingen → onderaan als "Benokee v1.0.0+1"

## 🚀 Handmatig Deployen

Als je handmatig wilt deployen:

```powershell
cd C:\Users\olivi\cursor\benokee_app
flutter devices
# Check of HA1EYG0B online is
flutter run -d HA1EYG0B
```

Of gebruik het batch script:
```powershell
.\deploy_android.bat
```
