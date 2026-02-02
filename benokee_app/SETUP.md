# Benokee App - Setup Instructies

## Vereisten

1. **Flutter SDK**: Installeer Flutter vanaf https://flutter.dev/docs/get-started/install
2. **Android Studio** (voor Android development) of **Xcode** (voor iOS, alleen op Mac)
3. **VS Code** of **Android Studio** als IDE

## Installatie Stappen

### 1. Flutter Installatie Verifiëren

```bash
flutter doctor
```

Zorg dat alle checks groen zijn (of geel voor optionele items).

### 2. Dependencies Installeren

```bash
cd benokee_app
flutter pub get
```

### 3. App Icoon Toevoegen

Zie `APP_ICON_INSTRUCTIES.md` voor details. Je hebt een ronde groene knop met witte "OK" nodig.

### 4. Testen op Emulator/Device

#### Android:
```bash
# Start Android emulator of verbind Android device
flutter run
```

#### iOS (alleen op Mac):
```bash
# Start iOS simulator of verbind iPhone
flutter run
```

## Build voor Release

### Android APK
```bash
flutter build apk
```
APK wordt gemaakt in: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (voor Play Store)
```bash
flutter build appbundle
```

### iOS (vereist Mac + Xcode)
```bash
flutter build ios
```
Open daarna Xcode om te archiveren en naar App Store te uploaden.

## Permissions

### Android
De app vraagt automatisch om:
- Notificaties (Android 13+)
- Exact alarms (Android 12+)
- SMS (alleen voor alerts)

### iOS
De app vraagt automatisch om:
- Notificaties
- Background modes worden automatisch geconfigureerd

## Troubleshooting

### Notificaties werken niet
1. Controleer of notificatie permissions zijn verleend
2. Op Android: Controleer of exact alarms permission is verleend
3. Test met `flutter run` en check logs

### SMS werkt niet (Android)
1. Controleer SMS permission
2. Test op echt device (emulator ondersteunt geen SMS)
3. Controleer of nummer correct is geformatteerd (+31...)

### App crasht bij start
1. Run `flutter clean`
2. Run `flutter pub get`
3. Herstart app

## Test Checklist

- [ ] Onboarding werkt
- [ ] Noodnummer kan worden ingevoerd
- [ ] Home screen toont grote OK knop
- [ ] Settings zijn toegankelijk
- [ ] Notificatie wordt gepland (check na 48 uur)
- [ ] Check-in logt correct
- [ ] Logs scherm toont geschiedenis
- [ ] SMS wordt verzonden na grace periode (Android)

## Volgende Stappen

1. Voeg app icoon toe (zie `APP_ICON_INSTRUCTIES.md`)
2. Test op echt device
3. Configureer signing keys voor release builds
4. Upload naar Play Store / App Store
