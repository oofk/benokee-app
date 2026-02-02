# Factuur-Bank Matching Script

ROBUUST Python script dat facturen uit PDF's automatisch matcht met banktransacties uit een CSV bestand.

## 📋 Voorbereiding

### 1. Benodigde bestanden

Zorg dat de volgende bestanden in dezelfde map staan als het script:

- **`bank.csv`** - Banktransacties export (komma- of puntkomma-gescheiden, latin1 encoding)
- **`*.pdf`** - Factuur PDF's die gematcht moeten worden
- **`leveranciers.xlsx`** (optioneel) - Tabel met leveranciersinformatie

### 2. Leveranciers.xlsx structuur

Maak een Excel bestand `leveranciers.xlsx` met de volgende kolommen:

| leverancier | type maatregel | omschrijving |
|--------------|----------------|--------------|
| Albert Heijn | Kosten aanschaf en onderhoud sportmaterialen | Boodschappen |
| Bouwbedrijf X | Kosten algemene bouw en onderhoudsmaatregelen | Reparaties dak |
| ... | ... | ... |

**Kolommen:**
- `leverancier` - Naam van de leverancier (fuzzy matching, case-insensitive)
- `type maatregel` - Type maatregel (zie opties hieronder)
- `omschrijving` - Omschrijving van de werkzaamheden

**Type maatregel opties:**
1. Kosten aanschaf en onderhoud sportmaterialen
2. Kosten algemene bouw en onderhoudsmaatregelen
3. duurzaamheid maatregel

> **Let op:** Als `leveranciers.xlsx` niet bestaat, wordt het automatisch aangemaakt. Je wordt dan voor elke match gevraagd om type maatregel en omschrijving in te voeren.

### 3. Bank.csv structuur

Het script verwacht een CSV bestand met **fixed kolom posities**:

- **Kolom 5 (index 4)**: Datum (bijv. "29-12-2025")
- **Kolom 7 (index 6)**: Bedrag (NL notatie: "40.000,00" → 40000.00)
- **Kolom 20 (index 19)**: Omschrijving (bijv. "Factuur VF2513565")
- **Laatste kolom**: Veld 86 (extra omschrijving)

Het script detecteert automatisch of de CSV komma- of puntkomma-gescheiden is.

### 4. Python dependencies

Installeer de benodigde packages:

```bash
pip install -r requirements.txt
```

**Benodigde packages:**
- pandas
- openpyxl (voor Excel bestanden)
- PyMuPDF (fitz) (voor PDF extractie)

## 🚀 Gebruik

### Script uitvoeren

```bash
python match_facturen.py
```

### Wat gebeurt er?

1. **Bank CSV lezen**
   - Leest `bank.csv` en parseert transacties
   - Maakt bedragen automatisch positief (banktransacties zijn vaak negatief)

2. **PDF's verwerken**
   - Extraheert factuurnummers, bedragen, datums en leveranciers uit alle PDF's
   - Ondersteunt meerdere factuurnummer formaten:
     - VF2513880, V2513880
     - Factuur: 25150
     - OO9F005177106818
     - 2502000291
     - F25-05873

3. **Matching**
   - Matcht facturen met banktransacties op basis van:
     - Factuurnummer in bank omschrijving (case-insensitive)
     - Bedrag binnen 5% tolerance

4. **Leveranciersinformatie**
   - Zoekt leverancier in `leveranciers.xlsx` (fuzzy matching)
   - Als niet gevonden:
     - Opent PDF automatisch
     - Vraagt om type maatregel (meerkeuze menu)
     - Vraagt om omschrijving werkzaamheden

5. **Bestanden verplaatsen**
   - PDF's met match → `verwerkt/` map
   - PDF's zonder match → `geen match/` map

6. **Excel output**
   - `facturen_final.xlsx` - Alle verwerkte facturen
   - `matches_final.xlsx` - Alle matches met volledige informatie

## 📊 Output bestanden

### facturen_final.xlsx

Kolommen:
- PDF
- Factuurnummer
- Factuurdatum
- Bedrag EUR
- Leverancier
- Werkzaamheden
- Tekst preview

### matches_final.xlsx

Kolommen (in volgorde):
1. **type maatregel** - Type maatregel (uit leveranciers.xlsx of handmatig)
2. **naam leverancier** - Naam van de leverancier
3. **factuurbedrag inc. btw** - Bedrag van de factuur
4. **factuurnummer** - Nummer van de factuur
5. **factuurdatum** - Datum van de factuur
6. **bankomschrijving** - Omschrijving uit banktransactie
7. **datum bank_datum** - Datum van banktransactie
8. **bank_bedrag** - Bedrag van banktransactie (altijd positief)
9. **omschrijving werkzaamheden** - Omschrijving uit leveranciers.xlsx of handmatig

## ⚙️ Configuratie

Je kunt de volgende instellingen aanpassen in het script:

```python
BANK_CSV = 'bank.csv'  # Naam van bank CSV bestand
PDF_PATTERN = '*.pdf'  # Pattern voor PDF bestanden
PROCESSED_DIR = 'verwerkt'  # Map voor PDF's met match
NO_MATCH_DIR = 'geen match'  # Map voor PDF's zonder match
LEVERANCIERS_XLSX = 'leveranciers.xlsx'  # Leveranciers tabel
AMOUNT_TOLERANCE = 0.05  # 5% bedrag tolerance voor matching
```

## 🔍 Matching logica

Een factuur wordt gematcht met een banktransactie wanneer:

1. **Factuurnummer match**: Het factuurnummer staat in de bank omschrijving (case-insensitive, fuzzy)
2. **Bedrag match**: Het bedrag komt overeen binnen 5% tolerance

**Voorbeeld match:**
- PDF: "Verkoopfactuur VF2513880.pdf" (€225,67)
- Bank: "Factuur VF2513880" (20-11-2025, -€225,67)
- ✅ Match! (bedrag wordt automatisch positief gemaakt)

## 🛠️ Troubleshooting

### "There is already an instance running!"

Deze melding kan verschijnen wanneer de PDF al open staat. Dit kan worden genegeerd - het script werkt gewoon door.

### Leverancier niet gevonden

Als een leverancier niet in `leveranciers.xlsx` staat:
1. PDF wordt automatisch geopend
2. Kies type maatregel (1, 2, 3 of Enter)
3. Voer omschrijving in (of Enter voor leeg)

### Geen matches gevonden

Controleer:
- Zijn factuurnummers correct geëxtraheerd uit PDF's?
- Staat het factuurnummer in de bank omschrijving?
- Is het bedrag binnen 5% tolerance?

### CSV parsing problemen

Het script detecteert automatisch de separator (komma of puntkomma). Als dit niet werkt:
- Controleer of de CSV correct is geëxporteerd
- Check of de kolom posities kloppen (zie Bank.csv structuur)

## 📝 Notities

- Bank bedragen worden automatisch positief gemaakt voor matching
- PDF's worden verplaatst na verwerking (niet verwijderd)
- Het script werkt case-insensitive voor alle matching
- Leveranciers matching is fuzzy (exact → substring → similarity)

## 🆘 Support

Bij problemen:
1. Check of alle bestanden in dezelfde map staan
2. Controleer of dependencies geïnstalleerd zijn
3. Bekijk de console output voor debug informatie
4. Zorg dat `leveranciers.xlsx` de juiste kolommen heeft

---

**Versie:** 1.0  
**Laatste update:** 2025


