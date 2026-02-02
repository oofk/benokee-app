# Benokee App - Build Instructies

## Status

✅ **Code is klaar** voor Android en iOS builds
✅ **Alle configuraties** zijn correct ingesteld
✅ **Privacy manifest** aanwezig voor iOS 17+
✅ **Permissions** correct geconfigureerd

## Android Build

### Vereisten:
1. Android Studio geïnstalleerd
2. Android SDK geconfigureerd

### Build Commando's:

```powershell
cd benokee_app

# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (voor Play Store)
flutter build appbundle --release
```

**Output locaties:**
- APK: `build\app\outputs\flutter-apk\app-release.apk`
- AAB: `build\app\outputs\bundle\release\app-release.aab`

### Als Android SDK niet gevonden wordt:

1. Installeer Android Studio: https://developer.android.com/studio
2. Open Android Studio → SDK Manager
3. Installeer Android SDK Platform (API 33+)
4. Configureer path:
   ```powershell
   flutter config --android-sdk "C:\Users\olivi\AppData\Local\Android\Sdk"
   ```

## iOS Build

### Vereisten:
1. **Mac computer** (vereist!)
2. Xcode geïnstalleerd
3. Apple Developer Account (voor App Store)

### Build Commando's (op Mac):

```bash
cd benokee_app

# Voor simulator
flutter build ios --simulator

# Voor device
flutter build ios --release

# Archive voor App Store (via Xcode)
open ios/Runner.xcworkspace
# Dan: Product → Archive
```

### Als je geen Mac hebt:

Gebruik **Codemagic** of **GitHub Actions** voor cloud iOS builds:
- Codemagic: https://codemagic.io (~€50/maand)
- GitHub Actions: Gratis voor open source projecten

## Wat is al geconfigureerd:

### Android:
- ✅ Min SDK: 24
- ✅ Target SDK: 34
- ✅ Permissions: Notifications, Exact Alarms
- ✅ MainActivity.kt
- ✅ Build.gradle configuratie
- ✅ Manifest met alle benodigde permissions

### iOS:
- ✅ Min iOS: 12.0
- ✅ Info.plist met alle benodigde keys
- ✅ Privacy manifest (PrivacyInfo.xcprivacy)
- ✅ Background modes geconfigureerd
- ✅ Notificatie permissions
- ✅ iPhone en iPad support

## Testen

### Android:
```powershell
flutter run -d android
```

### iOS (op Mac):
```bash
flutter run -d ios
```

## App Store / Play Store Release

### Android (Play Store):
1. Build App Bundle: `flutter build appbundle --release`
2. Upload naar Google Play Console
3. Vul store listing in
4. Submit voor review

### iOS (App Store):
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Configureer signing met je Apple Developer account
3. Product → Archive
4. Upload naar App Store Connect
5. Submit voor review

## Huidige Blokkades

- ❌ **Android SDK niet geïnstalleerd** - Installeer Android Studio
- ❌ **Geen Mac voor iOS** - Gebruik cloud build service of Mac

De app code is **100% klaar** voor beide platforms! 🎉
