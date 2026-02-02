# iOS Project Genereren - Complete Fix

## Probleem
```
warning building for device with codesigning disabled.
expected ios/runner.xcodeproj but this file is missing.
application not configured for ios
```

Het iOS Xcode project ontbreekt volledig. Dit moet worden gegenereerd.

---

## Oplossing: Genereer iOS Project

### Stap 1: Verifieer Flutter Setup

```bash
# Check Flutter installatie
flutter doctor

# Check of je in de juiste directory bent
pwd
# Moet eindigen op: benokee_app
```

### Stap 2: Clean Project

```bash
cd /pad/naar/benokee_app
flutter clean
```

### Stap 3: Genereer iOS Platform

**BELANGRIJK:** Dit moet op een Mac worden uitgevoerd!

**⚠️ Let op de correcte syntax:**
- `--platforms` (met 's', niet `--plattform` of `--platform`)
- `.` aan het einde (huidige directory)

```bash
# Genereer iOS project (CORRECTE SYNTAX)
flutter create --platforms=ios .

# Dit commando:
# - Genereert ios/Runner.xcodeproj
# - Genereert ios/Podfile
# - Genereert alle benodigde iOS bestanden
```

**Veelgemaakte fouten:**
- ❌ `flutter create --plattform=ios .` (typfout: dubbele 't')
- ❌ `flutter create --platform=ios .` (geen 's')
- ❌ `flutter create --platforms=ios` (geen output directory)
- ✅ `flutter create --platforms=ios .` (CORRECT)

### Stap 4: Herstel Configuraties

Na `flutter create` moet je deze bestanden mogelijk opnieuw configureren:

#### 4.1 Info.plist - Notificatie Permissions

Open `ios/Runner/Info.plist` en voeg toe (als ontbreekt):

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Benokee gebruikt notificaties om je te herinneren aan je periodieke check-ins voor je veiligheid.</string>
```

#### 4.2 PrivacyInfo.xcprivacy

Zorg dat `ios/PrivacyInfo.xcprivacy` bestaat (zie bestaande versie).

#### 4.3 Podfile

De Podfile wordt automatisch gegenereerd, maar controleer of deze correct is.

### Stap 5: CocoaPods Installeren

```bash
cd ios
pod install
cd ..
```

### Stap 6: Verifieer

```bash
# Check of project bestaat
ls -la ios/Runner.xcodeproj
ls -la ios/Runner.xcworkspace

# Beide moeten bestaan
```

---

## Complete Fix Script

Kopieer en plak dit in Terminal op je Mac:

```bash
#!/bin/bash

# Navigeer naar project
cd /pad/naar/benokee_app

echo "🧹 Cleaning Flutter..."
flutter clean

echo "📦 Installing dependencies..."
flutter pub get

echo "📱 Generating iOS project..."
flutter create --platforms=ios .

echo "📦 Installing CocoaPods dependencies..."
cd ios
pod install
cd ..

echo "✅ Verifying..."
if [ -d "ios/Runner.xcodeproj" ]; then
    echo "✅ Xcode project generated successfully!"
    echo "✅ Location: ios/Runner.xcodeproj"
else
    echo "❌ Xcode project still missing. Check errors above."
    exit 1
fi

if [ -d "ios/Runner.xcworkspace" ]; then
    echo "✅ Workspace generated successfully!"
    echo "✅ Location: ios/Runner.xcworkspace"
else
    echo "⚠️  Workspace missing. Run 'pod install' in ios/ directory."
fi

echo ""
echo "🎉 Done! You can now:"
echo "   open ios/Runner.xcworkspace"
```

---

## Als flutter create niet werkt

### Alternatief: Handmatig Project Aanmaken

Als `flutter create` faalt, kun je het project handmatig aanmaken:

1. **Open Xcode**
2. **File** > **New** > **Project**
3. Kies **iOS** > **App**
4. Configureer:
   - Product Name: `Runner`
   - Organization Identifier: `com.benokee.app`
   - Language: **Swift**
   - Interface: **Storyboard**
5. Sla op in `benokee_app/ios/` directory
6. Voeg Flutter integratie toe (complex, zie Flutter docs)

**Aanbevolen:** Gebruik `flutter create` in plaats van handmatig.

---

## Troubleshooting

### Probleem: "flutter create overwrites my files"

**Oplossing:**
```bash
# Maak backup
cp -r ios ios_backup

# Dan create
flutter create --platforms=ios .

# Herstel belangrijke bestanden uit backup:
cp ios_backup/Runner/Info.plist ios/Runner/Info.plist
cp ios_backup/PrivacyInfo.xcprivacy ios/PrivacyInfo.xcprivacy
```

### Probleem: "Command not found: flutter"

**Oplossing:**
- Zie `FLUTTER_PATH_MAC.md` voor PATH fix
- Of gebruik volledig pad: `/pad/naar/flutter/bin/flutter create`

### Probleem: "No such file or directory"

**Oplossing:**
```bash
# Check of je in de juiste directory bent
pwd
# Moet eindigen op: benokee_app

# Check of project bestaat
ls -la pubspec.yaml
# Moet bestand tonen
```

### Probleem: "Platform ios not found"

**Oplossing:**
```bash
# Check Flutter versie
flutter --version

# Update Flutter
flutter upgrade

# Probeer opnieuw
flutter create --platforms=ios .
```

---

## Verificatie Checklist

Na `flutter create` en `pod install`:

- [ ] `ios/Runner.xcodeproj/` bestaat
- [ ] `ios/Runner.xcworkspace/` bestaat (na pod install)
- [ ] `ios/Podfile` bestaat
- [ ] `ios/Podfile.lock` bestaat (na pod install)
- [ ] `ios/Pods/` directory bestaat (na pod install)
- [ ] `ios/Runner/Info.plist` bestaat
- [ ] `ios/Flutter/Generated.xcconfig` bestaat

---

## Volgende Stappen

Na succesvolle generatie:

1. **Open workspace:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configureer in Xcode:**
   - Bundle Identifier: `com.jouwnaam.benokee` (uniek maken)
   - Team: Selecteer je Apple Developer account
   - Signing: Automatically manage signing

3. **Build:**
   ```bash
   flutter build ios --no-codesign
   # OF via Xcode: Product > Build
   ```

---

## Belangrijk

- ✅ `flutter create` moet worden uitgevoerd op een **Mac**
- ✅ Zorg dat Flutter correct is geïnstalleerd (`flutter doctor`)
- ✅ Na `flutter create` moet je `pod install` uitvoeren
- ✅ Open altijd `.xcworkspace`, niet `.xcodeproj`

---

**Voer uit op je Mac: `flutter create --platforms=ios .` in de project root!**
