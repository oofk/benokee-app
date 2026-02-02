# Code naar GitHub pushen – stap voor stap

## Stap 1: GitHub-account

- Ga naar [github.com](https://github.com) en log in (of maak een gratis account).

---

## Stap 2: Nieuwe repository op GitHub aanmaken

1. Klik rechtsboven op **+** → **New repository**.
2. Vul in:
   - **Repository name:** bijvoorbeeld `benokee-app` of `cursor`.
   - **Description:** optioneel, bijv. "Benokee check-in app".
   - Kies **Public**.
   - **Vink NIET aan:** "Add a README", "Add .gitignore", "Choose a license" (je hebt al code).
3. Klik op **Create repository**.

4. **Kopieer de URL** van je nieuwe repo:
   - Je ziet iets als: `https://github.com/JOUW-GEBRUIKERSNAAM/benokee-app.git`
   - Of SSH: `git@github.com:JOUW-GEBRUIKERSNAAM/benokee-app.git`

---

## Stap 3: Git initialiseren (als nog niet gedaan)

Open een terminal in de map van je project (bijv. `C:\Users\olivi\cursor`) en voer uit:

```powershell
cd C:\Users\olivi\cursor
git init
```

---

## Stap 4: Bestanden toevoegen en eerste commit

```powershell
git add .
git status
```

Controleer of er geen gevoelige bestanden tussen zitten (wachtwoorden, API-keys). Daarna:

```powershell
git commit -m "Eerste commit - Benokee app"
```

---

## Stap 5: GitHub als remote koppelen

Vervang `JOUW-GEBRUIKERSNAAM` en `benokee-app` door jouw GitHub-gebruikersnaam en repo-naam:

```powershell
git remote add origin https://github.com/JOUW-GEBRUIKERSNAAM/benokee-app.git
```

---

## Stap 6: Branch hernoemen naar main (optioneel)

GitHub gebruikt standaard `main`. Als je op een andere branch zit:

```powershell
git branch -M main
```

---

## Stap 7: Eerste push

```powershell
git push -u origin main
```

- Bij **HTTPS** wordt om je **GitHub-gebruikersnaam en wachtwoord** gevraagd.  
  Voor wachtwoord: gebruik een **Personal Access Token** (zie onder).
- Bij **SSH** moet je een SSH-sleutel op GitHub hebben gezet.

---

## Inloggen bij push (HTTPS)

GitHub accepteert geen gewoon wachtwoord meer bij HTTPS. Je hebt een **Personal Access Token** nodig:

1. GitHub → rechtsboven je profielfoto → **Settings**.
2. Links onderaan: **Developer settings** → **Personal access tokens** → **Tokens (classic)**.
3. **Generate new token (classic)**.
4. Geef een naam, vink o.a. **repo** aan, genereer en **kopieer de token** (eenmalig zichtbaar).
5. Bij `git push`:
   - Username: je GitHub-gebruikersnaam  
   - Password: plak de **token** (niet je normale wachtwoord).

---

## Volgende keren (na wijzigingen)

```powershell
cd C:\Users\olivi\cursor
git add .
git commit -m "Korte beschrijving van je wijziging"
git push
```

---

## Samenvatting commando’s (eerste keer)

```powershell
cd C:\Users\olivi\cursor
git init
git add .
git commit -m "Eerste commit - Benokee app"
git remote add origin https://github.com/JOUW-GEBRUIKERSNAAM/benokee-app.git
git branch -M main
git push -u origin main
```

Vervang `JOUW-GEBRUIKERSNAAM` en `benokee-app` door jouw gegevens.
