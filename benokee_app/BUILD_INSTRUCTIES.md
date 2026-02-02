# Build Instructies voor Android en iOS

## Android Build

### Vereisten:
1. **Android Studio** geïnstalleerd
2. **Android SDK** geconfigureerd
3. **Java JDK** geïnstalleerd

### Stappen:

1. **Installeer Android Studio** (als nog niet gedaan):
   - Download: https://developer.android.com/studio
   - Installeer en open Android Studio
   - Ga naar: More Actions → SDK Manager
   - Installeer:
     - Android SDK Platform-Tools
     - Android SDK Build-Tools
     - Android SDK Platform (API 33 of hoger)

2. **Configureer Android SDK path**:
   ```powershell
   flutter config --android-sdk "C:\Users\olivi\AppData\Local\Android\Sdk"
   ```
   (Pas het pad aan naar waar jouw Android SDK staat)

3. **Build Android APK**:
   ```powershell
   cd benokee_app
   flutter build apk --release
   ```
   
   APK wordt gemaakt in: `build\app\outputs\flutter-apk\app-release.apk`

4. **Build Android App Bundle** (voor Play Store):
   ```powershell
   flutter build appbundle --release
   ```
   
   AAB wordt gemaakt in: `build\app\outputs\bundle\release\app-release.aab`

## iOS Build

### Vereisten:
1. **Mac computer** (vereist voor iOS builds)
2. **Xcode** geïnstalleerd
3. **Apple Developer Account** (voor App Store release)

### Stappen (op Mac):

1. **Open project in Xcode**:
   ```bash
   cd benokee_app
   open ios/Runner.xcworkspace
   ```

2. **Configureer signing**:
   - Selecteer Runner target
   - Ga naar "Signing & Capabilities"
   - Selecteer je Team (Apple Developer account)
   - Xcode genereert automatisch provisioning profile

3. **Build voor simulator**:
   ```bash
   flutter build ios --simulator
   ```

4. **Build voor device**:
   ```bash
   flutter build ios --release
   ```

5. **Archive voor App Store**:
   - Open Xcode
   - Product → Archive
   - Upload naar App Store Connect

## Alternatief: Cloud Build Services

Als je geen Mac hebt voor iOS builds:

### Codemagic (Aanbevolen):
- Website: https://codemagic.io
- Kosten: ~€50/maand
- Automatische iOS builds zonder Mac
- Integreert met GitHub/GitLab

### GitHub Actions:
- Gratis voor open source
- Kan iOS builds doen op Mac runners
- Vereist GitHub repository

## Huidige Status

- ✅ **Android configuratie**: Compleet (vereist Android SDK installatie)
- ✅ **iOS configuratie**: Compleet (vereist Mac + Xcode)
- ✅ **Privacy manifest**: Aanwezig voor iOS 17+
- ✅ **Permissions**: Correct geconfigureerd
- ✅ **Code**: Klaar voor beide platforms

## Quick Start

### Voor Android (als SDK geïnstalleerd is):
```powershell
cd benokee_app
flutter build apk --release
```

### Voor iOS (op Mac):
```bash
cd benokee_app
flutter build ios --release
```

## Troubleshooting

### Android SDK niet gevonden:
- Installeer Android Studio
- Run `flutter doctor --android-licenses` om licenties te accepteren
- Zet ANDROID_HOME environment variable

### iOS build faalt:
- Controleer of Xcode geïnstalleerd is: `xcode-select --print-path`
- Run `pod install` in `ios/` directory
- Controleer signing in Xcode
