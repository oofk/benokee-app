# Android Device Verbinden

## ⚠️ Device is Offline

Je Android device (HA1EYG0B) is offline. Volg deze stappen om het weer online te krijgen:

## ✅ Stap 1: Check USB Verbinding

1. **Ontgrendel je Android device**
2. **Check USB kabel** - Zorg dat de kabel goed is aangesloten
3. **Probeer een andere USB poort** - Soms werkt de ene poort beter dan de andere
4. **Probeer een andere USB kabel** - Als je een andere kabel hebt

## ✅ Stap 2: USB Debugging

1. **Ga naar Instellingen** op je Android device
2. **Ga naar "Over de telefoon"** of "About phone"
3. **Tik 7x op "Build number"** om Developer options te activeren
4. **Ga terug naar Instellingen**
5. **Ga naar "Developer options"** of "Ontwikkelaarsopties"
6. **Zet "USB debugging" aan**
7. **Accepteer de popup** die verschijnt (als die er is)

## ✅ Stap 3: Autoriseer Computer

1. **Ontgrendel je device**
2. **Koppel USB kabel aan**
3. **Er verschijnt een popup** op je device: "Allow USB debugging?"
4. **Vink "Always allow from this computer"** aan
5. **Klik "OK"** of "Toestaan"

## ✅ Stap 4: Check Verbinding

Na het verbinden, voer uit:

```powershell
cd C:\Users\olivi\cursor\benokee_app
flutter devices
```

Je zou moeten zien:
```
HA1EYG0B • android • ... • Android ... (mobile) • <device-id>
```

## 🚀 Stap 5: Deploy App

Zodra het device online is:

```powershell
cd C:\Users\olivi\cursor\benokee_app
flutter run -d HA1EYG0B
```

Of als er maar één Android device is:

```powershell
flutter run
```

## 🆘 Troubleshooting

### Device verschijnt niet
- Herstart Android device
- Herstart computer
- Probeer USB kabel opnieuw aan te sluiten
- Check of USB debugging aan staat

### "Device unauthorized"
- Check of je de popup hebt geaccepteerd
- Ontkoppel en koppel USB kabel opnieuw
- Accepteer de popup opnieuw

### "Offline" status
- Ontgrendel device
- Koppel USB kabel opnieuw aan
- Wacht 10 seconden
- Check opnieuw: `flutter devices`

### "No devices found"
- Zorg dat USB debugging aan staat
- Check of device is ontgrendeld
- Probeer `flutter doctor` om te zien of er problemen zijn

## 📱 Alternatief: Wireless Debugging (Android 11+)

Als USB niet werkt, kun je wireless debugging gebruiken:

1. **Ga naar Developer options**
2. **Zet "Wireless debugging" aan**
3. **Noteer IP adres en poort**
4. **Voer uit** (op computer):
   ```powershell
   adb connect <IP>:<PORT>
   ```

## ✅ Snelle Check

Voer dit uit om te zien of device online is:

```powershell
cd C:\Users\olivi\cursor\benokee_app
flutter devices
```

Als je `HA1EYG0B` ziet zonder "(offline)", dan is het klaar voor deploy!
