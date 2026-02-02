# App Icoon Instructies

De app heeft een logo nodig met:
- Witte achtergrond (ronde cirkel)
- Groene cirkel in het midden (bijv. #4CAF50 of groen[700])
- Witte "OK" tekst op de groene cirkel
- Minimale resolutie: 1024x1024 pixels

## Android

1. Maak een icoon met:
   - Witte ronde achtergrond
   - Groene ronde cirkel in het midden (ongeveer 80% van de grootte)
   - Witte "OK" tekst op de groene cirkel
   - Minimale resolutie: 1024x1024 pixels

2. Plaats het icoon in:
   - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
   - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
   - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
   - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
   - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

3. Of gebruik een tool zoals:
   - https://www.appicon.co/
   - https://icon.kitchen/
   - Flutter package: `flutter_launcher_icons`

## iOS

1. Maak een icoon met dezelfde stijl (witte achtergrond met groene cirkel en witte OK)

2. Plaats in:
   - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

3. Vereiste formaten:
   - 20x20 (@2x, @3x)
   - 29x29 (@2x, @3x)
   - 40x40 (@2x, @3x)
   - 60x60 (@2x, @3x)
   - 1024x1024 (App Store)

## Snelle Setup met flutter_launcher_icons

Voeg toe aan `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
```

Maak een 1024x1024 PNG met witte achtergrond, groene cirkel in het midden en witte "OK" op de groene cirkel, plaats in `assets/icon/icon.png`, en run:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```
