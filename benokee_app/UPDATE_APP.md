# App Bijwerken op Android Device

## ⚠️ Device Offline

Het Android device (HA1EYG0B) is momenteel **offline**.

## 📱 Device Verbinden

### Stap 1: Verbind Device via USB
1. Sluit het Android device aan via USB
2. Zorg dat USB debugging aan staat
3. Accepteer de "Allow USB debugging" popup op het device

### Stap 2: Check Device Status
```powershell
cd C:\Users\olivi\cursor\benokee_app
flutter devices
```

Je zou moeten zien:
```
HA1EYG0B • android • ... • Device is online
```

### Stap 3: Deploy App
```powershell
flutter run -d HA1EYG0B
```

Of gebruik het batch script:
```powershell
.\deploy_android.bat
```

## 🔄 Wat is Veranderd

De laatste code changes die gedeployed moeten worden:
- ✅ Dialog fix (sluit nu automatisch)
- ✅ Betere error handling voor e-mails
- ✅ Verbeterde logging

## ⚡ Snelle Deploy

Zodra het device online is, wordt de app automatisch gedeployed.

**Wacht op**: Device komt online...
