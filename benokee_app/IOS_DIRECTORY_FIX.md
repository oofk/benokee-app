# iOS Directory Fix - Dubbele Directory

## Probleem
```
pwd geeft: /users/olivier/downloads/benokee_app/benokee_app
pubspec.yaml staat in de directory
```

Je staat in een **subdirectory**! De `pubspec.yaml` staat waarschijnlijk één niveau hoger.

---

## Oplossing: Ga Één Niveau Omhoog

### Stap 1: Check Waar pubspec.yaml Staat

```bash
# Check huidige directory
pwd
# Geeft: /users/olivier/downloads/benokee_app/benokee_app

# Check of pubspec.yaml hier is
ls -la pubspec.yaml
# Als dit NIET werkt, staat het één niveau hoger

# Check één niveau hoger
ls -la ../pubspec.yaml
# Als dit WEL werkt, moet je één niveau omhoog
```

### Stap 2: Ga Naar Project Root

```bash
# Ga één niveau omhoog
cd ..

# Check of je nu in de juiste directory bent
pwd
# Moet zijn: /users/olivier/downloads/benokee_app

# Verifieer pubspec.yaml
ls -la pubspec.yaml
# Moet bestand tonen
```

### Stap 3: Genereer iOS Project

```bash
# Nu ben je in de juiste directory
flutter create --platforms=ios .
```

---

## Complete Fix Script

Kopieer en plak dit in Terminal op je Mac:

```bash
#!/bin/bash

echo "📍 Current directory:"
pwd

echo ""
echo "🔍 Checking for pubspec.yaml..."

# Check huidige directory
if [ -f "pubspec.yaml" ]; then
    echo "✅ pubspec.yaml found in current directory"
    PROJECT_DIR=$(pwd)
elif [ -f "../pubspec.yaml" ]; then
    echo "⚠️  pubspec.yaml found one level up"
    echo "   Navigating up one level..."
    cd ..
    PROJECT_DIR=$(pwd)
    echo "   Now in: $PROJECT_DIR"
else
    echo "❌ pubspec.yaml not found!"
    echo "   Please navigate to project root manually"
    exit 1
fi

echo ""
echo "📦 Verifying project structure..."
if [ -f "pubspec.yaml" ] && [ -d "lib" ]; then
    echo "✅ Project structure looks correct"
    echo "   Project root: $PROJECT_DIR"
else
    echo "❌ Project structure incomplete"
    exit 1
fi

echo ""
echo "🧹 Cleaning Flutter..."
flutter clean

echo ""
echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "📱 Generating iOS project..."
echo "   Command: flutter create --platforms=ios ."
flutter create --platforms=ios .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ iOS project generated!"
    
    echo ""
    echo "📦 Installing CocoaPods..."
    cd ios
    pod install
    cd ..
    
    echo ""
    echo "✅ Verifying..."
    if [ -d "ios/Runner.xcodeproj" ]; then
        echo "   ✅ ios/Runner.xcodeproj exists"
    fi
    if [ -d "ios/Runner.xcworkspace" ]; then
        echo "   ✅ ios/Runner.xcworkspace exists"
    fi
    
    echo ""
    echo "🎉 Success! You can now:"
    echo "   open ios/Runner.xcworkspace"
else
    echo ""
    echo "❌ Failed! Check error above"
    exit 1
fi
```

---

## Handmatige Stappen

### Stap 1: Ga Één Niveau Omhoog

```bash
# Je bent nu hier:
# /users/olivier/downloads/benokee_app/benokee_app

# Ga één niveau omhoog
cd ..

# Nu ben je hier:
# /users/olivier/downloads/benokee_app
```

### Stap 2: Verifieer

```bash
# Check directory
pwd
# Moet zijn: /users/olivier/downloads/benokee_app

# Check pubspec.yaml
ls -la pubspec.yaml
# Moet bestand tonen

# Check lib directory
ls -la lib/
# Moet directory tonen met main.dart
```

### Stap 3: Genereer iOS Project

```bash
# Nu in de juiste directory
flutter create --platforms=ios .
```

---

## Als Er Twee benokee_app Directories Zijn

Als je structuur er zo uitziet:
```
benokee_app/
  benokee_app/    ← Je bent hier (verkeerd!)
    ...
  pubspec.yaml    ← Hier staat het (correct!)
  lib/
  ...
```

**Oplossing:**
```bash
# Ga één niveau omhoog
cd /users/olivier/downloads/benokee_app

# Dan create
flutter create --platforms=ios .
```

---

## Snelle Fix (Kopieer Precies)

```bash
# Ga naar project root
cd /users/olivier/downloads/benokee_app

# Verifieer
pwd
ls pubspec.yaml

# Genereer iOS project
flutter create --platforms=ios .

# CocoaPods
cd ios && pod install && cd ..
```

---

## Verificatie

Na `flutter create`:

```bash
# Check project bestaat
ls -la ios/Runner.xcodeproj

# Check je bent in juiste directory
pwd
# Moet zijn: /users/olivier/downloads/benokee_app
# NIET: /users/olivier/downloads/benokee_app/benokee_app
```

---

**Ga één niveau omhoog met `cd ..` en probeer dan `flutter create --platforms=ios .`**
