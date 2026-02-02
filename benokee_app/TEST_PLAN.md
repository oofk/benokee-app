# Uitgebreide Test Plan - Benokee App

## 📧 E-mail Test Scenarios

### Test E-mail: test_benokee@okerckhoff.nl

**Wanneer je e-mails zou moeten ontvangen:**

1. **Introductie E-mail** - Direct na onboarding wanneer:
   - Je je eigen naam invult
   - Je contact e-mail invult: `test_benokee@okerckhoff.nl`
   - Je op "Verstuur introductie e-mail" klikt
   - **Verwachte tijd**: Binnen 10-30 seconden na klikken

2. **"I'm OK" E-mail** - Wanneer:
   - Je op de grote "IK BEN OKÉ" knop drukt
   - Instellingen → E-mail modus staat op "altijd" of "bij check-in"
   - **Verwachte tijd**: Binnen 10-30 seconden na klikken

3. **Missed Check-in Alert** - Wanneer:
   - Je 2 opeenvolgende dagen niet incheckt (na je ingestelde check interval)
   - **Verwachte tijd**: Direct na de 2e gemiste check-in dag

## 🧪 Test Checklist

### 1. App Start & Initialisatie
- [ ] App start zonder crashes
- [ ] Loading screen verschijnt kort
- [ ] Firebase initialiseert correct
- [ ] Geen errors in console

### 2. Role Selection Screen
- [ ] Screen laadt correct
- [ ] Twee opties zichtbaar: "Ik ben gebruiker" en "Ik ben contactpersoon"
- [ ] Knoppen zijn klikbaar
- [ ] Navigatie werkt

### 3. Onboarding Flow (Gebruiker)
- [ ] Welkom scherm verschijnt
- [ ] Stap indicator werkt
- [ ] Volgende/Vorige knoppen werken
- [ ] Naam invoer werkt
- [ ] E-mail validatie werkt (real-time)
- [ ] Contact naam invoer werkt
- [ ] Introductie e-mail versturen werkt
- [ ] E-mail wordt daadwerkelijk verstuurd
- [ ] Na onboarding → Home screen

### 4. Home Screen
- [ ] Grote groene "IK BEN OKÉ" knop zichtbaar
- [ ] Knop is klikbaar
- [ ] Bevestigingsdialoog verschijnt
- [ ] Check-in wordt geregistreerd
- [ ] Tijd sinds laatste check-in wordt getoond
- [ ] Settings knop werkt
- [ ] Help knop werkt (als aanwezig)

### 5. Settings Screen
- [ ] Alle instellingen zijn zichtbaar
- [ ] Check interval instellen werkt
- [ ] Reminder interval instellen werkt
- [ ] Check tijd instellen werkt (24-uurs formaat)
- [ ] Contactpersonen beheren werkt
- [ ] Contact toevoegen werkt
- [ ] Contact bewerken werkt
- [ ] Contact verwijderen werkt
- [ ] Introductie opnieuw doen werkt
- [ ] Help en ondersteuning werkt
- [ ] Logs bekijken werkt

### 6. E-mail Functionaliteit
- [ ] Introductie e-mail wordt verstuurd
- [ ] E-mail bevat juiste informatie
- [ ] E-mail bevat app store links
- [ ] E-mail bevat FCM token (als beschikbaar)
- [ ] "I'm OK" e-mail wordt verstuurd
- [ ] Missed check-in alert wordt verstuurd
- [ ] E-mails komen aan op test_benokee@okerckhoff.nl

### 7. Notificaties
- [ ] Notificaties worden gepland
- [ ] Notificaties verschijnen op juiste tijd
- [ ] Notificaties zijn klikbaar
- [ ] App opent bij klikken op notificatie
- [ ] Herinneringen werken correct

### 8. Performance
- [ ] App start snel (< 3 seconden)
- [ ] Schermen laden snel
- [ ] Geen lag bij navigatie
- [ ] Geen memory leaks
- [ ] Smooth animations

### 9. Gebruiksvriendelijkheid
- [ ] Tekst is leesbaar
- [ ] Knoppen zijn groot genoeg
- [ ] Foutmeldingen zijn duidelijk
- [ ] Success feedback is duidelijk
- [ ] Flow is logisch
- [ ] Help is beschikbaar

### 10. Edge Cases
- [ ] App werkt zonder internet (behalve e-mail)
- [ ] App werkt na herstart
- [ ] Notificaties werken na herstart
- [ ] Data blijft behouden na herstart
- [ ] Duplicate contact check werkt
- [ ] Invalid e-mail wordt afgewezen

## 🔍 Specifieke Test Cases

### Test Case 1: Eerste Gebruik
1. App openen
2. "Ik ben gebruiker" selecteren
3. Door onboarding gaan
4. Naam invullen: "Test Gebruiker"
5. E-mail invullen: test_benokee@okerckhoff.nl
6. Contact naam: "Test Contact"
7. Introductie e-mail versturen
8. **VERWACHT**: E-mail binnen 30 seconden op test_benokee@okerckhoff.nl

### Test Case 2: Check-in
1. Op "IK BEN OKÉ" knop drukken
2. Bevestigen
3. **VERWACHT**: "I'm OK" e-mail binnen 30 seconden (als e-mail modus aan staat)

### Test Case 3: Missed Check-in
1. Wacht 2 dagen zonder in te checken
2. **VERWACHT**: Alert e-mail na 2e gemiste dag

### Test Case 4: Contact Beheer
1. Settings → Contactpersonen
2. Nieuw contact toevoegen
3. Bestaand contact bewerken
4. Contact verwijderen
5. Duplicate e-mail proberen

### Test Case 5: Instellingen
1. Check interval aanpassen
2. Reminder interval aanpassen
3. Check tijd aanpassen
4. Instellingen opslaan
5. App herstarten
6. Check of instellingen behouden zijn

## 📊 Performance Metrics

- App start tijd: < 3 seconden
- Scherm transitie: < 300ms
- E-mail verzenden: < 30 seconden
- Memory usage: < 100MB
- Battery impact: Minimal

## 🐛 Bekende Issues om te Testen

- [ ] Firebase initialisatie errors
- [ ] E-mail verzenden failures
- [ ] Notificatie scheduling issues
- [ ] Data persistence issues
- [ ] Navigation issues

## ✅ Success Criteria

- Alle e-mails worden correct verstuurd
- Alle functionaliteiten werken
- Geen crashes
- Goede performance
- Gebruiksvriendelijke interface
