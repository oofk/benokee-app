# BOSA Formulier Automatisering

Een interactieve web applicatie voor het automatisch invullen van het BOSA (Bouw en Onderhoud Sportaccommodaties) subsidie formulier. De applicatie slaat alle gegevens op in Excel bestanden zodat deze hergebruikt kunnen worden voor volgende aanvragen.

## Features

- ✅ **Interactieve Web Interface**: Gebruiksvriendelijke interface voor het invoeren van formuliergegevens
- ✅ **Excel Opslag**: Alle gegevens worden opgeslagen in Excel voor hergebruik
- ✅ **Automatisch Invullen**: Browser automatisering met Selenium voor automatisch invullen van het formulier
- ✅ **Kosten Beheer**: Upload Excel bestanden met kosten data of voeg handmatig toe
- ✅ **Document Beheer**: Beheer facturen en offertes in een centrale directory
- ✅ **Flexibele Field Mapping**: Systeem kan aangepast worden als formulier velden veranderen

## Installatie

### Vereisten

- Python 3.10 of hoger
- Chrome browser (voor Selenium automatisering)
- ChromeDriver (wordt automatisch geïnstalleerd via webdriver-manager)

### Stappen

1. **Installeer dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Start de applicatie:**
   ```bash
   python bosa_app.py
   ```

3. **Open de browser:**
   - Ga naar: http://localhost:8001
   - De applicatie is nu beschikbaar

## Gebruik

### 1. Gegevens Invoeren

- Vul alle formuliergegevens in via de web interface
- Klik op "Opslaan in Excel" om gegevens op te slaan
- Gebruik "Laad Opgeslagen Data" om eerder opgeslagen gegevens te laden

### 2. Kosten Beheren

- **Optie A**: Upload een Excel bestand met kosten data
  - Het Excel bestand moet kolommen bevatten zoals: Activiteit, Bedrag, Categorie, etc.
  - Plaats documenten (PDF's, facturen) in: `bosa_data/kosten_documenten/`

- **Optie B**: Voeg kosten handmatig toe via de interface

### 3. Formulier Invullen

- Klik op "Start Formulier Invullen"
- De browser wordt geopend en het formulier wordt automatisch ingevuld
- U kunt het proces volgen en indien nodig handmatig aanpassen
- Controleer alle ingevulde gegevens voordat u het formulier verzendt

### 4. Instellingen

- **Formulier Analyse**: Analyseer de formulier structuur om veldnamen te identificeren
- **Field Mapping**: Pas de mapping aan als velden niet correct worden gevonden

## Bestandsstructuur

```
.
├── bosa_app.py                 # Flask applicatie
├── bosa_data_manager.py         # Excel data management
├── bosa_form_filler_improved.py # Verbeterde browser automatisering
├── bosa_form_analyzer.py       # Script om formulier structuur te analyseren
├── bosa_templates/
│   └── bosa_index.html         # Web interface
├── bosa_static/
│   ├── bosa_app.js            # Frontend JavaScript
│   └── bosa_styles.css        # Styling
├── bosa_data/
│   ├── bosa_formulier_data.xlsx    # Opgeslagen formulier gegevens
│   ├── bosa_kosten.xlsx            # Kosten data
│   └── kosten_documenten/          # Facturen en offertes
└── requirements.txt
```

## Excel Structuur

### bosa_formulier_data.xlsx

Bevat meerdere sheets:
- **Aanvrager**: Organisatie gegevens, KVK, BTW info, adres
- **Contact**: Contactpersoon gegevens
- **Bank**: IBAN, banknaam, rekeninghouder
- **Amateursport**: Sport specifieke gegevens
- **Activiteiten**: Beschrijving activiteiten
- **Ondertekenaar**: Ondertekenaar gegevens

### bosa_kosten.xlsx

Kolommen (voorbeeld):
- Activiteit
- Categorie
- Bedrag
- BTW
- Subtotaal
- Document (pad naar bestand)

## Formulier Analyse

Om de exacte veldnamen van het formulier te achterhalen:

```bash
python bosa_form_analyzer.py
```

Dit script:
- Opent het formulier in een browser
- Analyseert alle input velden, selects en textareas
- Slaat de structuur op in `bosa_form_structure.json`
- Helpt bij het maken van een field mapping

## Field Mapping

Als het formulier niet correct wordt ingevuld, kunt u een custom field mapping maken:

1. Analyseer het formulier met `bosa_form_analyzer.py`
2. Maak een `bosa_field_mapping.json` bestand:

```json
{
  "naam_organisatie": {
    "selector": {
      "by": "name",
      "value": "actual_field_name_in_form"
    }
  }
}
```

## Veelgestelde Vragen

### Het formulier wordt niet correct ingevuld

1. Analyseer het formulier met `bosa_form_analyzer.py`
2. Controleer de log bestanden: `bosa_form_filler.log`
3. Pas de field mapping aan in `bosa_field_mapping.json`

### Kosten worden niet correct ingevuld

- Zorg dat de Excel structuur overeenkomt met wat het formulier verwacht
- Controleer of documenten in de juiste directory staan
- Bekijk de browser console voor foutmeldingen

### Browser wordt niet geopend

- Controleer of Chrome geïnstalleerd is
- ChromeDriver wordt automatisch geïnstalleerd, maar kan handmatig nodig zijn
- Zet `headless=False` in de code om browser zichtbaar te maken

## Verbeteringen Toekomst

- [ ] Volledige implementatie van kosten sectie invullen
- [ ] Automatische document upload per kosten item
- [ ] Validatie van ingevulde gegevens
- [ ] Preview van wat ingevuld gaat worden
- [ ] Export naar PDF van ingevulde gegevens
- [ ] Multi-step wizard voor betere gebruikerservaring

## Vragen of Problemen?

Als u vragen heeft of problemen tegenkomt:

1. Controleer de log bestanden
2. Gebruik de formulier analyzer om veldnamen te identificeren
3. Pas de field mapping aan indien nodig

## Licentie

Dit project is gemaakt voor intern gebruik voor het automatisch invullen van BOSA subsidie formulieren.

