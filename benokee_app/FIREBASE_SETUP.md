# Firebase Setup Instructies

## Overzicht
De Benokee app gebruikt:
- **Firebase Cloud Messaging (FCM)** voor push notificaties tussen gebruikers die beide de app hebben geïnstalleerd
- **Firebase Functions** voor het versturen van e-mails via Resend API (zodat gebruikers geen SMTP credentials hoeven in te vullen)

## Stap 1: Firebase Project Aanmaken

1. Ga naar [Firebase Console](https://console.firebase.google.com/)
2. Klik op "Add project" of selecteer een bestaand project
3. Volg de wizard om een project aan te maken
4. Schakel Google Analytics in (optioneel maar aanbevolen)

## Stap 2: Android App Toevoegen

1. In Firebase Console, klik op het Android icoon
2. Voer de volgende gegevens in:
   - **Package name**: `com.benokee.app` (of je eigen package name)
   - **App nickname**: Benokee (optioneel)
   - **Debug signing certificate SHA-1**: (optioneel voor development)
3. Klik op "Register app"
4. Download `google-services.json`
5. Plaats `google-services.json` in `android/app/`

## Stap 3: iOS App Toevoegen

1. In Firebase Console, klik op het iOS icoon
2. Voer de volgende gegevens in:
   - **Bundle ID**: `com.benokee.app` (moet overeenkomen met Xcode project)
   - **App nickname**: Benokee (optioneel)
3. Klik op "Register app"
4. Download `GoogleService-Info.plist`
5. Open Xcode project en sleep `GoogleService-Info.plist` naar de root van het project

## Stap 4: Android Configuratie

### build.gradle (Project level)
Zorg dat je `google-services` plugin hebt:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### build.gradle (App level)
Voeg toe aan het einde van het bestand:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### AndroidManifest.xml
Zorg dat je de volgende permissions hebt:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

## Stap 5: iOS Configuratie

### Podfile
Zorg dat je Firebase pods hebt:

```ruby
pod 'Firebase/Core'
pod 'Firebase/Messaging'
```

Run:
```bash
cd ios
pod install
```

### AppDelegate.swift
Voeg Firebase initialisatie toe:

```swift
import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Info.plist
Voeg toe:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

## Stap 6: Flutter Dependencies

De dependencies zijn al toegevoegd in `pubspec.yaml`:
- `firebase_core: ^3.6.0`
- `firebase_messaging: ^15.1.3`

Run:
```bash
flutter pub get
```

## Stap 7: Resend API Setup (voor e-mail versturen)

✅ **API Key**: `re_Y8EA2N4u_1LwDxdn3XttTMVNVnKJVg2YL` (al geconfigureerd)

1. Maak een gratis account aan op [resend.com](https://resend.com) (als je dat nog niet hebt gedaan)
2. Ga naar API Keys en maak een nieuwe API key aan
3. Kopieer de API key (of gebruik de bovenstaande key)

## Stap 8: Firebase Functions Setup

### Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### Initialize Functions
```bash
cd benokee_app
firebase init functions
```

Selecteer:
- JavaScript
- ESLint: Yes
- Install dependencies: Yes

### Set Resend API Key
```bash
firebase functions:config:set resend.api_key="re_xxxxxxxxxxxxx"
```

Of via Firebase Console:
1. Ga naar Firebase Console > Functions > Configuration
2. Voeg environment variable toe: `RESEND_API_KEY` = `re_xxxxxxxxxxxxx`

### Deploy Functions
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

## Stap 9: FCM Server Key (optioneel, voor toekomstige FCM implementatie)

Voor het versturen van push notificaties via backend:

1. Ga naar Firebase Console > Project Settings > Cloud Messaging
2. Kopieer de "Server key" (voor backend implementatie)
3. Of gebruik Firebase Cloud Functions (aanbevolen)

## Stap 10: Testen

1. Build en run de app
2. Check of FCM token wordt gegenereerd (zie debug console)
3. Test push notificaties via Firebase Console > Cloud Messaging > Send test message

## Troubleshooting

### Android: "google-services.json not found"
- Zorg dat `google-services.json` in `android/app/` staat
- Check of de package name overeenkomt

### iOS: "GoogleService-Info.plist not found"
- Zorg dat het bestand in Xcode project is toegevoegd
- Check of de Bundle ID overeenkomt

### FCM Token wordt niet gegenereerd
- Check of Firebase correct is geïnitialiseerd
- Check of notificatie permissions zijn verleend
- Check debug console voor errors

## Belangrijke Notities

- **Gratis tier**: 
  - Firebase Functions: 2 miljoen invocations/maand gratis
  - Resend: 3.000 e-mails/maand gratis
  - Ruim voldoende voor deze app
- **Security**: 
  - FCM tokens worden lokaal opgeslagen en gedeeld via e-mail/QR code
  - Resend API key wordt alleen in Firebase Functions opgeslagen (niet in app)
- **E-mail verzenden**: 
  - Gebruikt Resend via Firebase Functions
  - Gebruikers hoeven geen SMTP credentials in te vullen
  - E-mails komen van `noreply@benokee.app` (vervang met je eigen domain)
- **Domain verificatie**: 
  - Voor productie: verifieer je eigen domain in Resend
  - Voor testen: gebruik Resend's test domain

## Volgende Stappen

Na Firebase setup:
1. Implementeer FCM token uitwisseling tussen gebruikers
2. Implementeer backend service voor FCM berichten versturen (optioneel)
3. Test de volledige flow
