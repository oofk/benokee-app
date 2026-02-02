# Device Verbinden - Troubleshooting

## ⚠️ Device Nog Niet Gedetecteerd

Flutter detecteert het device nog niet als "online". Dit kan verschillende oorzaken hebben:

## ✅ Checklist

### 1. USB Debugging
- [ ] Ga naar **Settings** → **About phone**
- [ ] Tik 7x op **Build number** om Developer options te activeren
- [ ] Ga naar **Settings** → **Developer options**
- [ ] Zet **USB debugging** aan
- [ ] Zet **Install via USB** aan (als beschikbaar)

### 2. USB Kabel
- [ ] Probeer een andere USB kabel
- [ ] Gebruik een USB 2.0 poort (niet USB 3.0)
- [ ] Probeer een andere USB poort

### 3. USB Debugging Popup
- [ ] Ontgrendel je device
- [ ] Accepteer de **"Allow USB debugging?"** popup
- [ ] Vink **"Always allow from this computer"** aan
- [ ] Klik **OK**

### 4. Device Status
- [ ] Device is ontgrendeld
- [ ] Geen andere apps gebruiken USB debugging
- [ ] Herstart device (optioneel)

### 5. Flutter/ADB
- [ ] Sluit alle andere apps die ADB gebruiken
- [ ] Herstart terminal/PowerShell
- [ ] Probeer: `flutter doctor` om te checken

## 🔄 Automatisch Proberen

Er draait een script dat automatisch blijft proberen tot het device gedetecteerd wordt.

**Maximaal 20 pogingen** (ongeveer 1 minuut).

## 🚀 Handmatig Deployen

Als het device wel verbonden is maar Flutter het niet ziet:

```powershell
cd C:\Users\olivi\cursor\benokee_app
flutter devices
flutter run -d HA1EYG0B
```

Of als je het device ID niet weet:
```powershell
flutter devices
# Zoek naar je device in de lijst
flutter run
# Kies je device uit de lijst
```

## 📱 Alternatief: Wireless Debugging

Als USB niet werkt, kun je ook wireless debugging gebruiken:
1. Zet **Wireless debugging** aan in Developer options
2. Noteer het IP adres en poort
3. Gebruik: `adb connect <IP>:<PORT>`

## ⏱️ Wachten

Het script blijft automatisch proberen. **Zodra Flutter het device detecteert**, wordt de app automatisch gedeployed!
