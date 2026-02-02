"""
Excel data manager voor BOSA formulier gegevens.
Slaat alle formulierdata op in Excel zodat deze hergebruikt kunnen worden.
"""
import os
import pandas as pd
from pathlib import Path
from typing import Dict, Any, Optional, List
import json


class BOSADataManager:
    """Beheert opslag en laad van BOSA formulier data in Excel format."""
    
    def __init__(self, data_dir: str = "bosa_data"):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(exist_ok=True)
        self.excel_file = self.data_dir / "bosa_formulier_data.xlsx"
        self.costs_excel_file = self.data_dir / "bosa_kosten.xlsx"
        self.costs_directory = self.data_dir / "kosten_documenten"
        self.costs_directory.mkdir(exist_ok=True)
        
    def save_form_data(self, data: Dict[str, Any]) -> str:
        """
        Slaat formulierdata op in Excel.
        Returns: pad naar het Excel bestand
        """
        # Maak een DataFrame voor elke sectie
        sheets = {}
        
        # Aanvrager gegevens
        aanvrager_data = {
            'Veld': [],
            'Waarde': []
        }
        if 'aanvrager' in data:
            for key, value in data['aanvrager'].items():
                aanvrager_data['Veld'].append(key)
                aanvrager_data['Waarde'].append(str(value) if value is not None else '')
        sheets['Aanvrager'] = pd.DataFrame(aanvrager_data)
        
        # Contactgegevens
        contact_data = {
            'Veld': [],
            'Waarde': []
        }
        if 'contact' in data:
            for key, value in data['contact'].items():
                contact_data['Veld'].append(key)
                contact_data['Waarde'].append(str(value) if value is not None else '')
        sheets['Contact'] = pd.DataFrame(contact_data)
        
        # Bankgegevens
        bank_data = {
            'Veld': [],
            'Waarde': []
        }
        if 'bank' in data:
            for key, value in data['bank'].items():
                bank_data['Veld'].append(key)
                bank_data['Waarde'].append(str(value) if value is not None else '')
        sheets['Bank'] = pd.DataFrame(bank_data)
        
        # Amateursport
        sport_data = {
            'Veld': [],
            'Waarde': []
        }
        if 'sport' in data:
            for key, value in data['sport'].items():
                sport_data['Veld'].append(key)
                sport_data['Waarde'].append(str(value) if value is not None else '')
        sheets['Amateursport'] = pd.DataFrame(sport_data)
        
        # Activiteiten
        activiteiten_data = {
            'Veld': [],
            'Waarde': []
        }
        if 'activiteiten' in data:
            for key, value in data['activiteiten'].items():
                activiteiten_data['Veld'].append(key)
                activiteiten_data['Waarde'].append(str(value) if value is not None else '')
        sheets['Activiteiten'] = pd.DataFrame(activiteiten_data)
        
        # Ondertekenaar
        ondertekenaar_data = {
            'Veld': [],
            'Waarde': []
        }
        if 'ondertekenaar' in data:
            for key, value in data['ondertekenaar'].items():
                ondertekenaar_data['Veld'].append(key)
                ondertekenaar_data['Waarde'].append(str(value) if value is not None else '')
        sheets['Ondertekenaar'] = pd.DataFrame(ondertekenaar_data)
        
        # Schrijf naar Excel
        with pd.ExcelWriter(self.excel_file, engine='openpyxl') as writer:
            for sheet_name, df in sheets.items():
                df.to_excel(writer, sheet_name=sheet_name, index=False)
        
        return str(self.excel_file)
    
    def load_form_data(self) -> Optional[Dict[str, Any]]:
        """
        Laadt formulierdata uit Excel.
        Returns: dict met alle formulierdata of None als bestand niet bestaat
        """
        if not self.excel_file.exists():
            return None
        
        data = {}
        
        try:
            excel_data = pd.read_excel(self.excel_file, sheet_name=None, engine='openpyxl')
            
            # Converteer elke sheet terug naar dict
            for sheet_name, df in excel_data.items():
                if len(df) > 0:
                    section_data = {}
                    for _, row in df.iterrows():
                        field = row['Veld']
                        value = row['Waarde']
                        # Probeer waarde te converteren
                        if value == '' or pd.isna(value):
                            value = None
                        section_data[field] = value
                    data[sheet_name.lower()] = section_data
        except Exception as e:
            print(f"Fout bij laden van Excel: {e}")
            return None
        
        return data
    
    def save_costs_data(self, costs: List[Dict[str, Any]]) -> str:
        """
        Slaat kosten data op in Excel.
        costs: lijst van dicts met kosten informatie
        Returns: pad naar het Excel bestand
        """
        if not costs:
            return str(self.costs_excel_file)
        
        df = pd.DataFrame(costs)
        df.to_excel(self.costs_excel_file, index=False, engine='openpyxl')
        return str(self.costs_excel_file)
    
    def load_costs_data(self) -> List[Dict[str, Any]]:
        """
        Laadt kosten data uit Excel.
        Returns: lijst van dicts met kosten informatie
        """
        if not self.costs_excel_file.exists():
            return []
        
        try:
            df = pd.read_excel(self.costs_excel_file, engine='openpyxl')
            return df.to_dict('records')
        except Exception as e:
            print(f"Fout bij laden van kosten Excel: {e}")
            return []
    
    def get_cost_documents(self) -> List[str]:
        """
        Retourneert lijst van document paden in de kosten directory.
        """
        if not self.costs_directory.exists():
            return []
        
        documents = []
        for ext in ['*.pdf', '*.jpg', '*.jpeg', '*.png', '*.xlsx', '*.xls', '*.ods']:
            documents.extend(self.costs_directory.glob(ext))
        
        return [str(doc) for doc in documents]
    
    def save_cost_document(self, file_path: str) -> str:
        """
        Kopieert een document naar de kosten directory.
        Returns: pad naar gekopieerd bestand
        """
        from shutil import copy2
        source = Path(file_path)
        dest = self.costs_directory / source.name
        copy2(source, dest)
        return str(dest)

