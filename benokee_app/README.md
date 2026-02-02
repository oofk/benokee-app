# Benokee App

Een eenvoudige, betrouwbare check-in tool voor alleenstaanden met lokale notificaties, SMS-alerts en persistente scheduling.

## Features

- ✅ Onboarding met tutorial en noodnummer invoer
- ✅ Grote "IK BEN OKÉ" knop voor check-ins
- ✅ Automatische notificaties elke 48 uur (instelbaar)
- ✅ 4-uurs grace periode met hourly reminders
- ✅ SMS alerts naar noodcontact na grace periode
- ✅ Lokale opslag van settings en logs
- ✅ Volledig offline, geen cloud services
- ✅ Android en iOS support

## Installatie

1. Installeer Flutter SDK: https://flutter.dev/docs/get-started/install
2. Clone of download dit project
3. Open terminal in `benokee_app` directory
4. Run: `flutter pub get`
5. Run: `flutter run` (voor Android) of gebruik Xcode voor iOS

## Build

### Android
```bash
flutter build apk
```

### iOS (vereist Mac)
```bash
flutter build ios
```

## Configuratie

### Android
- Min SDK: 24
- Target SDK: 34
- Permissions: SMS, Exact Alarms, Notifications

### iOS
- Min iOS: 12.0
- Background Modes: fetch, processing
- Notifications: UserNotifications framework

## Dependencies

- `flutter_local_notifications`: Lokale notificaties
- `timezone`: Timezone support voor exacte alarms
- `sms_maintained`: SMS verzending (Android only)
- `shared_preferences`: Lokale opslag
- `permission_handler`: Permissions management
- `intl`: Datum/tijd formatting

## Gebruik

1. **Eerste keer**: Volg onboarding, voer noodnummer in
2. **Check-in**: Druk op grote groene knop wanneer je een notificatie krijgt
3. **Instellingen**: Tandwieltje rechtsboven voor configuratie
4. **Logs**: Bekijk check-in geschiedenis in settings

## Technische Details

- Notificaties worden automatisch hergepland bij app open/resume
- Exact alarms voor betrouwbare timing (Android)
- Background fetch voor iOS herstarts
- Grace periode met hourly reminders
- SMS wordt alleen verzonden na volledige grace periode

## Licentie

Privé project - geen licentie.
