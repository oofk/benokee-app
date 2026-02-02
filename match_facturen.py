#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ROBUUST Python script dat facturen uit PDF's matcht met banktransacties.

Input:
- bank.csv (; gescheiden, latin1, fixed kolommen)
- *.pdf facturen in dezelfde map

Output:
- facturen_final.xlsx
- matches_final.xlsx
"""

import re
import os
import glob
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional, Tuple
import pandas as pd
import fitz  # PyMuPDF
from difflib import SequenceMatcher
import webbrowser

# ============================================================================
# CONFIGURATIE
# ============================================================================

BANK_CSV = 'bank.csv'  # Komma- of puntkomma-gescheiden CSV
PDF_PATTERN = '*.pdf'
PROCESSED_DIR = 'verwerkt'  # Map voor verwerkte PDF's met match
NO_MATCH_DIR = 'geen match'  # Map voor PDF's zonder match
LEVERANCIERS_XLSX = 'leveranciers.xlsx'  # Tabel met leveranciers info
GROOTBOEK_FILES = ['grootboek.xlsx', 'grootboek2.xlsx']  # Grootboek bestanden met debiteuren

# Fixed kolom posities in bank.csv (0-indexed)
BANK_COL_DATE = 4      # Kolom 5
BANK_COL_AMOUNT = 6    # Kolom 7
BANK_COL_DESC = 19     # Kolom 20
BANK_COL_FIELD86 = -1  # Laatste kolom

# Regex patterns voor factuurnummers (in volgorde van specificiteit)
INVOICE_PATTERNS = [
    r'vf?(\d{6,})',                    # VF2513880, V2513880, VF2500693
    r'\b(f24|f25)[-:]?(\d{5,})\b',     # F24-00175, F25-00730, F25-05873
    r'fact[_-]?(\d{4,})',              # Fact_20253095, factuur_18414
    r'fac(\d{4,})',                    # FAC2025037, FAC2025046
    r'factuur[:\s_-]*(\d{4,})',        # Factuur: 25150, Factuur 241130253
    r'oo9[fpt](\d{8,})',               # OO9F005177106818
    r'\b(2502\d{4,})\b',               # 2502000291
    r'\b(25-?\d{5,})\b',               # 25-00007, 250290, 250389
    r'\b(20\d{2}\d{4,})\b',            # 2025027, 202514405, 20250221
    r'\b(\d{6,})\b',                   # 2507498, 252742, 99004946, 125730130
    r'\b(\d{5,})\b',                   # 35092, 35621, 10548 (minimaal 5 cijfers)
]

# Bedrag regex
AMOUNT_PATTERNS = [
    r'totaal[:\s]*€?\s*([\d.,]+)',     # Totaal € 225,67
    r'bedrag[:\s]*€?\s*([\d.,]+)',     # Bedrag: € 225,67
    r'€\s*([\d.,]+)',                  # € 225,67
    r'(\d{1,3}(?:\.\d{3})*(?:,\d{2})?)',  # NL notatie: 1.234,56
]

# Matching tolerance
AMOUNT_TOLERANCE = 0.05  # 5%


# ============================================================================
# HELPER FUNCTIES
# ============================================================================

def clean_text(text: str) -> str:
    """Normaliseer tekst voor matching."""
    if not text:
        return ""
    return re.sub(r'\s+', ' ', text.strip(), flags=re.UNICODE)


def parse_nl_amount(amount_str: str) -> Optional[float]:
    """
    Parse Nederlandse bedrag notatie: "1.234,56" → 1234.56
    Handelt ook "225,67" en "40.000,00" af.
    """
    if not amount_str:
        return None
    
    # Verwijder € en whitespace
    amount_str = re.sub(r'[€\s]', '', amount_str.strip())
    
    # Check of het NL notatie is (komma als decimaal)
    if ',' in amount_str:
        # Verwijder duizendtallen punten
        amount_str = amount_str.replace('.', '')
        # Vervang komma door punt
        amount_str = amount_str.replace(',', '.')
    
    try:
        return float(amount_str)
    except (ValueError, AttributeError):
        return None


def parse_date_flexible(date_str: str) -> Optional[datetime]:
    """
    Parse datum in flexibele formaten: %d-%m-%Y, %d/%m/%Y, etc.
    """
    if not date_str or pd.isna(date_str):
        return None
    
    date_str = str(date_str).strip()
    formats = [
        '%d-%m-%Y',
        '%d/%m/%Y',
        '%Y-%m-%d',
        '%Y/%m/%d',
        '%d.%m.%Y',
    ]
    
    for fmt in formats:
        try:
            return datetime.strptime(date_str, fmt)
        except (ValueError, AttributeError):
            continue
    
    return None


def extract_invoice_number(text: str, filename: str = "") -> Optional[str]:
    """
    Extract factuurnummer uit tekst met meerdere regex patterns.
    """
    if not text:
        text = ""
    
    # Combineer tekst en filename (filename heeft prioriteit)
    search_text = f"{filename} {text}".upper()
    
    # Eerst proberen patterns die volledige matches geven (met prefix)
    for pattern in INVOICE_PATTERNS:
        matches = re.findall(pattern, search_text, re.IGNORECASE)
        if matches:
            # Voor patterns met groepen, combineer groepen
            if isinstance(matches[0], tuple):
                # Combineer alle groepen (bijv. F24 + 00175)
                best_match = ''.join(str(m) for m in max(matches, key=lambda x: len(''.join(str(i) for i in x))))
            else:
                best_match = max(matches, key=len)
            
            best_match_str = str(best_match).upper()
            # Minimaal 4 cijfers, maar voor korte nummers (5-6 cijfers) alleen als ze in filename staan
            if len(best_match_str) >= 4:
                # Als het een kort nummer is, check of het in filename staat
                if len(best_match_str) < 7 and filename.upper().find(best_match_str) == -1:
                    continue
                return best_match_str
    
    # Fallback: zoek naar nummers in filename
    filename_upper = filename.upper()
    # Zoek naar nummers van 5+ cijfers in filename
    filename_numbers = re.findall(r'\d{5,}', filename_upper)
    if filename_numbers:
        # Neem het langste nummer
        return max(filename_numbers, key=len)
    
    return None


def extract_amount_from_text(text: str) -> Optional[float]:
    """
    Extract bedrag uit tekst met meerdere patterns.
    """
    if not text:
        return None
    
    text_upper = text.upper()
    
    for pattern in AMOUNT_PATTERNS:
        matches = re.findall(pattern, text_upper, re.IGNORECASE)
        if matches:
            # Neem het grootste bedrag (meestal het totaal)
            amounts = []
            for match in matches:
                parsed = parse_nl_amount(match)
                if parsed and parsed > 0:
                    amounts.append(parsed)
            
            if amounts:
                return max(amounts)  # Neem het grootste bedrag
    
    return None


def extract_supplier_name_from_bank(bank_omschrijving: str) -> Optional[str]:
    """
    Extract leveranciersnaam uit bank omschrijving.
    Bank omschrijvingen bevatten vaak de leveranciersnaam.
    """
    if not bank_omschrijving:
        return None
    
    # Veelvoorkomende patronen in bank omschrijvingen
    # Bijv: "Factuur Verbunt Hockey BV", "Betaling aan ClubColors B.V.", etc.
    
    # Verwijder veelvoorkomende prefixen
    text = bank_omschrijving.strip()
    text_lower = text.lower()
    
    # Skip als het alleen factuurnummers zijn
    if re.match(r'^[\d\s-]+$', text):
        return None
    
    # Verwijder veelvoorkomende woorden
    remove_words = ['factuur', 'invoice', 'betaling', 'payment', 'overboeking', 'incasso', 
                   'automatische', 'automatisch', 'storting', 'afschrift']
    for word in remove_words:
        text = re.sub(rf'\b{word}\b', '', text, flags=re.IGNORECASE)
    
    # Zoek naar bedrijfsnamen (woorden met hoofdletters, of bekende bedrijfsvormen)
    # Bijv: "Verbunt Hockey BV", "ClubColors B.V.", "J.V.L. Installaties"
    
    # Patroon: woorden met hoofdletters gevolgd door BV, B.V., etc.
    company_patterns = [
        r'([A-Z][A-Za-z]+(?:\s+[A-Z][A-Za-z]+)*)\s+(?:B\.?V\.?|BV|B\.V\.)',
        r'([A-Z][A-Za-z]+(?:\s+[A-Z][A-Za-z]+)*)\s+(?:Inc\.?|LLC|Ltd\.?)',
        r'([A-Z][A-Za-z]+(?:\s+[A-Z][A-Za-z]+)*)\s+(?:Installaties|Hockey|Sport)',
    ]
    
    for pattern in company_patterns:
        match = re.search(pattern, text)
        if match:
            supplier = match.group(1).strip()
            if len(supplier) > 3 and 'mmhc voordaan' not in supplier.lower():
                return supplier[:50]
    
    # Fallback: neem eerste woorden (niet factuurnummers)
    words = text.split()
    supplier_words = []
    for word in words:
        word_clean = re.sub(r'[^\w\s]', '', word)
        # Skip korte woorden, nummers, en veelvoorkomende woorden
        if (len(word_clean) > 3 and 
            not word_clean.isdigit() and 
            word_clean.lower() not in ['factuur', 'invoice', 'betaling', 'aan', 'van']):
            supplier_words.append(word_clean)
            if len(supplier_words) >= 3:  # Max 3 woorden
                break
    
    if supplier_words:
        supplier = ' '.join(supplier_words)
        if 'mmhc voordaan' not in supplier.lower():
            return supplier[:50]
    
    return None


def extract_supplier_name(text: str, filename: str) -> str:
    """
    Probeer leveranciersnaam te extraheren uit tekst of filename.
    Sluit "MMHC Voordaan" uit en zoekt naar alternatieve leveranciers.
    """
    # Eenvoudige heuristiek: eerste regel of filename zonder extensie
    lines = text.split('\n')[:10]  # Eerste 10 regels (meer regels voor betere extractie)
    suppliers_found = []
    
    for line in lines:
        line = line.strip()
        if line and len(line) > 3 and len(line) < 100:
            # Skip veelvoorkomende headers
            if not any(skip in line.lower() for skip in ['factuur', 'invoice', 'datum', 'bedrag', 'totaal']):
                line_lower = line.lower()
                # Sluit MMHC Voordaan uit
                if 'mmhc voordaan' not in line_lower and 'voordaan' not in line_lower:
                    suppliers_found.append(line[:50])
                # Zoek naar alternatieve leveranciers (bijv. Verbunt)
                elif 'verbunt' in line_lower:
                    suppliers_found.append(line[:50])
    
    # Als leveranciers gevonden, neem de eerste (niet-MMHC Voordaan)
    if suppliers_found:
        return suppliers_found[0]
    
    # Fallback: filename zonder extensie
    filename_stem = Path(filename).stem[:50]
    # Check of filename niet MMHC Voordaan is
    if 'mmhc voordaan' not in filename_stem.lower() and 'voordaan' not in filename_stem.lower():
        return filename_stem
    
    # Als filename wel Voordaan is, probeer andere delen van filename
    # Bijv. "2025027_VoordaanClubhuis.pdf" -> zoek naar andere delen
    parts = filename_stem.split('_')
    for part in parts:
        if 'voordaan' not in part.lower() and len(part) > 3:
            return part[:50]
    
    return filename_stem  # Laatste fallback


def extract_invoice_date(text: str) -> Optional[datetime]:
    """
    Extract factuurdatum uit tekst.
    Zoekt naar patronen zoals: "Datum: 15-11-2025", "Factuurdatum 20/11/2025", etc.
    """
    if not text:
        return None
    
    # Datum patterns (NL formaten)
    date_patterns = [
        r'datum[:\s]+(\d{1,2}[-./]\d{1,2}[-./]\d{2,4})',  # Datum: 15-11-2025
        r'factuurdatum[:\s]+(\d{1,2}[-./]\d{1,2}[-./]\d{2,4})',  # Factuurdatum: 15-11-2025
        r'(\d{1,2}[-./]\d{1,2}[-./]\d{4})',  # 15-11-2025, 15/11/2025, 15.11.2025
        r'(\d{4}[-./]\d{1,2}[-./]\d{1,2})',  # 2025-11-15
    ]
    
    for pattern in date_patterns:
        matches = re.findall(pattern, text, re.IGNORECASE)
        if matches:
            # Probeer de eerste match te parsen
            for match in matches:
                date = parse_date_flexible(match)
                if date:
                    return date
    
    return None


def extract_work_description(text: str) -> str:
    """
    Extract samenvatting van werkzaamheden/omschrijving uit factuur.
    Zoekt naar secties zoals "Omschrijving", "Werkzaamheden", "Beschrijving", etc.
    """
    if not text:
        return ""
    
    # Zoek naar secties met omschrijvingen
    description_keywords = [
        r'omschrijving[:\s]*(.+?)(?:\n\n|\n[A-Z]|totaal|bedrag|€|euro)',
        r'werkzaamheden[:\s]*(.+?)(?:\n\n|\n[A-Z]|totaal|bedrag|€|euro)',
        r'beschrijving[:\s]*(.+?)(?:\n\n|\n[A-Z]|totaal|bedrag|€|euro)',
        r'producten[:\s]*(.+?)(?:\n\n|\n[A-Z]|totaal|bedrag|€|euro)',
        r'diensten[:\s]*(.+?)(?:\n\n|\n[A-Z]|totaal|bedrag|€|euro)',
    ]
    
    text_lower = text.lower()
    
    for pattern in description_keywords:
        matches = re.findall(pattern, text, re.IGNORECASE | re.DOTALL)
        if matches:
            # Neem de eerste match en clean
            desc = matches[0].strip()
            # Verwijder te lange regels en normaliseer
            lines = desc.split('\n')[:10]  # Max 10 regels
            desc = ' '.join([line.strip() for line in lines if line.strip()])
            # Limiteer lengte
            if len(desc) > 500:
                desc = desc[:500] + "..."
            return clean_text(desc)
    
    # Fallback: zoek naar regels tussen factuurnummer en totaal
    # Dit is een heuristiek voor facturen zonder duidelijke sectie
    lines = text.split('\n')
    description_lines = []
    in_description = False
    
    for i, line in enumerate(lines):
        line_lower = line.lower().strip()
        
        # Start bij factuurnummer of na leverancier info
        if any(keyword in line_lower for keyword in ['factuur', 'invoice', 'nummer']):
            in_description = True
            continue
        
        # Stop bij totaal, bedrag, of einde
        if any(keyword in line_lower for keyword in ['totaal', 'bedrag', 'totaalbedrag', '€', 'euro']):
            break
        
        # Verzamel regels die lijken op omschrijvingen
        if in_description and line.strip():
            # Skip lege regels en headers
            if len(line.strip()) > 5 and not any(skip in line_lower for skip in ['datum', 'klant', 'adres', 'btw']):
                description_lines.append(line.strip())
                if len(description_lines) >= 5:  # Max 5 regels
                    break
    
    if description_lines:
        desc = ' '.join(description_lines)
        if len(desc) > 500:
            desc = desc[:500] + "..."
        return clean_text(desc)
    
    return ""


# ============================================================================
# LEVERANCIERS LOADING
# ============================================================================

def extract_supplier_from_omschrijving(omschrijving: str) -> Optional[str]:
    """
    Extract leveranciersnaam uit omschrijving tekst.
    Bijv: "Nadine van Gerwen september" -> "Nadine van Gerwen"
         "Pro-Club licence + 12 coaches" -> "Pro-Club"
    """
    if not omschrijving or pd.isna(omschrijving):
        return None
    
    omschrijving = str(omschrijving).strip()
    
    # Skip veelvoorkomende niet-leverancier teksten
    skip_patterns = [
        r'salaris',
        r'trainersvergoeding',
        r'augustus|september|oktober|november|december',
        r'bon shag',
        r'^[0-9\s-]+$',  # Alleen nummers
    ]
    
    for pattern in skip_patterns:
        if re.search(pattern, omschrijving, re.IGNORECASE):
            return None
    
    # Verwijder veelvoorkomende suffixen
    omschrijving = re.sub(r'\s+(september|oktober|november|december|januari|februari|maart|april|mei|juni|juli|augustus).*$', '', omschrijving, flags=re.IGNORECASE)
    omschrijving = re.sub(r'\s+deel\s+\d+.*$', '', omschrijving, flags=re.IGNORECASE)
    omschrijving = re.sub(r'\s+\d{4}-\d{4}.*$', '', omschrijving)  # Jaar ranges
    
    # Neem eerste deel (tot eerste | of + of speciale tekens)
    omschrijving = re.split(r'[|+]', omschrijving)[0].strip()
    
    # Neem eerste 2-4 woorden (meestal bedrijfsnaam)
    words = omschrijving.split()
    if len(words) >= 2:
        # Neem eerste 2-3 woorden als ze niet te kort zijn
        supplier_words = []
        for word in words[:4]:
            if len(word) > 2 and not word.isdigit():
                supplier_words.append(word)
                if len(supplier_words) >= 3:
                    break
        if supplier_words:
            supplier = ' '.join(supplier_words)
            if len(supplier) > 3 and 'mmhc voordaan' not in supplier.lower():
                return supplier[:50]
    
    return None


def load_grootboek_betalingen() -> pd.DataFrame:
    """
    Laad betalingen uit grootboek bestanden met factuurnummers, leveranciers en bedragen.
    Returns DataFrame met: factuurnummer, leverancier, bedrag, bron
    """
    betalingen = []
    
    for grootboek_file in GROOTBOEK_FILES:
        if not os.path.exists(grootboek_file):
            continue
        
        try:
            df = pd.read_excel(grootboek_file, engine='openpyxl')
            original_columns = df.columns.tolist()
            df.columns = df.columns.str.strip()
            
            # Zoek relevante kolommen
            factuur_col = None
            omschrijving_col = None
            bedrag_col = None
            
            for col in df.columns:
                col_lower = col.lower()
                if 'factuur' in col_lower and factuur_col is None:
                    factuur_col = col
                if 'omschrijving' in col_lower and omschrijving_col is None:
                    omschrijving_col = col
                if col_lower in ['debet', 'credit'] and bedrag_col is None:
                    bedrag_col = col
            
            # Als we factuurnummer kolom hebben, gebruik die
            if factuur_col and omschrijving_col:
                factuur_rows = df[df[factuur_col].notna()].copy()
                
                for idx, row in factuur_rows.iterrows():
                    factuur_num = str(row[factuur_col]).strip()
                    omschrijving = str(row[omschrijving_col]).strip() if pd.notna(row[omschrijving_col]) else ''
                    
                    # Extract leverancier uit omschrijving
                    leverancier = extract_supplier_from_omschrijving(omschrijving)
                    if not leverancier:
                        leverancier = omschrijving[:50] if len(omschrijving) > 3 else ''
                    
                    # Skip als leverancier MMHC Voordaan is
                    if leverancier and 'mmhc voordaan' in leverancier.lower():
                        continue
                    
                    # Haal bedrag op (Debet of Credit)
                    bedrag = 0.0
                    if bedrag_col:
                        bedrag = float(row[bedrag_col]) if pd.notna(row[bedrag_col]) else 0.0
                    else:
                        # Probeer Debet of Credit kolom te vinden
                        for col in df.columns:
                            if col.lower() in ['debet', 'credit']:
                                bedrag = float(row[col]) if pd.notna(row[col]) else 0.0
                                if bedrag > 0:
                                    break
                    
                    if bedrag > 0 and leverancier:
                        betalingen.append({
                            'factuurnummer': factuur_num,
                            'leverancier': leverancier,
                            'bedrag': bedrag,
                            'bron': f'grootboek_{Path(grootboek_file).name}'
                        })
                
                print(f"✅ {len(betalingen)} betalingen geladen uit {grootboek_file}")
        except Exception as e:
            print(f"⚠️  Fout bij laden {grootboek_file}: {e}")
            import traceback
            traceback.print_exc()
    
    if betalingen:
        df_betalingen = pd.DataFrame(betalingen)
        print(f"✅ Totaal {len(df_betalingen)} betalingen uit grootboek bestanden")
        return df_betalingen
    
    return pd.DataFrame(columns=['factuurnummer', 'leverancier', 'bedrag', 'bron'])


def create_integrated_payment_list(bank_df: pd.DataFrame, grootboek_betalingen: pd.DataFrame = None) -> pd.DataFrame:
    """
    Maak geïntegreerde lijst van betalingen uit grootboek + bank.
    Returns DataFrame met: factuurnummer, leverancier, bedrag, datum, bron, bank_omschrijving
    """
    integrated_list = []
    
    # 1. Laad betalingen uit grootboek (als niet al gegeven)
    if grootboek_betalingen is None:
        grootboek_betalingen = load_grootboek_betalingen()
    
    # 2. Extract factuurnummers en leveranciers uit bank transacties
    for idx, row in bank_df.iterrows():
        bank_omschrijving = str(row.get('omschrijving', ''))
        bank_bedrag = row.get('bedrag', 0.0)
        bank_datum = row.get('datum')
        
        # Extract factuurnummer uit bank omschrijving
        factuur_num = None
        for pattern in INVOICE_PATTERNS:
            match = re.search(pattern, bank_omschrijving, re.IGNORECASE)
            if match:
                factuur_num = match.group(1) if match.lastindex >= 1 else match.group(0)
                break
        
        # Extract leverancier uit bank omschrijving
        leverancier = extract_supplier_name_from_bank(bank_omschrijving)
        
        if factuur_num or leverancier:
            integrated_list.append({
                'factuurnummer': factuur_num or '',
                'leverancier': leverancier or '',
                'bedrag': bank_bedrag,
                'datum': bank_datum,
                'bron': 'bank',
                'bank_omschrijving': bank_omschrijving
            })
    
    # 3. Voeg grootboek betalingen toe
    for idx, row in grootboek_betalingen.iterrows():
        integrated_list.append({
            'factuurnummer': str(row.get('factuurnummer', '')),
            'leverancier': str(row.get('leverancier', '')),
            'bedrag': float(row.get('bedrag', 0.0)),
            'datum': None,  # Grootboek heeft mogelijk geen datum
            'bron': row.get('bron', 'grootboek'),
            'bank_omschrijving': ''
        })
    
    if integrated_list:
        df_integrated = pd.DataFrame(integrated_list)
        # Verwijder duplicaten (op basis van factuurnummer + bedrag)
        df_integrated = df_integrated.drop_duplicates(
            subset=['factuurnummer', 'bedrag', 'leverancier'], 
            keep='first'
        )
        print(f"✅ Geïntegreerde lijst: {len(df_integrated)} betalingen (grootboek + bank)")
        return df_integrated
    
    return pd.DataFrame(columns=['factuurnummer', 'leverancier', 'bedrag', 'datum', 'bron', 'bank_omschrijving'])


def match_invoice_to_integrated_list(invoice: Dict, integrated_df: pd.DataFrame, bank_df: pd.DataFrame) -> Optional[Dict]:
    """
    Match een factuur met de geïntegreerde lijst op meerdere criteria:
    1. Factuurnummer (exact of partial)
    2. Bedrag + leverancier
    3. Bestandsnaam extractie
    """
    invoice_num = invoice.get('factuurnummer')
    invoice_amount = invoice.get('bedrag_eur')
    invoice_supplier = invoice.get('leverancier', '')
    pdf_filename = invoice.get('pdf', '')
    
    # Als geen factuurnummer uit PDF, probeer uit bestandsnaam
    if not invoice_num and pdf_filename:
        invoice_num = extract_invoice_number(pdf_filename, pdf_filename)
        if invoice_num:
            invoice['factuurnummer'] = invoice_num
    
    matches = []
    
    # Strategie 1: Match op factuurnummer
    if invoice_num:
        invoice_num_upper = str(invoice_num).upper()
        
        # Exact match
        exact_matches = integrated_df[
            integrated_df['factuurnummer'].str.upper().str.contains(
                re.escape(invoice_num_upper), case=False, na=False, regex=True
            )
        ]
        
        # Partial match (laatste 6+ cijfers)
        partial_matches = pd.DataFrame()
        if len(invoice_num) >= 6:
            last_digits = invoice_num[-6:]
            partial_matches = integrated_df[
                integrated_df['factuurnummer'].str.contains(last_digits, case=False, na=False, regex=False)
            ]
        
        # Combineer matches
        if not exact_matches.empty:
            matches.append(exact_matches)
        if not partial_matches.empty:
            matches.append(partial_matches)
    
    # Strategie 2: Match op bedrag + leverancier (fuzzy)
    if invoice_amount and invoice_supplier and len(invoice_supplier) > 3:
        # Fuzzy match leverancier
        for idx, row in integrated_df.iterrows():
            integrated_supplier = str(row.get('leverancier', ''))
            if integrated_supplier and len(integrated_supplier) > 3:
                similarity = SequenceMatcher(None, 
                    invoice_supplier.lower(), 
                    integrated_supplier.lower()
                ).ratio()
                
                if similarity >= 0.7:  # 70% overeenkomst
                    # Check bedrag (binnen 5% tolerance)
                    integrated_amount = float(row.get('bedrag', 0.0))
                    if abs(integrated_amount - abs(invoice_amount)) / abs(invoice_amount) <= AMOUNT_TOLERANCE:
                        matches.append(pd.DataFrame([row]))
    
    # Strategie 3: Match op exact bedrag (als geen andere match)
    if not matches and invoice_amount:
        exact_amount_matches = integrated_df[
            abs(integrated_df['bedrag'] - abs(invoice_amount)) < 0.01  # Exact match (€0.01 tolerance)
        ]
        if not exact_amount_matches.empty:
            matches.append(exact_amount_matches)
    
    # Combineer alle matches
    if matches:
        all_matches = pd.concat(matches).drop_duplicates()
        
        # Filter op bedrag als we een factuurnummer match hebben
        if invoice_amount:
            all_matches['verschil_abs'] = abs(all_matches['bedrag'] - abs(invoice_amount))
            all_matches['verschil_pct'] = all_matches['verschil_abs'] / abs(invoice_amount)
            all_matches = all_matches[all_matches['verschil_pct'] <= AMOUNT_TOLERANCE]
        
        if not all_matches.empty:
            # Sorteer op beste match (exact factuurnummer > partial > bedrag+leverancier > alleen bedrag)
            all_matches['score'] = 0
            if invoice_num:
                all_matches.loc[
                    all_matches['factuurnummer'].str.upper().str.contains(
                        re.escape(str(invoice_num).upper()), case=False, na=False, regex=True
                    ), 'score'
                ] = 100  # Exact factuurnummer match
                if len(invoice_num) >= 6:
                    all_matches.loc[
                        all_matches['factuurnummer'].str.contains(invoice_num[-6:], case=False, na=False, regex=False),
                        'score'
                    ] = all_matches.loc[
                        all_matches['factuurnummer'].str.contains(invoice_num[-6:], case=False, na=False, regex=False),
                        'score'
                    ].apply(lambda x: max(x, 50))  # Partial match
            
            # Bedrag + leverancier match krijgt score 30
            if invoice_supplier:
                for idx, row in all_matches.iterrows():
                    integrated_supplier = str(row.get('leverancier', ''))
                    if integrated_supplier and len(integrated_supplier) > 3:
                        similarity = SequenceMatcher(None,
                            invoice_supplier.lower(),
                            integrated_supplier.lower()
                        ).ratio()
                        if similarity >= 0.7 and row['score'] < 30:
                            all_matches.loc[idx, 'score'] = 30
            
            # Alleen bedrag match krijgt score 10
            all_matches.loc[all_matches['score'] == 0, 'score'] = 10
            
            # Sorteer op score (hoogste eerst), dan op verschil percentage
            all_matches = all_matches.sort_values(['score', 'verschil_pct'], ascending=[False, True])
            
            best_match = all_matches.iloc[0]
            
            # Haal bank transactie op als bron is 'bank'
            bank_datum = best_match.get('datum')
            bank_bedrag = best_match.get('bedrag')
            bank_omschrijving = best_match.get('bank_omschrijving', '')
            
            # Als datum ontbreekt, probeer uit bank_df te halen
            if not bank_datum and best_match.get('bron') == 'bank':
                # Zoek in bank_df op bedrag en omschrijving
                bank_match = bank_df[
                    (abs(bank_df['bedrag'] - bank_bedrag) < 0.01) &
                    (bank_df['omschrijving'].str.contains(
                        re.escape(best_match.get('factuurnummer', '')), case=False, na=False, regex=True
                    ))
                ]
                if not bank_match.empty:
                    bank_datum = bank_match.iloc[0].get('datum')
                    bank_omschrijving = bank_match.iloc[0].get('omschrijving', '')
            
            # Update leverancier als die beter is uit geïntegreerde lijst
            integrated_supplier = best_match.get('leverancier', '')
            if integrated_supplier and (
                not invoice_supplier or 
                len(integrated_supplier) > len(invoice_supplier) or
                'mmhc voordaan' in invoice_supplier.lower()
            ):
                invoice_supplier = integrated_supplier
            
            return {
                'pdf': invoice['pdf'],
                'factuurnummer': invoice_num or best_match.get('factuurnummer', ''),
                'pdf_bedrag': invoice_amount,
                'factuurdatum': invoice.get('factuurdatum'),
                'werkzaamheden': invoice.get('werkzaamheden', ''),
                'bank_datum': bank_datum,
                'bank_bedrag': bank_bedrag,
                'verschil': abs(bank_bedrag - invoice_amount) if invoice_amount else None,
                'bank_omschrijving': bank_omschrijving,
                'leverancier': invoice_supplier,
                'match_score': best_match.get('score', 0),
                'match_bron': best_match.get('bron', 'unknown')
            }
    
    return None


def load_grootboek_debiteuren() -> pd.DataFrame:
    """
    Laad debiteuren/leveranciers uit grootboek.xlsx en grootboek2.xlsx.
    Returns DataFrame met unieke debiteuren namen.
    """
    debiteuren = []
    
    for grootboek_file in GROOTBOEK_FILES:
        if not os.path.exists(grootboek_file):
            continue
        
        try:
            df = pd.read_excel(grootboek_file, engine='openpyxl')
            # Normaliseer kolomnamen
            df.columns = df.columns.str.strip().str.lower()
            
            # Voor Grootboek2.xlsx: gebruik Omschrijving kolom
            if 'omschrijving' in df.columns:
                # Filter op rijen met factuurnummers (betrouwbaarder)
                if 'factuurnummer' in df.columns:
                    factuur_df = df[df['factuurnummer'].notna()]
                    omschrijvingen = factuur_df['omschrijving'].dropna().unique()
                else:
                    omschrijvingen = df['omschrijving'].dropna().unique()
                
                for omschrijving in omschrijvingen:
                    supplier = extract_supplier_from_omschrijving(omschrijving)
                    if supplier:
                        debiteuren.append(supplier)
                
                print(f"✅ {len(debiteuren)} leveranciers gevonden in {grootboek_file} (uit omschrijving)")
                continue
            
            # Voor grootboek.xlsx: zoek kolom met debiteur/leverancier naam
            debiteur_col = None
            for col in df.columns:
                col_lower = col.lower()
                if any(keyword in col_lower for keyword in ['debiteur', 'leverancier', 'naam', 'bedrijf', 'company', 'omschrijving']):
                    debiteur_col = col
                    break
            
            if debiteur_col:
                # Haal unieke debiteuren
                debiteuren_df = df[debiteur_col].dropna().unique()
                for debiteur in debiteuren_df:
                    debiteur_str = str(debiteur).strip()
                    # Extract leverancier uit omschrijving als nodig
                    supplier = extract_supplier_from_omschrijving(debiteur_str)
                    if supplier:
                        debiteuren.append(supplier)
                    elif len(debiteur_str) > 3 and 'mmhc voordaan' not in debiteur_str.lower():
                        debiteuren.append(debiteur_str[:50])
                print(f"✅ {len(debiteuren_df)} debiteuren gevonden in {grootboek_file}")
            else:
                print(f"⚠️  Geen debiteur/omschrijving kolom gevonden in {grootboek_file}")
        except Exception as e:
            print(f"⚠️  Fout bij laden {grootboek_file}: {e}")
            import traceback
            traceback.print_exc()
    
    if debiteuren:
        # Maak DataFrame met unieke debiteuren
        unique_debiteuren = list(set(debiteuren))
        print(f"✅ Totaal {len(unique_debiteuren)} unieke leveranciers uit grootboek bestanden")
        return pd.DataFrame({'leverancier': unique_debiteuren})
    
    return pd.DataFrame(columns=['leverancier'])


def load_leveranciers() -> pd.DataFrame:
    """
    Laad leveranciers.xlsx met kolommen: leverancier, type maatregel, omschrijving.
    Combineert ook met debiteuren uit grootboek bestanden.
    """
    leveranciers_list = []
    
    # Laad leveranciers.xlsx
    if os.path.exists(LEVERANCIERS_XLSX):
        try:
            df = pd.read_excel(LEVERANCIERS_XLSX, engine='openpyxl')
            # Normaliseer kolomnamen (case-insensitive, strip whitespace)
            df.columns = df.columns.str.strip().str.lower()
            
            # Zorg dat alle benodigde kolommen bestaan
            required_cols = ['leverancier', 'type maatregel', 'omschrijving']
            for col in required_cols:
                if col not in df.columns:
                    df[col] = None
            
            leveranciers_list.append(df[required_cols])
            print(f"✅ {len(df)} leveranciers geladen uit {LEVERANCIERS_XLSX}")
        except Exception as e:
            print(f"⚠️  Fout bij laden {LEVERANCIERS_XLSX}: {e}")
    else:
        print(f"⚠️  {LEVERANCIERS_XLSX} niet gevonden")
    
    # Laad debiteuren uit grootboek bestanden
    grootboek_df = load_grootboek_debiteuren()
    if not grootboek_df.empty:
        # Voeg type maatregel en omschrijving kolommen toe (leeg)
        grootboek_df['type maatregel'] = None
        grootboek_df['omschrijving'] = None
        leveranciers_list.append(grootboek_df)
    
    # Combineer alle leveranciers
    if leveranciers_list:
        combined_df = pd.concat(leveranciers_list, ignore_index=True)
        # Verwijder duplicaten (op basis van leverancier naam)
        combined_df = combined_df.drop_duplicates(subset=['leverancier'], keep='first')
        print(f"✅ Totaal {len(combined_df)} unieke leveranciers beschikbaar")
        return combined_df
    
    return pd.DataFrame(columns=['leverancier', 'type maatregel', 'omschrijving'])


def fuzzy_match_leverancier(supplier_name: str, leveranciers_df: pd.DataFrame) -> Optional[Dict]:
    """
    Fuzzy match leveranciersnaam (case-insensitive, niet exact).
    Returns dict met type_maatregel en omschrijving of None.
    """
    if not supplier_name or leveranciers_df.empty:
        return None
    
    supplier_lower = supplier_name.lower().strip()
    
    # Eerst exacte match (case-insensitive)
    exact_match = leveranciers_df[
        leveranciers_df['leverancier'].str.lower().str.strip() == supplier_lower
    ]
    if not exact_match.empty:
        row = exact_match.iloc[0]
        return {
            'type_maatregel': str(row['type maatregel']) if pd.notna(row['type maatregel']) else '',
            'omschrijving': str(row['omschrijving']) if pd.notna(row['omschrijving']) else ''
        }
    
    # Dan substring match
    for idx, row in leveranciers_df.iterrows():
        leverancier = str(row['leverancier']).lower().strip()
        if supplier_lower in leverancier or leverancier in supplier_lower:
            return {
                'type_maatregel': str(row['type maatregel']) if pd.notna(row['type maatregel']) else '',
                'omschrijving': str(row['omschrijving']) if pd.notna(row['omschrijving']) else ''
            }
    
    # Dan fuzzy match met SequenceMatcher (similarity > 0.7)
    best_match = None
    best_score = 0.7  # Minimum threshold
    
    for idx, row in leveranciers_df.iterrows():
        leverancier = str(row['leverancier']).lower().strip()
        similarity = SequenceMatcher(None, supplier_lower, leverancier).ratio()
        if similarity > best_score:
            best_score = similarity
            best_match = row
    
    if best_match is not None:
        return {
            'type_maatregel': str(best_match['type maatregel']) if pd.notna(best_match['type maatregel']) else '',
            'omschrijving': str(best_match['omschrijving']) if pd.notna(best_match['omschrijving']) else ''
        }
    
    return None


def prompt_type_maatregel(pdf_path: Optional[str] = None, current: int = 0, total: int = 0) -> str:
    """
    Vraag gebruiker om type maatregel met meerkeuze menu.
    
    Args:
        pdf_path: Pad naar PDF bestand
        current: Huidige factuur nummer (1-based)
        total: Totaal aantal facturen dat prompts verwacht
    """
    if pdf_path:
        abs_path = os.path.abspath(pdf_path)
        print(f"\n📄 PDF: {abs_path}")
        # Probeer PDF te openen in browser/viewer (negeer errors)
        try:
            webbrowser.open(f"file:///{abs_path.replace(os.sep, '/')}", new=0)
        except Exception:
            pass  # Negeer errors (bijv. "There is already an instance running!")
    
    # Toon voortgang
    if total > 0:
        print(f"\n📊 Voortgang: {current}/{total} facturen verwerkt ({total - current} nog te gaan)")
    
    print("\nType maatregel:")
    print("  1. Kosten aanschaf en onderhoud sportmaterialen")
    print("  2. Kosten algemene bouw en onderhoudsmaatregelen")
    print("  3. duurzaamheid maatregel")
    print("  (Enter) geen maatregel")
    
    choice = input("\nKies optie (1-3 of Enter): ").strip()
    
    type_map = {
        '1': 'Kosten aanschaf en onderhoud sportmaterialen',
        '2': 'Kosten algemene bouw en onderhoudsmaatregelen',
        '3': 'duurzaamheid maatregel',
        '': ''  # Enter = leeg
    }
    
    return type_map.get(choice, '')


def prompt_user_input(prompt_text: str, pdf_path: Optional[str] = None, current: int = 0, total: int = 0) -> str:
    """
    Vraag gebruiker om input. Toon PDF pad als beschikbaar.
    Enter zonder input = lege string.
    
    Args:
        prompt_text: Tekst van de prompt
        pdf_path: Pad naar PDF bestand
        current: Huidige factuur nummer (1-based)
        total: Totaal aantal facturen dat prompts verwacht
    """
    if pdf_path:
        abs_path = os.path.abspath(pdf_path)
        print(f"\n📄 PDF: {abs_path}")
        # Probeer PDF te openen in browser/viewer (negeer errors)
        try:
            webbrowser.open(f"file:///{abs_path.replace(os.sep, '/')}", new=0)
        except Exception:
            pass  # Negeer errors (bijv. "There is already an instance running!")
    
    # Toon voortgang
    if total > 0:
        print(f"\n📊 Voortgang: {current}/{total} facturen verwerkt ({total - current} nog te gaan)")
    
    user_input = input(f"{prompt_text} (Enter voor leeg): ").strip()
    return user_input


# ============================================================================
# BANK CSV PARSING
# ============================================================================

def detect_separator(filepath: str) -> str:
    """
    Detecteer automatisch de separator door eerste regel te analyseren.
    """
    try:
        with open(filepath, 'r', encoding='latin1') as f:
            # Lees eerste paar regels voor betere detectie
            lines = [f.readline() for _ in range(min(5, 5))]
            if not lines or not lines[0]:
                return ','  # Default naar komma
            
            first_line = lines[0]
            # Verwijder BOM als die er is
            if first_line.startswith('\ufeff'):
                first_line = first_line[1:]
            
            # Tel verschillende separators in eerste regel
            semicolon_count = first_line.count(';')
            comma_count = first_line.count(',')
            tab_count = first_line.count('\t')
            
            # Als er veel komma's zijn, check of het niet bedragen zijn (1.234,56)
            # Tel alleen komma's die niet tussen cijfers staan
            real_comma_count = len(re.findall(r',(?![0-9])', first_line))
            real_semicolon_count = len(re.findall(r';(?![0-9])', first_line))
            
            # Kies separator met meeste voorkomens (prioriteit: ; > , > \t)
            # Maar als komma veel voorkomt en puntkomma niet, gebruik komma
            if real_semicolon_count > max(real_comma_count, tab_count, 3):
                return ';'
            elif real_comma_count > max(tab_count, 3):
                return ','
            elif tab_count > 3:
                return '\t'
            elif comma_count > semicolon_count:
                return ','
            elif semicolon_count > 0:
                return ';'
            else:
                return ','  # Default naar komma
    except Exception:
        return ','  # Default fallback naar komma


def parse_bank_csv(filepath: str) -> pd.DataFrame:
    """
    Parse bank.csv met fixed kolom posities.
    CRUCIAAL: Gebruik header=None en hardcode indexen!
    Separator wordt automatisch gedetecteerd (komma of puntkomma).
    """
    print(f"📂 Bank CSV lezen: {filepath}")
    
    if not os.path.exists(filepath):
        print(f"❌ Bestand niet gevonden: {filepath}")
        return pd.DataFrame()
    
    try:
        # Detecteer separator (standaard komma, maar kan ook ; zijn)
        separator = detect_separator(filepath)
        print(f"🔍 Separator gedetecteerd: '{separator}' (repr: {repr(separator)})")
        
        # Als detectie faalt, probeer beide
        if separator == ',':
            print("   → Gebruikt komma (,) als separator")
        elif separator == ';':
            print("   → Gebruikt puntkomma (;) als separator")
        
        # Lees zonder header, latin1 encoding
        # Verwijder BOM door skipinitialspace of door eerste regel te lezen
        try:
            df = pd.read_csv(
                filepath,
                sep=separator,
                header=None,
                encoding='latin1',
                on_bad_lines='skip',
                engine='python',
                skipinitialspace=True
            )
        except (TypeError, ValueError) as e:
            # Fallback voor oudere pandas of andere problemen
            print(f"⚠️  Probeer alternatieve methode: {e}")
            try:
                # Probeer met csv module eerst om BOM te verwijderen
                import csv
                import io
                
                with open(filepath, 'r', encoding='latin1') as f:
                    content = f.read()
                    # Verwijder BOM
                    if content.startswith('\ufeff'):
                        content = content[1:]
                    
                    # Parse met csv module
                    reader = csv.reader(io.StringIO(content), delimiter=separator)
                    rows = list(reader)
                    
                    # Converteer naar DataFrame
                    df = pd.DataFrame(rows)
            except Exception as e2:
                print(f"❌ Fout bij alternatieve parsing: {e2}")
                # Laatste poging: probeer met None separator (auto-detect)
                df = pd.read_csv(
                    filepath,
                    sep=None,
                    header=None,
                    encoding='latin1',
                    engine='python',
                    on_bad_lines='skip'
                )
        
        print(f"✅ {len(df)} rijen gelezen, {df.shape[1]} kolommen gedetecteerd")
        
        # Debug: toon eerste regel
        if len(df) > 0:
            print(f"🔍 Eerste regel preview: {df.iloc[0].tolist()[:5]}...")
        
        # Check of we genoeg kolommen hebben
        min_cols_needed = max(BANK_COL_DATE, BANK_COL_AMOUNT, BANK_COL_DESC) + 1
        if df.shape[1] < min_cols_needed:
            print(f"⚠️  Waarschuwing: Te weinig kolommen ({df.shape[1]}, nodig: {min_cols_needed})")
            print(f"🔍 Probeer alle kolommen te gebruiken...")
            # Als we te weinig kolommen hebben, probeer dan alle beschikbare kolommen
            # Pas kolom indices aan
            actual_cols = df.shape[1]
            if actual_cols > 0:
                # Gebruik beschikbare kolommen als fallback
                date_col = min(BANK_COL_DATE, actual_cols - 1)
                amount_col = min(BANK_COL_AMOUNT, actual_cols - 1)
                desc_col = min(BANK_COL_DESC, actual_cols - 1)
                print(f"🔧 Aangepaste kolommen: datum={date_col}, bedrag={amount_col}, omschrijving={desc_col}")
            else:
                print(f"❌ Geen kolommen gevonden!")
                return pd.DataFrame()
        else:
            date_col = BANK_COL_DATE
            amount_col = BANK_COL_AMOUNT
            desc_col = BANK_COL_DESC
        
        # Extract relevante kolommen met hardcoded indexen
        bank_data = []
        for idx, row in df.iterrows():
            try:
                # Haal waarden op met .iloc voor veiligheid
                if len(row) <= max(date_col, amount_col, desc_col):
                    continue
                
                date_str = str(row.iloc[date_col]) if len(row) > date_col else ""
                amount_str = str(row.iloc[amount_col]) if len(row) > amount_col else ""
                desc = str(row.iloc[desc_col]) if len(row) > desc_col else ""
                
                # Field86 is laatste kolom
                field86 = ""
                if len(row) > 0:
                    try:
                        field86 = str(row.iloc[-1])
                    except (IndexError, AttributeError):
                        pass
                
                # Skip lege rijen
                if not date_str.strip() and not amount_str.strip():
                    continue
                
                # Parse datum
                date = parse_date_flexible(date_str)
                
                # Parse bedrag (NL notatie)
                amount = parse_nl_amount(amount_str)
                
                # Maak bedrag positief (banktransacties zijn vaak negatief)
                if amount is not None:
                    amount = abs(amount)
                
                # Combineer omschrijvingen
                full_desc = f"{desc} {field86}".strip()
                
                if date and amount is not None:
                    bank_data.append({
                        'datum': date,
                        'bedrag': amount,  # Altijd positief
                        'omschrijving': clean_text(full_desc),
                        'raw_date': date_str,
                        'raw_amount': amount_str,
                    })
                elif amount is not None:  # Accepteer ook zonder datum
                    bank_data.append({
                        'datum': None,
                        'bedrag': amount,  # Altijd positief
                        'omschrijving': clean_text(full_desc),
                        'raw_date': date_str,
                        'raw_amount': amount_str,
                    })
            except (IndexError, ValueError, AttributeError) as e:
                # Skip corrupte rijen
                continue
        
        result_df = pd.DataFrame(bank_data)
        print(f"✅ {len(result_df)} geldige transacties geparsed")
        
        if len(result_df) == 0 and len(df) > 0:
            print(f"⚠️  Geen transacties geparsed, maar {len(df)} rijen gelezen")
            print(f"🔍 Debug: eerste paar rijen:")
            for i in range(min(3, len(df))):
                print(f"  Rij {i}: {df.iloc[i].tolist()[:10]}")
        
        return result_df
        
    except Exception as e:
        print(f"❌ Fout bij lezen bank.csv: {e}")
        import traceback
        traceback.print_exc()
        return pd.DataFrame()


# ============================================================================
# PDF EXTRACTION
# ============================================================================

def extract_pdf_data(pdf_path: str) -> Optional[Dict]:
    """
    Extract factuurnummer en bedrag uit PDF.
    """
    print(f"  📄 {Path(pdf_path).name}...", end=" ")
    
    try:
        doc = fitz.open(pdf_path)
        full_text = ""
        
        # Lees alle pagina's
        for page_num in range(len(doc)):
            page = doc[page_num]
            full_text += page.get_text() + "\n"
        
        doc.close()
        
        if not full_text.strip():
            print("❌ Lege PDF")
            return None
        
        # Extract factuurnummer
        invoice_num = extract_invoice_number(full_text, Path(pdf_path).name)
        if not invoice_num:
            # Probeer ook filename
            invoice_num = extract_invoice_number(Path(pdf_path).stem)
        
        # Extract bedrag
        amount = extract_amount_from_text(full_text)
        
        # Extract leverancier
        supplier = extract_supplier_name(full_text, Path(pdf_path).name)
        
        # Extract factuurdatum
        invoice_date = extract_invoice_date(full_text)
        
        # Extract omschrijving werkzaamheden
        work_description = extract_work_description(full_text)
        
        # Tekst preview (eerste 200 karakters)
        text_preview = clean_text(full_text[:200])
        
        if invoice_num:
            if invoice_date and pd.notna(invoice_date):
                try:
                    date_str = invoice_date.strftime('%d-%m-%Y')
                except (AttributeError, ValueError):
                    date_str = str(invoice_date) if invoice_date else "Geen datum"
            else:
                date_str = "Geen datum"
            print(f"✅ {invoice_num} (€{amount:.2f}, {date_str})" if amount else f"✅ {invoice_num} ({date_str})")
        else:
            print("⚠️  Geen factuurnummer gevonden")
        
        return {
            'pdf': Path(pdf_path).name,
            'factuurnummer': invoice_num,
            'bedrag_eur': amount,
            'leverancier': supplier,
            'factuurdatum': invoice_date,
            'werkzaamheden': work_description,
            'tekst_preview': text_preview,
        }
        
    except Exception as e:
        print(f"❌ Fout: {e}")
        return None


def move_processed_file(filepath: str, has_match: bool = True) -> None:
    """
    Verplaats een verwerkt bestand naar de juiste map.
    - has_match=True: verplaats naar verwerkt/
    - has_match=False: verplaats naar geen match/
    """
    try:
        source = Path(filepath)
        if not source.exists():
            return
        
        # Bepaal doelmap
        if has_match:
            target_dir = Path(PROCESSED_DIR)
            target_name = "verwerkt"
        else:
            target_dir = Path(NO_MATCH_DIR)
            target_name = "geen match"
        
        # Maak map aan als die niet bestaat
        target_dir.mkdir(exist_ok=True)
        
        # Verplaats naar doelmap
        destination = target_dir / source.name
        
        # Als bestand al bestaat, voeg timestamp toe
        if destination.exists():
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            stem = source.stem
            suffix = source.suffix
            destination = target_dir / f"{stem}_{timestamp}{suffix}"
        
        # Verplaats bestand
        source.rename(destination)
        print(f"   📦 Verplaatst naar: {target_name}/")
        
    except Exception as e:
        print(f"   ⚠️  Kon bestand niet verplaatsen: {e}")


def process_all_pdfs() -> List[Dict]:
    """
    Process alle PDF's in de huidige map.
    Retourneert lijst van invoices (zonder bestanden te verplaatsen).
    """
    pdf_files = glob.glob(PDF_PATTERN)
    
    # Filter uit verwerkt en geen match mappen
    pdf_files = [f for f in pdf_files 
                 if not f.startswith(PROCESSED_DIR) and not f.startswith(NO_MATCH_DIR)]
    
    if not pdf_files:
        print(f"⚠️  Geen PDF bestanden gevonden met pattern: {PDF_PATTERN}")
        return []
    
    print(f"\n📚 {len(pdf_files)} PDF's gevonden\n")
    
    invoices = []
    for pdf_path in sorted(pdf_files):
        data = extract_pdf_data(pdf_path)
        if data:
            invoices.append(data)
        # Bestanden worden later verplaatst na matching
    
    print(f"\n✅ {len(invoices)} PDF's succesvol verwerkt")
    return invoices


# ============================================================================
# MATCHING LOGICA
# ============================================================================

def match_invoice_to_bank(invoice: Dict, bank_df: pd.DataFrame) -> Optional[Dict]:
    """
    Match een factuur met een banktransactie op basis van factuurnummer.
    Returns de beste match of None.
    Verbeterd: ondersteunt partial matches, bestandsnaam matching, en meerdere facturen in één betaling.
    """
    invoice_num = invoice.get('factuurnummer')
    invoice_amount = invoice.get('bedrag_eur')
    pdf_filename = invoice.get('pdf', '')
    
    # Als geen factuurnummer uit PDF, probeer uit bestandsnaam te extraheren
    if not invoice_num and pdf_filename:
        invoice_num = extract_invoice_number(pdf_filename, pdf_filename)
        if invoice_num:
            # Update invoice dict met factuurnummer uit bestandsnaam
            invoice['factuurnummer'] = invoice_num
    
    if not invoice_num:
        return None
    
    # Zoek transacties waar factuurnummer in omschrijving staat
    invoice_num_upper = invoice_num.upper()
    
    # Probeer verschillende matching strategieën
    matches = pd.DataFrame()
    
    # 1. Exacte match (volledige nummer)
    escaped_num = re.escape(invoice_num_upper)
    mask_exact = bank_df['omschrijving'].str.upper().str.contains(
        escaped_num, case=False, na=False, regex=True
    )
    matches_exact = bank_df[mask_exact].copy()
    
    # 2. Partial match (laatste 6+ cijfers van factuurnummer)
    matches_partial = pd.DataFrame()
    if len(invoice_num) >= 6:
        last_digits = invoice_num[-6:]
        mask_partial = bank_df['omschrijving'].str.contains(
            last_digits, case=False, na=False, regex=False
        )
        matches_partial = bank_df[mask_partial].copy()
    
    # 3. Match op bestandsnaam (als factuurnummer niet direct gevonden)
    matches_filename = pd.DataFrame()
    if pdf_filename:
        # Extract alle mogelijke nummers uit bestandsnaam
        filename_upper = pdf_filename.upper()
        # Zoek naar nummers in bestandsnaam
        filename_numbers = re.findall(r'\d{4,}', filename_upper)
        for num in filename_numbers:
            if len(num) >= 4:
                mask_fn = bank_df['omschrijving'].str.contains(
                    num, case=False, na=False, regex=False
                )
                matches_fn = bank_df[mask_fn].copy()
                if not matches_fn.empty:
                    matches_filename = pd.concat([matches_filename, matches_fn]).drop_duplicates()
    
    # Combineer alle matches (exact heeft prioriteit)
    all_matches = []
    if not matches_exact.empty:
        all_matches.append(matches_exact)
    if not matches_partial.empty:
        all_matches.append(matches_partial)
    if not matches_filename.empty:
        all_matches.append(matches_filename)
    
    if all_matches:
        matches = pd.concat(all_matches).drop_duplicates()
    else:
        matches = pd.DataFrame()
    
    if matches.empty:
        return None
    
    # Filter op bedrag (binnen 5% tolerance)
    # Bank bedragen zijn al positief gemaakt in parse_bank_csv
    if invoice_amount:
        matches['verschil_abs'] = abs(matches['bedrag'] - abs(invoice_amount))
        matches['verschil_pct'] = matches['verschil_abs'] / abs(invoice_amount)
        matches = matches[matches['verschil_pct'] <= AMOUNT_TOLERANCE]
        
        if matches.empty:
            return None
        
        # Sorteer op beste match (exacte match heeft prioriteit, dan kleinste verschil)
        matches['is_exact'] = matches.index.isin(matches_exact.index)
        matches['is_partial'] = matches.index.isin(matches_partial.index)
        matches = matches.sort_values(
            ['is_exact', 'is_partial', 'verschil_pct'], 
            ascending=[False, False, True]
        )
    
    # Neem de beste match
    best_match = matches.iloc[0]
    
    # Probeer leverancier uit bank omschrijving te halen als fallback
    supplier_name = invoice.get('leverancier', '')
    bank_omschrijving = best_match['omschrijving']
    
    # Als leverancier niet goed is (leeg, te kort, of MMHC Voordaan), probeer bank
    if (not supplier_name or 
        len(supplier_name) < 5 or 
        'mmhc voordaan' in supplier_name.lower() or
        supplier_name.lower() in ['factuur', 'invoice']):
        supplier_from_bank = extract_supplier_name_from_bank(bank_omschrijving)
        if supplier_from_bank:
            supplier_name = supplier_from_bank
    
    return {
        'pdf': invoice['pdf'],
        'factuurnummer': invoice_num,
        'pdf_bedrag': invoice_amount,
        'factuurdatum': invoice.get('factuurdatum'),
        'werkzaamheden': invoice.get('werkzaamheden', ''),
        'bank_datum': best_match['datum'],
        'bank_bedrag': best_match['bedrag'],
        'verschil': abs(best_match['bedrag'] - invoice_amount) if invoice_amount else None,
        'bank_omschrijving': bank_omschrijving,
        'leverancier': supplier_name,  # Update met beste leveranciersnaam
    }


def match_invoice_by_amount(invoice: Dict, bank_df: pd.DataFrame, exclude_dates: List[datetime] = None, exact_only: bool = True) -> Optional[pd.DataFrame]:
    """
    Match een factuur met een banktransactie alleen op bedrag.
    Excludeert al gematchte datums.
    Returns DataFrame met mogelijke matches of None.
    
    Args:
        exact_only: Als True, alleen exacte matches (0.0% verschil). Als False, binnen 5% tolerance.
    """
    invoice_amount = invoice.get('bedrag_eur')
    
    if not invoice_amount:
        return None
    
    # Filter op bedrag
    bank_df = bank_df.copy()
    bank_df['verschil_abs'] = abs(bank_df['bedrag'] - abs(invoice_amount))
    bank_df['verschil_pct'] = bank_df['verschil_abs'] / abs(invoice_amount)
    
    if exact_only:
        # Alleen exacte matches (0.0% verschil, met kleine rounding tolerance)
        matches = bank_df[bank_df['verschil_pct'] < 0.001].copy()  # < 0.1% = praktisch exact
    else:
        matches = bank_df[bank_df['verschil_pct'] <= AMOUNT_TOLERANCE].copy()
    
    # Excludeer al gematchte datums
    if exclude_dates:
        matches = matches[~matches['datum'].isin(exclude_dates)]
    
    if matches.empty:
        return None
    
    # Sorteer op beste match (kleinste verschil)
    matches = matches.sort_values('verschil_pct')
    
    return matches


def select_bank_match(matches: pd.DataFrame, invoice: Dict) -> Optional[pd.Series]:
    """
    Laat gebruiker kiezen uit meerdere bank matches.
    Returns gekozen match of None.
    Toont alleen exacte matches (0.0% verschil).
    """
    if len(matches) == 1:
        return matches.iloc[0]
    
    # Filter alleen exacte matches (0.0% verschil)
    exact_matches = matches[matches['verschil_pct'] < 0.001].copy()
    
    if exact_matches.empty:
        # Geen exacte matches, maar we hebben matches (binnen tolerance)
        # Toon alleen als er maar 1 is
        if len(matches) == 1:
            return matches.iloc[0]
        return None
    
    if len(exact_matches) == 1:
        return exact_matches.iloc[0]
    
    print(f"\n📋 Meerdere exacte matches gevonden voor {invoice.get('pdf')} (€{invoice.get('bedrag_eur', 0):.2f}):")
    print()
    
    for idx, (_, match) in enumerate(exact_matches.iterrows(), 1):
        # Check of datum geldig is (niet NaT of None)
        match_datum = match.get('datum')
        if match_datum and pd.notna(match_datum):
            try:
                date_str = match_datum.strftime('%d-%m-%Y')
            except (AttributeError, ValueError):
                date_str = str(match_datum) if match_datum else 'Geen datum'
        else:
            date_str = 'Geen datum'
        verschil_pct = match['verschil_pct'] * 100
        print(f"  {idx}. {date_str} - €{match['bedrag']:.2f} ({verschil_pct:.1f}% verschil)")
        print(f"     Omschrijving: {match['omschrijving'][:60]}...")
    
    print(f"  0. Geen match")
    print()
    
    while True:
        try:
            choice = input("Kies een optie (0-{}): ".format(len(exact_matches))).strip()
            if choice == '0':
                return None
            choice_num = int(choice)
            if 1 <= choice_num <= len(exact_matches):
                return exact_matches.iloc[choice_num - 1]
            else:
                print("❌ Ongeldige keuze, probeer opnieuw.")
        except (ValueError, IndexError):
            print("❌ Ongeldige keuze, probeer opnieuw.")


# ============================================================================
# MAIN
# ============================================================================

def enrich_match_with_leverancier(match: Dict, invoice: Dict, leveranciers_df: pd.DataFrame, pdf_path: Optional[str] = None, current: int = 0, total: int = 0) -> Dict:
    """
    Verrijk match met leveranciersinformatie.
    Vraag eerst om leveranciersnaam als niet gevonden, probeer dan opnieuw te matchen.
    Gebruikt bank omschrijving als fallback voor leveranciersnaam.
    
    Args:
        match: Match dictionary
        invoice: Invoice dictionary
        leveranciers_df: Leveranciers DataFrame
        pdf_path: Pad naar PDF bestand
        current: Huidige factuur nummer (1-based)
        total: Totaal aantal facturen dat prompts verwacht
    """
    supplier_name = invoice.get('leverancier', '')
    
    # Probeer leverancier uit bank omschrijving te halen als PDF extractie niet goed is
    bank_omschrijving = match.get('bank_omschrijving', '')
    supplier_from_bank = None
    
    if bank_omschrijving:
        supplier_from_bank = extract_supplier_name_from_bank(bank_omschrijving)
        if supplier_from_bank:
            # Check of bank leverancier beter is (langer, meer specifiek)
            if (not supplier_name or 
                len(supplier_from_bank) > len(supplier_name) or 
                'mmhc voordaan' in supplier_name.lower()):
                supplier_name = supplier_from_bank
                print(f"📋 Leverancier uit bank omschrijving: {supplier_name}")
    
    # Vind PDF pad eerst (voor prompts)
    if not pdf_path:
        pdf_files = glob.glob(PDF_PATTERN)
        pdf_files = [f for f in pdf_files 
                    if not f.startswith(PROCESSED_DIR) and not f.startswith(NO_MATCH_DIR)]
        for pf in pdf_files:
            if Path(pf).name == invoice.get('pdf'):
                pdf_path = pf
                break
    
    # Zoek leverancier in tabel
    leverancier_info = fuzzy_match_leverancier(supplier_name, leveranciers_df)
    
    if leverancier_info:
        type_maatregel = leverancier_info['type_maatregel']
        omschrijving = leverancier_info['omschrijving']
    else:
        # Leverancier niet gevonden, vraag eerst om leveranciersnaam
        print(f"\n❓ Leverancier niet gevonden: {supplier_name}")
        if supplier_from_bank and supplier_from_bank != supplier_name:
            print(f"   (Gevonden in bank: {supplier_from_bank}, maar niet in leveranciers tabel)")
        
        # Open PDF en vraag om leveranciersnaam
        if pdf_path:
            abs_path = os.path.abspath(pdf_path)
            print(f"\n📄 PDF: {abs_path}")
            try:
                webbrowser.open(f"file:///{abs_path.replace(os.sep, '/')}", new=0)
            except Exception:
                pass
        
        if total > 0:
            print(f"\n📊 Voortgang: {current}/{total} facturen verwerkt ({total - current} nog te gaan)")
        
        user_supplier_name = input("Leveranciersnaam (Enter om huidige naam te behouden): ").strip()
        
        # Als gebruiker een naam heeft ingevoerd, probeer opnieuw te matchen
        if user_supplier_name:
            supplier_name = user_supplier_name
            print(f"   → Opnieuw zoeken met: {supplier_name}")
            leverancier_info = fuzzy_match_leverancier(supplier_name, leveranciers_df)
        
        # Als nu wel gevonden, gebruik die informatie
        if leverancier_info:
            type_maatregel = leverancier_info['type_maatregel']
            omschrijving = leverancier_info['omschrijving']
            print(f"✅ Leverancier gevonden in tabel!")
        else:
            # Nog steeds niet gevonden, vraag type maatregel en omschrijving
            print(f"   → Nog steeds niet gevonden, vragen om type maatregel en omschrijving...")
            # Open PDF en vraag type maatregel (meerkeuze menu)
            type_maatregel = prompt_type_maatregel(pdf_path, current, total)
            # Open PDF opnieuw en vraag omschrijving
            omschrijving = prompt_user_input("Omschrijving werkzaamheden: ", pdf_path, current, total)
    
    match['type_maatregel'] = type_maatregel
    match['leverancier'] = supplier_name  # Gebruik beste leveranciersnaam (PDF, bank, of gebruiker input)
    match['werkzaamheden'] = omschrijving  # Overschrijf PDF omschrijving
    
    return match


def suggest_leveranciers_to_add(supplier_pdf_map: Dict[str, List[str]], leveranciers_df: pd.DataFrame, matches: List[Dict]) -> None:
    """
    Detecteer leveranciers met meerdere PDF's die niet in leveranciers.xlsx staan.
    Stel voor om deze toe te voegen.
    """
    suggestions = []
    
    for supplier, pdfs in supplier_pdf_map.items():
        # Skip als leverancier al in leveranciers.xlsx staat
        leverancier_info = fuzzy_match_leverancier(supplier, leveranciers_df)
        if leverancier_info:
            continue
        
        # Skip als leverancier te kort of MMHC Voordaan
        if len(supplier) < 3 or 'mmhc voordaan' in supplier.lower():
            continue
        
        # Tel hoeveel PDF's van deze leverancier gematcht zijn
        matched_count = sum(1 for match in matches if match.get('leverancier', '').lower() == supplier.lower())
        
        # Als 2+ PDF's van deze leverancier, stel voor om toe te voegen
        if len(pdfs) >= 2 or matched_count >= 2:
            suggestions.append({
                'leverancier': supplier,
                'aantal_pdfs': len(pdfs),
                'gematcht': matched_count,
                'pdfs': pdfs[:5]  # Eerste 5 PDF's als voorbeeld
            })
    
    if suggestions:
        print("\n" + "=" * 70)
        print("💡 SUGGESTIES: Leveranciers om toe te voegen aan leveranciers.xlsx")
        print("=" * 70)
        print()
        print("De volgende leveranciers hebben meerdere facturen maar staan niet in leveranciers.xlsx:")
        print()
        
        for idx, suggestion in enumerate(suggestions, 1):
            print(f"{idx}. {suggestion['leverancier']}")
            print(f"   → {suggestion['aantal_pdfs']} PDF's gevonden, {suggestion['gematcht']} gematcht")
            print(f"   → Voorbeelden: {', '.join(suggestion['pdfs'])}")
            print()
        
        print("Wil je deze leveranciers toevoegen aan leveranciers.xlsx?")
        print("(Dit voorkomt toekomstige prompts voor deze leveranciers)")
        choice = input("Toevoegen? (j/n): ").strip().lower()
        
        if choice in ['j', 'ja', 'y', 'yes']:
            # Laad bestaande leveranciers.xlsx
            if os.path.exists(LEVERANCIERS_XLSX):
                try:
                    df = pd.read_excel(LEVERANCIERS_XLSX, engine='openpyxl')
                    df.columns = df.columns.str.strip().str.lower()
                except:
                    df = pd.DataFrame(columns=['leverancier', 'type maatregel', 'omschrijving'])
            else:
                df = pd.DataFrame(columns=['leverancier', 'type maatregel', 'omschrijving'])
            
            # Voeg nieuwe leveranciers toe
            for suggestion in suggestions:
                supplier = suggestion['leverancier']
                # Check of niet al bestaat
                if supplier.lower() not in df['leverancier'].str.lower().values:
                    new_row = pd.DataFrame([{
                        'leverancier': supplier,
                        'type maatregel': None,
                        'omschrijving': None
                    }])
                    df = pd.concat([df, new_row], ignore_index=True)
                    print(f"✅ {supplier} toegevoegd aan leveranciers.xlsx")
            
            # Sla op
            df.to_excel(LEVERANCIERS_XLSX, index=False, engine='openpyxl')
            print(f"\n✅ {len(suggestions)} leveranciers toegevoegd aan {LEVERANCIERS_XLSX}")
            print()


def load_existing_matches() -> set:
    """
    Laad bestaande matches uit matches_final.xlsx om dubbele verwerking te voorkomen.
    Returns set van PDF namen die al gematcht zijn.
    """
    if not os.path.exists('matches_final.xlsx'):
        return set()
    
    try:
        df = pd.read_excel('matches_final.xlsx', engine='openpyxl')
        if 'pdf' in df.columns:
            existing_pdfs = set(df['pdf'].dropna().astype(str))
            print(f"✅ {len(existing_pdfs)} bestaande matches gevonden in matches_final.xlsx")
            return existing_pdfs
    except Exception as e:
        print(f"⚠️  Kon bestaande matches niet laden: {e}")
    
    return set()


def main():
    print("=" * 70)
    print("🔍 FACTUUR-BANK MATCHING SCRIPT")
    print("=" * 70)
    print()
    
    # 0. Laad bestaande matches
    existing_matches = load_existing_matches()
    print()
    
    # 0. Laad leveranciers
    leveranciers_df = load_leveranciers()
    print()
    
    # 1. Parse bank.csv
    if not os.path.exists(BANK_CSV):
        print(f"❌ {BANK_CSV} niet gevonden!")
        return
    
    bank_df = parse_bank_csv(BANK_CSV)
    if bank_df.empty:
        print("❌ Geen banktransacties gevonden!")
        return
    
    print()
    
    # 2. Process PDF's
    invoices = process_all_pdfs()
    if not invoices:
        print("❌ Geen facturen gevonden!")
        return
    
    # Filter bestaande matches
    if existing_matches:
        original_count = len(invoices)
        invoices = [inv for inv in invoices if inv['pdf'] not in existing_matches]
        filtered_count = original_count - len(invoices)
        if filtered_count > 0:
            print(f"⏭️  {filtered_count} facturen overgeslagen (al in matches_final.xlsx)")
            print()
    
    if not invoices:
        print("⚠️  Alle facturen zijn al verwerkt!")
        return
    
    print()
    
    # 2b. Laad grootboek betalingen eerst
    print("📊 Laad betalingen uit grootboek...\n")
    grootboek_betalingen = load_grootboek_betalingen()
    print()
    
    # 2c. Maak geïntegreerde lijst van betalingen (grootboek + bank)
    print("📊 Maak geïntegreerde lijst van betalingen...\n")
    integrated_payments = create_integrated_payment_list(bank_df, grootboek_betalingen)
    if integrated_payments.empty:
        print("⚠️  Geïntegreerde lijst is leeg, gebruik alleen bank transacties")
    print()
    
    # 3. Matching met geïntegreerde lijst
    print("🔗 Matching facturen met geïntegreerde betalingslijst...\n")
    print("(Matching op: factuurnummer, bedrag+leverancier, bestandsnaam)\n")
    matches = []
    matched_pdfs = set()  # Track welke PDF's een match hebben
    invoice_dict = {inv['pdf']: inv for inv in invoices}  # Voor snelle lookup
    
    # Track leveranciers per PDF voor suggesties
    supplier_pdf_map = {}  # {leverancier: [pdf1, pdf2, ...]}
    
    # Bepaal hoeveel facturen prompts verwachten (leverancier niet gevonden)
    leveranciers_need_prompt = []
    for invoice in invoices:
        supplier_name = invoice.get('leverancier', '')
        leverancier_info = fuzzy_match_leverancier(supplier_name, leveranciers_df)
        if not leverancier_info:
            leveranciers_need_prompt.append(invoice['pdf'])
        
        # Track leveranciers voor suggesties
        if supplier_name and len(supplier_name) > 3:
            if supplier_name not in supplier_pdf_map:
                supplier_pdf_map[supplier_name] = []
            supplier_pdf_map[supplier_name].append(invoice['pdf'])
    
    total_prompts = len(leveranciers_need_prompt)
    current_prompt = 0
    
    for invoice in invoices:
        # Sla origineel factuurnummer op voor vergelijking
        original_invoice_num = invoice.get('factuurnummer')
        
        # Probeer eerst nieuwe geïntegreerde matching
        match = match_invoice_to_integrated_list(invoice, integrated_payments, bank_df)
        
        # Fallback naar oude methode als nieuwe geen match geeft
        if not match:
            match = match_invoice_to_bank(invoice, bank_df)
        if match:
            matched_pdfs.add(invoice['pdf'])
            # Check of bank_datum geldig is (niet NaT of None)
            bank_datum = match.get('bank_datum')
            if bank_datum and pd.notna(bank_datum):
                try:
                    date_str = bank_datum.strftime('%d-%m-%Y')
                except (AttributeError, ValueError):
                    date_str = str(bank_datum) if bank_datum else 'Geen datum'
            else:
                date_str = 'Geen datum'
            # Toon of match via bestandsnaam kwam
            match_source = "bestandsnaam" if not original_invoice_num else "PDF"
            print(f"✅ {invoice['pdf']} → {date_str} (€{match['bank_bedrag']:.2f}) [{match_source}]")
            
            # Verrijk met leveranciersinformatie
            pdf_path = None
            pdf_files = glob.glob(PDF_PATTERN)
            pdf_files = [f for f in pdf_files 
                        if not f.startswith(PROCESSED_DIR) and not f.startswith(NO_MATCH_DIR)]
            for pf in pdf_files:
                if Path(pf).name == invoice.get('pdf'):
                    pdf_path = pf
                    break
            
            # Update invoice met leverancier uit match (als die beter is)
            if match.get('leverancier') and match['leverancier'] != invoice.get('leverancier', ''):
                invoice['leverancier'] = match['leverancier']
                # Herbereken of prompt nodig is
                leverancier_info = fuzzy_match_leverancier(match['leverancier'], leveranciers_df)
                needs_prompt = not leverancier_info
                if needs_prompt and invoice['pdf'] not in leveranciers_need_prompt:
                    leveranciers_need_prompt.append(invoice['pdf'])
                    total_prompts += 1
                elif not needs_prompt and invoice['pdf'] in leveranciers_need_prompt:
                    leveranciers_need_prompt.remove(invoice['pdf'])
                    total_prompts = max(0, total_prompts - 1)
            else:
                # Check of deze factuur prompts verwacht
                needs_prompt = invoice['pdf'] in leveranciers_need_prompt
            
            if needs_prompt:
                current_prompt += 1
            
            match = enrich_match_with_leverancier(
                match, invoice, leveranciers_df, pdf_path, 
                current=current_prompt if needs_prompt else 0,
                total=total_prompts
            )
            matches.append(match)
        else:
            # Debug: toon waarom geen match
            invoice_num = invoice.get('factuurnummer')
            if not invoice_num:
                print(f"❌ {invoice['pdf']} → Geen factuurnummer gevonden (ook niet in bestandsnaam)")
            else:
                print(f"❌ {invoice['pdf']} → Geen match (factuurnummer: {invoice_num})")
    
    print()
    
    # 3b. Suggesties voor leveranciers om toe te voegen
    if matches:
        suggest_leveranciers_to_add(supplier_pdf_map, leveranciers_df, matches)
    
    # 4b. Optioneel: Match niet-gematchte facturen op bedrag (alleen exacte matches)
    unmatched_invoices = [inv for inv in invoices if inv['pdf'] not in matched_pdfs]
    
    if unmatched_invoices:
        print("=" * 70)
        print(f"📊 {len(unmatched_invoices)} facturen zonder match gevonden")
        print("=" * 70)
        print()
        print("Wil je proberen deze facturen te matchen op exact bedrag (0.0% verschil)?")
        print("(Alleen exacte bedrag matches worden getoond)")
        print()
        
        continue_choice = input("Doorgaan met exacte bedrag matching? (j/n): ").strip().lower()
        
        if continue_choice in ['j', 'ja', 'y', 'yes']:
            print()
            print("🔗 Matching op exact bedrag (0.0% verschil)...\n")
            
            # Verzamel al gematchte datums om te excluderen
            matched_dates = []
            for match in matches:
                if match.get('bank_datum'):
                    matched_dates.append(match['bank_datum'])
            
            remaining_count = len(unmatched_invoices)
            
            for idx, invoice in enumerate(unmatched_invoices, 1):
                print(f"[{idx}/{remaining_count}] ", end="")
                
                # Check voor "999" om naar laatste stap te gaan
                if idx > 1:  # Alleen na eerste factuur
                    skip_choice = input("(Enter om door te gaan, 999 om naar laatste stap): ").strip()
                    if skip_choice == '999':
                        print("\n⏭️  Naar laatste stap (verplaatsen facturen)...\n")
                        break
                
                invoice_amount = invoice.get('bedrag_eur')
                if not invoice_amount:
                    print(f"⚠️  {invoice['pdf']} → Geen bedrag, overslaan")
                    continue
                
                # Zoek matches op exact bedrag (0.0% verschil)
                amount_matches = match_invoice_by_amount(
                    invoice, bank_df, exclude_dates=matched_dates, exact_only=True
                )
                
                if amount_matches is None or amount_matches.empty:
                    print(f"❌ {invoice['pdf']} → Geen exacte bedrag match (€{invoice_amount:.2f})")
                    continue
                
                # Laat gebruiker kiezen als meerdere matches
                selected_match = select_bank_match(amount_matches, invoice)
                
                if selected_match is None:
                    print(f"⏭️  {invoice['pdf']} → Overgeslagen")
                    continue
                
                # Probeer leverancier uit bank omschrijving te halen als fallback
                supplier_name = invoice.get('leverancier', '')
                bank_omschrijving = selected_match['omschrijving']
                
                # Als leverancier niet goed is, probeer bank
                if (not supplier_name or 
                    len(supplier_name) < 5 or 
                    'mmhc voordaan' in supplier_name.lower() or
                    supplier_name.lower() in ['factuur', 'invoice']):
                    supplier_from_bank = extract_supplier_name_from_bank(bank_omschrijving)
                    if supplier_from_bank:
                        supplier_name = supplier_from_bank
                
                # Maak match dict
                match = {
                    'pdf': invoice['pdf'],
                    'factuurnummer': invoice.get('factuurnummer', ''),
                    'pdf_bedrag': invoice_amount,
                    'factuurdatum': invoice.get('factuurdatum'),
                    'werkzaamheden': invoice.get('werkzaamheden', ''),
                    'bank_datum': selected_match['datum'],
                    'bank_bedrag': selected_match['bedrag'],
                    'verschil': abs(selected_match['bedrag'] - invoice_amount),
                    'bank_omschrijving': bank_omschrijving,
                    'leverancier': supplier_name,  # Update met beste leveranciersnaam
                }
                
                # Verrijk met leveranciersinformatie
                pdf_path = None
                pdf_files = glob.glob(PDF_PATTERN)
                pdf_files = [f for f in pdf_files 
                            if not f.startswith(PROCESSED_DIR) and not f.startswith(NO_MATCH_DIR)]
                for pf in pdf_files:
                    if Path(pf).name == invoice.get('pdf'):
                        pdf_path = pf
                        break
                
                # Bepaal of deze factuur prompts verwacht
                supplier_name = invoice.get('leverancier', '')
                leverancier_info = fuzzy_match_leverancier(supplier_name, leveranciers_df)
                needs_prompt = not leverancier_info
                
                # Tel prompts voor bedrag matching
                if needs_prompt:
                    # Tel hoeveel facturen in deze ronde prompts verwachten
                    bedrag_prompts = sum(1 for inv in unmatched_invoices[:idx] 
                                        if not fuzzy_match_leverancier(inv.get('leverancier', ''), leveranciers_df))
                    bedrag_total_prompts = sum(1 for inv in unmatched_invoices 
                                              if not fuzzy_match_leverancier(inv.get('leverancier', ''), leveranciers_df))
                    current_prompt_num = bedrag_prompts + 1
                else:
                    current_prompt_num = 0
                    bedrag_total_prompts = 0
                
                match = enrich_match_with_leverancier(
                    match, invoice, leveranciers_df, pdf_path,
                    current=current_prompt_num if needs_prompt else 0,
                    total=bedrag_total_prompts if needs_prompt else 0
                )
                matches.append(match)
                matched_pdfs.add(invoice['pdf'])
                matched_dates.append(selected_match['datum'])  # Voeg toe aan exclude lijst
                
                # Check of bank_datum geldig is (niet NaT of None)
                bank_datum = match.get('bank_datum')
                if bank_datum and pd.notna(bank_datum):
                    try:
                        date_str = bank_datum.strftime('%d-%m-%Y')
                    except (AttributeError, ValueError):
                        date_str = str(bank_datum) if bank_datum else 'Geen datum'
                else:
                    date_str = 'Geen datum'
                print(f"✅ {invoice['pdf']} → {date_str} (€{match['bank_bedrag']:.2f})")
            
            print()
    
    print()
    
    # 5. Output Excel bestanden
    print("💾 Excel bestanden schrijven...\n")
    
    # facturen_final.xlsx
    invoices_df = pd.DataFrame(invoices)
    
    # Format factuurdatum als datetime
    if 'factuurdatum' in invoices_df.columns:
        if pd.api.types.is_datetime64_any_dtype(invoices_df['factuurdatum']):
            # Gebruik apply om NaT waarden correct af te handelen
            invoices_df['factuurdatum'] = invoices_df['factuurdatum'].apply(
                lambda x: x.strftime('%d-%m-%Y') if pd.notna(x) else ''
            )
        else:
            invoices_df['factuurdatum'] = invoices_df['factuurdatum'].astype(str).replace('NaT', '')
    
    # Zorg dat alle kolommen bestaan
    required_cols = ['pdf', 'factuurnummer', 'factuurdatum', 'bedrag_eur', 'leverancier', 'werkzaamheden', 'tekst_preview']
    for col in required_cols:
        if col not in invoices_df.columns:
            invoices_df[col] = None
    
    invoices_df = invoices_df[required_cols]
    invoices_df.to_excel('facturen_final.xlsx', index=False, engine='openpyxl')
    print(f"✅ facturen_final.xlsx ({len(invoices_df)} rijen)")
    
    # matches_final.xlsx
    if matches:
        # Laad bestaande matches en voeg nieuwe toe
        if os.path.exists('matches_final.xlsx'):
            try:
                existing_df = pd.read_excel('matches_final.xlsx', engine='openpyxl')
                new_matches_df = pd.DataFrame(matches)
                # Combineer (verwijder duplicaten op basis van PDF naam)
                combined_df = pd.concat([existing_df, new_matches_df]).drop_duplicates(subset=['pdf'], keep='last')
                matches_df = combined_df
                print(f"📊 {len(new_matches_df)} nieuwe matches toegevoegd aan {len(existing_df)} bestaande")
            except Exception as e:
                print(f"⚠️  Kon bestaande matches niet laden, alleen nieuwe worden opgeslagen: {e}")
                matches_df = pd.DataFrame(matches)
        else:
            matches_df = pd.DataFrame(matches)
        
        # Format datums (als het datetime objecten zijn) - alleen voor nieuwe matches
        # Bestaande matches hebben al geformatteerde datums
        if 'bank_datum' in matches_df.columns:
            if pd.api.types.is_datetime64_any_dtype(matches_df['bank_datum']):
                # Gebruik apply om NaT waarden correct af te handelen
                matches_df['bank_datum'] = matches_df['bank_datum'].apply(
                    lambda x: x.strftime('%d-%m-%Y') if pd.notna(x) else ''
                )
            else:
                # Al string formaat of None
                matches_df['bank_datum'] = matches_df['bank_datum'].astype(str).replace('NaT', '').replace('nan', '')
        
        if 'factuurdatum' in matches_df.columns:
            if pd.api.types.is_datetime64_any_dtype(matches_df['factuurdatum']):
                # Gebruik apply om NaT waarden correct af te handelen
                matches_df['factuurdatum'] = matches_df['factuurdatum'].apply(
                    lambda x: x.strftime('%d-%m-%Y') if pd.notna(x) else ''
                )
            else:
                # Al string formaat of None
                matches_df['factuurdatum'] = matches_df['factuurdatum'].astype(str).replace('NaT', '').replace('nan', '')
        
        # Zorg dat alle kolommen bestaan
        if 'type_maatregel' not in matches_df.columns:
            matches_df['type_maatregel'] = ''
        if 'leverancier' not in matches_df.columns:
            matches_df['leverancier'] = ''
        if 'werkzaamheden' not in matches_df.columns:
            matches_df['werkzaamheden'] = ''
        
        # Hernoem kolommen voor duidelijkheid
        matches_df = matches_df.rename(columns={
            'pdf_bedrag': 'factuurbedrag inc. btw',
            'bank_omschrijving': 'bankomschrijving',
            'bank_datum': 'datum bank_datum',
            'werkzaamheden': 'omschrijving werkzaamheden',
            'type_maatregel': 'type maatregel',
            'leverancier': 'naam leverancier'
        })
        
        # Herordenen kolommen in juiste volgorde
        required_cols = [
            'type maatregel',
            'naam leverancier',
            'factuurbedrag inc. btw',
            'factuurnummer',
            'factuurdatum',
            'bankomschrijving',
            'datum bank_datum',
            'bank_bedrag',
            'omschrijving werkzaamheden'
        ]
        
        # Zorg dat alle kolommen bestaan
        for col in required_cols:
            if col not in matches_df.columns:
                matches_df[col] = None
        
        matches_df = matches_df[required_cols]
        matches_df.to_excel('matches_final.xlsx', index=False, engine='openpyxl')
        print(f"✅ matches_final.xlsx ({len(matches_df)} matches)")
    else:
        # Maak leeg bestand
        empty_df = pd.DataFrame(columns=[
            'type maatregel',
            'naam leverancier',
            'factuurbedrag inc. btw',
            'factuurnummer',
            'factuurdatum',
            'bankomschrijving',
            'datum bank_datum',
            'bank_bedrag',
            'omschrijving werkzaamheden'
        ])
        empty_df.to_excel('matches_final.xlsx', index=False, engine='openpyxl')
        print(f"⚠️  matches_final.xlsx (0 matches)")
    
    print()
    
    # 6. Verplaats PDF's naar juiste map (aan het einde)
    print("=" * 70)
    print("📦 PDF's verplaatsen")
    print("=" * 70)
    print()
    print("⚠️  BELANGRIJK: Sluit eerst alle open PDF bestanden voordat je doorgaat!")
    print("   De PDF's moeten gesloten zijn om ze te kunnen verplaatsen.")
    print()
    
    input("Druk op Enter wanneer alle PDF's gesloten zijn...")
    print()
    
    pdf_files = glob.glob(PDF_PATTERN)
    pdf_files = [f for f in pdf_files 
                 if not f.startswith(PROCESSED_DIR) and not f.startswith(NO_MATCH_DIR)]
    
    if not pdf_files:
        print("⚠️  Geen PDF's gevonden om te verplaatsen")
    else:
        print(f"📦 {len(pdf_files)} PDF's verplaatsen...\n")
        
        moved_count = 0
        failed_count = 0
        
        for pdf_path in pdf_files:
            pdf_name = Path(pdf_path).name
            try:
                if pdf_name in matched_pdfs:
                    # Heeft match: verplaats naar verwerkt/
                    move_processed_file(pdf_path, has_match=True)
                    moved_count += 1
                else:
                    # Geen match: verplaats naar geen match/
                    move_processed_file(pdf_path, has_match=False)
                    moved_count += 1
            except Exception as e:
                print(f"   ❌ Kon {pdf_name} niet verplaatsen: {e}")
                failed_count += 1
        
        print()
        print(f"✅ {moved_count} PDF's succesvol verplaatst")
        if failed_count > 0:
            print(f"⚠️  {failed_count} PDF's konden niet verplaatst worden (mogelijk nog open)")
    
    print()
    print("=" * 70)
    print("✅ KLAAR!")
    
    # Toon statistieken over verplaatste bestanden
    if os.path.exists(PROCESSED_DIR):
        processed_count = len(list(Path(PROCESSED_DIR).glob('*.pdf')))
        if processed_count > 0:
            print(f"📦 {processed_count} PDF's met match in: {PROCESSED_DIR}/")
    
    if os.path.exists(NO_MATCH_DIR):
        no_match_count = len(list(Path(NO_MATCH_DIR).glob('*.pdf')))
        if no_match_count > 0:
            print(f"📦 {no_match_count} PDF's zonder match in: {NO_MATCH_DIR}/")
    
    print("=" * 70)


if __name__ == '__main__':
    main()

