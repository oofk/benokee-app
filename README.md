# Boodschappenplanner (Flask)

Eenvoudige lokale webapp (Flask + vanilla JS) om een wekelijkse boodschappenlijst te maken op basis van vaste gerechten, standaarditems, incidentele items en Albert Heijn bonus-aanbiedingen.

## Vereisten
- Python 3.10+ aanbevolen

## Installatie
```bash
pip install -r requirements.txt
```

## Starten
```bash
python app.py
# Open http://localhost:8000
```

## Structuur
- `app.py` – Flask app + API routes
- `data/seed_data.py` – ingebakken gegevens (Excel-structuur)
- `data/storage.py` – JSON opslag + seeding
- `services/bonus_service.py` – AH bonus scraper + matching
- `services/list_generation_service.py` – combinatielogica voor de lijst
- `templates/index.html` – single-page achtige UI (Nederlands)
- `static/app.js`, `static/styles.css` – frontend logica en styling

## API (korte versie)
- `GET/POST/PUT/DELETE /api/dishes`
- `GET/POST/PUT/DELETE /api/standard-items`
- `GET/POST/PUT/DELETE /api/incidental-items`
- `GET /api/bonus` – bonus scraping (fouttolerant, retourneert leeg bij problemen)
- `POST /api/generate-list` – verwacht `{ dishIds, standardItemIds, incidentalItemIds, includeBonusSuggestions }` en levert gecombineerde lijst + bonus info.

## Data en persistentie
- Bij eerste start worden JSON-bestanden aangemaakt in `data/` vanuit de seeds.
- Data blijft lokaal; geen cloud afhankelijkheden.

## Gebruik (UI)
1. Kies aantal dagen/personen.
2. Selecteer gerechten per dag en bekijk ingrediënten-overzicht.
3. Vink standaard wekelijkse items aan/uit (frequente items staan al aan).
4. Vink incidentele items aan.
5. Haal AH bonus op (optioneel) en zie matches/suggesties.
6. Overzicht: afvinkbare lijst en exporteerbare tekst, kopieer met één klik.

## Opmerkingen
- Scraping selectors staan in `services/bonus_service.py` en zijn eenvoudig aanpasbaar als AH de HTML wijzigt.
- Debug staat aan in `app.py`; zet `debug=False` voor productie-achtig gebruik.

