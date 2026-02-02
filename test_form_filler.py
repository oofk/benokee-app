#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test script voor de BOSA formulier filler met voorbeelddata.
"""

import sys
import io
from bosa_form_filler_improved import BOSAFormFillerImproved
from pathlib import Path

# Fix encoding voor Windows console
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# Voorbeelddata voor het formulier
test_form_data = {
    "aanvrager": {
        "naam_organisatie": "Test Sportvereniging",
        "kvk_nummer": "12345678",
        "btw_plichtig": "nee",
        "btw_aftrek": "nee",
        "postadres_type": "postadres",
        "straat": "Teststraat",
        "huisnummer": "123",
        "postcode": "1234AB",
        "plaats": "Amsterdam",
        "provincie": "Noord-Holland",
        "telefoon": "020-1234567",
        "email": "test@example.com"
    },
    "contact": {
        "voornaam_contact": "Jan",
        "tussenvoegsel_contact": "van",
        "achternaam_contact": "Berg",
        "email_contact": "jan.van.berg@example.com",
        "telefoon_contact": "020-1234567",
        "relatienummer": "",
        "intermediair": "nee",
        "akkoord_digitale_correspondentie": True
    },
    "bank": {
        "iban": "NL91ABNA0417164300",
        "banknaam": "ABN AMRO",
        "rekeninghouder": "Test Sportvereniging"
    },
    "ondertekenaar": {
        "tekenbevoegdheid": "zelfstandig",
        "voornaam_ondertekenaar": "Jan",
        "tussenvoegsel_ondertekenaar": "van",
        "achternaam_ondertekenaar": "Berg",
        "functie_ondertekenaar": "Voorzitter",
        "email_ondertekenaar": "jan.van.berg@example.com",
        "telefoon_ondertekenaar": "020-1234567"
    }
}

# Test kosten data (leeg voor nu)
test_costs_data = []

print("=== TEST BOSA FORMULIER FILLER ===\n")
print("Dit script test het automatisch invullen van het BOSA formulier.")
print("De browser wordt geopend en het formulier wordt automatisch ingevuld.\n")
print("LET OP: Dit is een test met voorbeelddata!")
print("Controleer handmatig of alle velden correct zijn ingevuld.\n")

input("Druk op Enter om te starten (of Ctrl+C om te annuleren)...")

try:
    # Maak form filler instance
    filler = BOSAFormFillerImproved(headless=False, wait_time=2)
    
    print("\nStart browser en navigeer naar formulier...")
    
    # Vul formulier in
    success = filler.fill_complete_form(
        form_data=test_form_data,
        costs_data=test_costs_data,
        documents_dir=None,
        auto_advance=True
    )
    
    if success:
        print("\n" + "="*50)
        print("TEST VOLTOOID!")
        print("="*50)
        print("\nHet formulier is automatisch ingevuld.")
        print("Controleer in de browser of alle velden correct zijn ingevuld.")
        print("\nDe browser blijft open zodat u kunt controleren.")
        print("Sluit de browser handmatig wanneer u klaar bent.")
        
        # Wacht zodat gebruiker kan controleren
        input("\nDruk op Enter om de browser te sluiten...")
    else:
        print("\nFOUT: Het invullen van het formulier is mislukt.")
        print("Controleer de log bestanden voor details.")
    
    # Sluit browser
    filler.close_browser()
    
except KeyboardInterrupt:
    print("\n\nTest geannuleerd door gebruiker.")
    sys.exit(0)
except Exception as e:
    print(f"\n\nFOUT: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)