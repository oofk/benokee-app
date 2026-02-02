# Implementatie Notities: Hybride Messaging (FCM + SMTP)

## Status
✅ Dependencies toegevoegd (firebase_core, firebase_messaging, mailer, qr_flutter, flutter_secure_storage)
✅ FCM Service gemaakt
✅ SMTP Email Service gemaakt  
✅ Hybrid Messaging Service gemaakt
✅ QR Service gemaakt
✅ Storage Service uitgebreid (FCM token, user role)
✅ Localization strings toegevoegd

## Nog te doen

### 1. Onboarding aanpassen
- [ ] Rol selectie toevoegen aan het begin (gebruiker vs contactpersoon)
- [ ] Als contactpersoon: andere flow (geen check-in setup, alleen meldingen)
- [ ] Als gebruiker: bestaande flow + SMTP credentials vragen
- [ ] QR code tonen in introductie dialoog

### 2. Introductie e-mail updaten
- [ ] QR code genereren met FCM token
- [ ] E-mail body updaten met app installatie info
- [ ] Deep link toevoegen voor automatische koppeling

### 3. Contactpersoon modus
- [ ] Nieuwe screen maken voor contactpersonen (alleen meldingen zien)
- [ ] Geen check-in knop, alleen notificaties
- [ ] Deep link handler voor automatische koppeling

### 4. Firebase setup
- [ ] Firebase project configuratie bestanden
- [ ] google-services.json voor Android
- [ ] GoogleService-Info.plist voor iOS
- [ ] Setup instructies document

### 5. FCM token uitwisseling
- [ ] Token delen via e-mail
- [ ] Deep link handler voor token ontvangst
- [ ] Automatische koppeling bij app installatie

### 6. SMTP credentials setup
- [ ] Dialoog voor e-mail en wachtwoord invoer
- [ ] Veilige opslag met flutter_secure_storage
- [ ] Gmail App Password instructies

## Vragen voor gebruiker

1. **QR code inhoud**: Moet de QR code een deep link bevatten die automatisch de app opent en koppelt, of alleen een link naar de app store?

2. **Contactpersoon onboarding**: Moet een contactpersoon die de app installeert een volledige onboarding doorlopen, of direct naar het meldingenscherm?

3. **FCM token delen**: Moet de FCM token automatisch in de introductie e-mail worden opgenomen, of alleen via QR code?

4. **SMTP setup timing**: Wanneer moeten SMTP credentials worden gevraagd? Tijdens onboarding of later in instellingen?

5. **Firebase project**: Heb je al een Firebase project, of moet ik setup instructies maken?

## Volgende stappen

1. Wacht op antwoorden op vragen
2. Onboarding volledig aanpassen
3. Contactpersoon modus implementeren
4. Firebase setup documentatie maken
5. Testen en debuggen
