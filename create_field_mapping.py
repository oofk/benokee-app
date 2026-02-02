#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Maak een field mapping bestand op basis van de gevonden formuliervelden.
Dit bestand koppelt onze data keys aan de echte formulier veldnamen.
"""

import json
from pathlib import Path


def create_mapping_entry(name, field_id, field_type, label, page, radio_options=None):
    """Maak een mapping entry."""
    entry = {
        "selector": {
            "by": "name",
            "value": name
        },
        "type": field_type,
        "id": field_id,
        "label": label,
        "page": page
    }
    
    if field_type == "radio" and radio_options:
        entry["radio_options"] = radio_options
    
    return entry


# Laad formulier structuur
with open('bosa_form_structure.json', 'r', encoding='utf-8') as f:
    form_data = json.load(f)

fields = form_data['all_fields']
field_mapping = {}

print("=== MAKEN FIELD MAPPING ===\n")

# Functie om veld te vinden op basis van label tekst
def find_field_by_label(label_text, field_type=None):
    """Zoek veld op basis van label tekst."""
    for field in fields:
        field_label = field.get('label', '').lower()
        if label_text.lower() in field_label or field_label in label_text.lower():
            if field_type is None or field.get('type') == field_type:
                return field
    return None

# Functie om veld te vinden op basis van name
def find_field_by_name(name):
    """Zoek veld op basis van name."""
    for field in fields:
        if field.get('name') == name:
            return field
    return None

# === AANVRAGER SECTIE ===
print("Mapping aanvrager velden...")

# Naam organisatie
field = find_field_by_name('input_112')
if field:
    field_mapping['naam_organisatie'] = create_mapping_entry(
        field['name'], field['id'], field['type'], 
        'Naam amateursport organisatie', field['page']
    )

# KVK nummer - zoek naar veld met KVK in label of bekende field name
field = find_field_by_name('input_406') or find_field_by_name('input_404')
if field:
    field_mapping['kvk_nummer'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'KVK-nummer', field['page']
    )

# BTW-plichtig
field = find_field_by_name('input_402')
if field:
    field_mapping['btw_plichtig'] = create_mapping_entry(
        field['name'], field['id'], 'radio',
        'BTW-plichtig', field['page'],
        ['ja', 'nee']
    )

# BTW-aftrek
field = find_field_by_name('input_480')
if field:
    field_mapping['btw_aftrek'] = create_mapping_entry(
        field['name'], field['id'], 'radio',
        'Heeft de amateursportorganisatie recht op aftrek van btw', field['page'],
        ['ja', 'gedeeltelijk', 'nee']
    )

# Postadres type
field = find_field_by_name('input_410')
if field:
    field_mapping['postadres_type'] = create_mapping_entry(
        field['name'], field['id'], 'radio',
        'Postadres of postbus', field['page'],
        ['postadres', 'postbus']
    )

# Straat
field = find_field_by_name('input_411')
if field:
    field_mapping['straat'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Straat', field['page']
    )

# Huisnummer
field = find_field_by_name('input_412')
if field:
    field_mapping['huisnummer'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Huisnummer en toevoeging', field['page']
    )

# Postcode
field = find_field_by_name('input_226')
if field:
    field_mapping['postcode'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Postcode', field['page']
    )

# Plaats
field = find_field_by_name('input_227')
if field:
    field_mapping['plaats'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Plaats', field['page']
    )

# Provincie
field = find_field_by_name('input_330')
if field:
    field_mapping['provincie'] = create_mapping_entry(
        field['name'], field['id'], 'select',
        'Provincie', field['page']
    )

# Telefoon
field = find_field_by_name('input_413')
if field and field.get('type') == 'email':
    # Zoek telefoon veld (meestal na email)
    pass

# Email
field = find_field_by_name('input_413')
if field and field.get('type') == 'email':
    field_mapping['email'] = create_mapping_entry(
        field['name'], field['id'], 'email',
        'E-mailadres', field['page']
    )

# === CONTACT SECTIE ===
print("Mapping contact velden...")

# Voornaam
field = find_field_by_name('input_2')
if field:
    field_mapping['voornaam_contact'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Voornaam', field['page']
    )

# Tussenvoegsel
field = find_field_by_name('input_341')
if field:
    field_mapping['tussenvoegsel_contact'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Tussenvoegsel', field['page']
    )

# Achternaam
field = find_field_by_name('input_3')
if field:
    field_mapping['achternaam_contact'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Achternaam', field['page']
    )

# Email contact
field = find_field_by_name('input_6')
if field:
    field_mapping['email_contact'] = create_mapping_entry(
        field['name'], field['id'], 'email',
        'E-mailadres', field['page']
    )

# Telefoon contact
field = find_field_by_name('input_98')
if field:
    field_mapping['telefoon_contact'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Telefoonnummer', field['page']
    )

# Relatienummer
field = find_field_by_name('input_306')
if field:
    field_mapping['relatienummer'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Relatienummer', field['page']
    )

# Intermediair
field = find_field_by_name('input_333')
if field:
    field_mapping['intermediair'] = create_mapping_entry(
        field['name'], field['id'], 'radio',
        'Vraagt u als intermediair aan', field['page'],
        ['ja', 'nee']
    )

# Akkoord digitale correspondentie
field = find_field_by_name('input_205.1')
if field:
    field_mapping['akkoord_digitale_correspondentie'] = create_mapping_entry(
        field['name'], field['id'], 'checkbox',
        'Ik ga akkoord met digitale correspondentie', field['page']
    )

# === BANK SECTIE ===
print("Mapping bank velden...")

# IBAN - zoek naar veld met IBAN
field = find_field_by_name('input_416.1')
if field:
    field_mapping['iban'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'IBAN', field['page']
    )
else:
    # Zoek via label
    for f in fields:
        label = f.get('label', '') or ''
        if 'iban' in label.lower():
            field_mapping['iban'] = create_mapping_entry(
                f['name'], f['id'], f['type'],
                'IBAN', f['page']
            )
            break

# Banknaam
field = find_field_by_name('input_416.2')
if field:
    field_mapping['banknaam'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Banknaam', field['page']
    )

# Rekeninghouder
field = find_field_by_name('input_416.4')
if field:
    field_mapping['rekeninghouder'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Rekeninghouder', field['page']
    )

# === ONDERTEKENAAR SECTIE ===
print("Mapping ondertekenaar velden...")

# Tekenbevoegdheid
field = find_field_by_name('input_331')
if field:
    field_mapping['tekenbevoegdheid'] = create_mapping_entry(
        field['name'], field['id'], 'radio',
        'Tekenbevoegdheid', field['page'],
        ['zelfstandig', 'gezamenlijk', 'machtiging']
    )

# Voornaam ondertekenaar
field = find_field_by_name('input_56')
if field:
    field_mapping['voornaam_ondertekenaar'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Voornaam', field['page']
    )

# Tussenvoegsel ondertekenaar
field = find_field_by_name('input_474')
if field:
    field_mapping['tussenvoegsel_ondertekenaar'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Tussenvoegsel', field['page']
    )

# Achternaam ondertekenaar
field = find_field_by_name('input_57')
if field:
    field_mapping['achternaam_ondertekenaar'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Achternaam', field['page']
    )

# Functie ondertekenaar
field = find_field_by_name('input_87')
if field:
    field_mapping['functie_ondertekenaar'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Functie', field['page']
    )

# Email ondertekenaar
field = find_field_by_name('input_318')
if field:
    field_mapping['email_ondertekenaar'] = create_mapping_entry(
        field['name'], field['id'], 'email',
        'E-mailadres', field['page']
    )

# Telefoon ondertekenaar
field = find_field_by_name('input_61')
if field:
    field_mapping['telefoon_ondertekenaar'] = create_mapping_entry(
        field['name'], field['id'], field['type'],
        'Telefoonnummer', field['page']
    )

# Sla mapping op
output_file = Path('bosa_field_mapping.json')
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(field_mapping, f, indent=2, ensure_ascii=False)

print(f"\nOK: Field mapping opgeslagen in {output_file}")
print(f"OK: Totaal {len(field_mapping)} velden gemapped\n")

# Toon overzicht
print("=== GEMAPPTE VELDEN ===\n")
for key, value in sorted(field_mapping.items()):
    print(f"  {key}: {value['selector']['value']} ({value['type']}) - {value.get('label', 'Geen label')}")
