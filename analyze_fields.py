#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Analyseer de gevonden formuliervelden en maak een overzicht."""

import json

with open('bosa_form_structure.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print("=== BOSA FORMULIER VELDEN ANALYSE ===\n")

# Velden met labels
fields_with_labels = [f for f in data['all_fields'] if f.get('label') and f.get('label').strip()]
print(f"Velden met labels: {len(fields_with_labels)}")
print(f"Totaal velden: {len(data['all_fields'])}")
print(f"Totaal pagina's: {len(data['pages'])}\n")

print("=== BELANGRIJKE VELDEN MET LABELS ===\n")
for field in fields_with_labels[:30]:  # Eerste 30
    field_type = field.get('type', 'unknown')
    field_name = field.get('name', 'unknown')
    field_label = field.get('label', 'Geen label')
    page = field.get('page', '?')
    print(f"Pagina {page}: {field_name} ({field_type}) - {field_label}")

print("\n=== GRAVITY FORMS BUTTONS ===\n")
buttons = [f for f in data['all_fields'] if 'button' in f.get('type', '') or 'gform' in f.get('name', '').lower() or 'gform' in f.get('id', '').lower()]
for btn in buttons[:15]:
    print(f"  {btn.get('name', btn.get('id', 'unknown'))} - {btn.get('type', 'unknown')}")

print("\n=== SELECT VELDEN ===\n")
selects = [f for f in data['all_fields'] if f.get('type') == 'select']
for sel in selects:
    name = sel.get('name', 'unknown')
    label = sel.get('label', 'Geen label')
    options_count = len(sel.get('options', []))
    print(f"  {name} - {label} ({options_count} opties)")

