# BOSA Formulier Automatisering - Test Instructies

## Wat is er gemaakt

1. ✅ **Verbeterde Analyzer** - Vindt meer labels met 9 verschillende strategieën
2. ✅ **Field Mapping Bestand** - `bosa_field_mapping.json` met 29 gemapte velden
3. ✅ **Test Script** - `test_form_filler.py` voor het testen van de form filler

## Testen van de Form Filler

### Stap 1: Run de analyzer opnieuw (optioneel)
Als je meer labels wilt vinden, run:
```bash
python bosa_form_analyzer.py
```
Dit verbetert de field mapping met meer gevonden labels.

### Stap 2: Test de form filler
```bash
python test_form_filler.py
```

Dit script:
- Opent automatisch de browser
- Navigeert naar het BOSA formulier (voorbeeldversie)
- Vult automatisch alle velden in met testdata
- Klikt automatisch door alle stappen
- Laat de browser open zodat je kunt controleren

### Stap 3: Controleer de resultaten
- Controleer of alle velden correct zijn ingevuld
- Controleer of de navigatie tussen stappen werkt
- Bekijk de log bestanden voor details: `bosa_form_filler.log`

## Field Mapping

Het field mapping bestand (`bosa_field_mapping.json`) bevat:
- 29 gemapte velden
- Mapping van onze data keys naar formulier veldnamen
- Type informatie (text, radio, select, checkbox)
- Label informatie voor debugging

## Verbeteringen

### Analyzer Verbeteringen:
- ✅ 9 verschillende strategieën om labels te vinden
- ✅ Gravity Forms specifieke zoekstrategieën
- ✅ Radio button label detectie
- ✅ Aria-label en title attribuut ondersteuning

### Form Filler Verbeteringen:
- ✅ Gebruikt automatisch field mapping
- ✅ Ondersteunt radio buttons, checkboxes, selects
- ✅ Betere error handling en logging
- ✅ Automatische navigatie tussen stappen

## Volgende Stappen

1. **Test met echte data**: Pas `test_form_filler.py` aan met jouw echte gegevens
2. **Kosten sectie**: Implementeer de kosten sectie invullen (stap 7)
3. **Document upload**: Voeg document upload functionaliteit toe
4. **Validatie**: Voeg validatie toe voor verplichte velden

## Troubleshooting

### Veld wordt niet gevonden
- Controleer `bosa_field_mapping.json` of het veld gemapped is
- Run de analyzer opnieuw om labels te vinden
- Check de log bestanden voor details

### Radio button wordt niet geselecteerd
- Controleer of de waarde overeenkomt met de radio_options in de mapping
- Gebruik kleine letters: "ja" in plaats van "Ja"

### Dropdown wordt niet geselecteerd
- Controleer of de waarde exact overeenkomt met een optie
- Gebruik de exacte tekst zoals in het formulier


