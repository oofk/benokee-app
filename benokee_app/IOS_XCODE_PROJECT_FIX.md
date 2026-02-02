# iOS Xcode Project Fix

## Probleem
```
unable to find the xcode project '/....ios/runner.xcodeproj' for the target pods runner
```

Het Xcode project (`.xcodeproj`) ontbreekt. Dit moet worden gegenereerd door Flutter.

---

## Oplossing: Genereer iOS Project

### Stap 1: Flutter Dependencies Installeren

```bash
cd /pad/naar/benokee_app
flutter pub get
```

### Stap 2: Genereer iOS Project

Flutter genereert automatisch het Xcode project wanneer je het iOS platform build. Voer uit:

```bash
# Optie A: Via Flutter create (hergenereert iOS platform)
flutter create --platforms=ios .

# OF

# Optie B: Via Flutter build (genereert automatisch)
flutter build ios --no-codesign
```

**Let op:** `flutter create` kan bestaande bestanden overschrijven. Maak eerst een backup als je twijfelt.

### Stap 3: Verifieer Project Bestaat

```bash
ls -la ios/Runner.xcodeproj
ls -la ios/Runner.xcworkspace
```

Beide moeten nu bestaan.

### Stap 4: CocoaPods Installeren

```bash
cd ios
pod install
cd ..
```

---

## Alternatieve Methode: Handmatig Project Genereren

Als bovenstaande niet werkt:

### Stap 1: Clean Flutter

```bash
cd /pad/naar/benokee_app
flutter clean
```

### Stap 2: Hercreate iOS Platform

```bash
# Verwijder iOS directory (maak eerst backup!)
rm -rf ios

# Hercreate iOS platform
flutter create --platforms=ios .

# Dit genereert een nieuwe ios/ directory met alle benodigde bestanden
```

### Stap 3: Herstel Configuraties

Na `flutter create` moet je mogelijk deze bestanden opnieuw configureren:
- `ios/Runner/Info.plist` - Notificatie permissions
- `ios/PrivacyInfo.xcprivacy` - Privacy manifest
- `ios/Podfile` - CocoaPods configuratie

---

## Snelle Fix (Aanbevolen)

Kopieer en plak dit in Terminal op je Mac:

```bash
cd /pad/naar/benokee_app

# Clean
flutter clean

# Dependencies
flutter pub get

# Genereer iOS project (dit maakt .xcodeproj aan)
flutter create --platforms=ios .

# Installeer CocoaPods dependencies
cd ios
pod install
cd ..

# Verifieer
ls -la ios/Runner.xcodeproj
ls -la ios/Runner.xcworkspace
```

---

## Troubleshooting

### Probleem: "flutter create overwrites files"

**Oplossing:**
```bash
# Maak backup eerst
cp -r ios ios_backup

# Dan flutter create
flutter create --platforms=ios .
```

### Probleem: "Pod install still fails"

**Oplossing:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

### Probleem: "Xcode project still not found"

**Oplossing:**
1. Check of je in de juiste directory bent: `pwd`
2. Check of Flutter correct is geïnstalleerd: `flutter doctor`
3. Probeer handmatig:
   ```bash
   flutter build ios --no-codesign
   ```

---

## Wat wordt gegenereerd

Na `flutter create --platforms=ios .` zou je moeten hebben:

```
ios/
├── Runner.xcodeproj/          ← Xcode project
├── Runner.xcworkspace/         ← Workspace (na pod install)
├── Podfile                     ← CocoaPods config
├── Runner/
│   ├── Info.plist
│   ├── AppDelegate.swift
│   └── ...
└── Flutter/
    └── Generated.xcconfig
```

---

## Belangrijk

**Na `flutter create`:**
- Je moet mogelijk `Info.plist` opnieuw configureren (notificaties, privacy)
- Je moet mogelijk `PrivacyInfo.xcprivacy` opnieuw toevoegen
- Je moet `pod install` uitvoeren om workspace te maken

---

## Volgende Stappen

Na succesvolle generatie:

1. **Open workspace:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configureer signing** in Xcode

3. **Build en run**

---

**Probeer eerst: `flutter create --platforms=ios .` in de project root!**
