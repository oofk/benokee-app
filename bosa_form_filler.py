"""
Browser automation service voor het automatisch invullen van het BOSA formulier.
"""
import time
from typing import Dict, Any, Optional, List
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from pathlib import Path


class BOSAFormFiller:
    """Automatiseert het invullen van het BOSA subsidie formulier."""
    
    def __init__(self, headless: bool = False):
        self.driver = None
        self.headless = headless
        self.base_url = "https://formulierdus-i.nl/bosa26/"
        
    def start_browser(self):
        """Start de browser."""
        chrome_options = Options()
        if self.headless:
            chrome_options.add_argument('--headless')
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument('--disable-blink-features=AutomationControlled')
        chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
        chrome_options.add_experimental_option('useAutomationExtension', False)
        
        service = Service(ChromeDriverManager().install())
        self.driver = webdriver.Chrome(service=service, options=chrome_options)
        self.driver.maximize_window()
    
    def close_browser(self):
        """Sluit de browser."""
        if self.driver:
            self.driver.quit()
            self.driver = None
    
    def navigate_to_form(self, voorbeeldversie: bool = True):
        """Navigeer naar het formulier."""
        url = self.base_url
        if voorbeeldversie:
            url += "?voorbeeldversie=1"
        self.driver.get(url)
        time.sleep(2)  # Wacht tot pagina geladen is
    
    def wait_for_element(self, by: By, value: str, timeout: int = 10):
        """Wacht tot element zichtbaar is."""
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located((by, value))
        )
    
    def fill_text_field(self, field_name: str, value: str, by_type: By = By.NAME):
        """Vul een tekstveld in."""
        try:
            element = self.wait_for_element(by_type, field_name)
            element.clear()
            element.send_keys(str(value))
            return True
        except Exception as e:
            print(f"Fout bij invullen van {field_name}: {e}")
            return False
    
    def select_dropdown(self, field_name: str, value: str, by_type: By = By.NAME):
        """Selecteer een waarde in een dropdown."""
        try:
            element = self.wait_for_element(by_type, field_name)
            select = Select(element)
            select.select_by_visible_text(str(value))
            return True
        except Exception as e:
            print(f"Fout bij selecteren van {field_name}: {e}")
            return False
    
    def click_radio_button(self, field_name: str, value: str, by_type: By = By.NAME):
        """Klik op een radio button."""
        try:
            # Zoek naar radio buttons met dezelfde name
            radios = self.driver.find_elements(by_type, field_name)
            for radio in radios:
                if radio.get_attribute('value') == value:
                    if not radio.is_selected():
                        radio.click()
                    return True
            return False
        except Exception as e:
            print(f"Fout bij klikken op radio {field_name}: {e}")
            return False
    
    def click_checkbox(self, field_name: str, by_type: By = By.NAME):
        """Klik op een checkbox."""
        try:
            checkbox = self.wait_for_element(by_type, field_name)
            if not checkbox.is_selected():
                checkbox.click()
            return True
        except Exception as e:
            print(f"Fout bij klikken op checkbox {field_name}: {e}")
            return False
    
    def upload_file(self, field_name: str, file_path: str, by_type: By = By.NAME):
        """Upload een bestand."""
        try:
            element = self.wait_for_element(by_type, field_name)
            element.send_keys(str(file_path))
            return True
        except Exception as e:
            print(f"Fout bij uploaden van bestand {field_name}: {e}")
            return False
    
    def fill_aanvrager_section(self, data: Dict[str, Any]):
        """Vul de aanvrager sectie in."""
        print("Invullen aanvrager sectie...")
        
        if 'naam_organisatie' in data:
            self.fill_text_field('naam_organisatie', data['naam_organisatie'])
        
        if 'kvk_nummer' in data:
            self.fill_text_field('kvk_nummer', data['kvk_nummer'])
        
        if 'btw_plichtig' in data:
            self.click_radio_button('btw_plichtig', data['btw_plichtig'])
        
        if 'btw_aftrek' in data:
            self.click_radio_button('btw_aftrek', data['btw_aftrek'])
        
        # Adresgegevens
        if 'postadres_type' in data:
            self.click_radio_button('postadres_type', data['postadres_type'])
        
        if 'straat' in data:
            self.fill_text_field('straat', data['straat'])
        
        if 'huisnummer' in data:
            self.fill_text_field('huisnummer', data['huisnummer'])
        
        if 'postcode' in data:
            self.fill_text_field('postcode', data['postcode'])
        
        if 'plaats' in data:
            self.fill_text_field('plaats', data['plaats'])
        
        if 'provincie' in data:
            self.select_dropdown('provincie', data['provincie'])
        
        if 'telefoon' in data:
            self.fill_text_field('telefoon', data['telefoon'])
        
        if 'email' in data:
            self.fill_text_field('email', data['email'])
        
        time.sleep(1)
    
    def fill_contact_section(self, data: Dict[str, Any]):
        """Vul de contactgegevens sectie in."""
        print("Invullen contact sectie...")
        
        if 'voornaam' in data:
            self.fill_text_field('voornaam_contact', data['voornaam'])
        
        if 'tussenvoegsel' in data:
            self.fill_text_field('tussenvoegsel_contact', data['tussenvoegsel'])
        
        if 'achternaam' in data:
            self.fill_text_field('achternaam_contact', data['achternaam'])
        
        if 'email_contact' in data:
            self.fill_text_field('email_contact', data['email_contact'])
        
        if 'telefoon_contact' in data:
            self.fill_text_field('telefoon_contact', data['telefoon_contact'])
        
        if 'relatienummer' in data:
            self.fill_text_field('relatienummer', data['relatienummer'])
        
        time.sleep(1)
    
    def fill_bank_section(self, data: Dict[str, Any]):
        """Vul de bankgegevens sectie in."""
        print("Invullen bank sectie...")
        
        if 'iban' in data:
            self.fill_text_field('iban', data['iban'])
        
        if 'banknaam' in data:
            self.fill_text_field('banknaam', data['banknaam'])
        
        if 'rekeninghouder' in data:
            self.fill_text_field('rekeninghouder', data['rekeninghouder'])
        
        time.sleep(1)
    
    def fill_kosten_section(self, costs_data: List[Dict[str, Any]], documents_dir: Optional[str] = None):
        """Vul de kosten sectie in met data uit Excel."""
        print("Invullen kosten sectie...")
        
        # Navigeer naar kosten sectie (stap 7)
        # Dit vereist specifieke implementatie gebaseerd op de formulier structuur
        # Voor nu een basis implementatie
        
        for cost_item in costs_data:
            # Voeg kosten toe via de formulier interface
            # Dit hangt af van hoe het formulier gestructureerd is
            pass
        
        # Upload documenten
        if documents_dir:
            doc_paths = Path(documents_dir).glob('*')
            for doc_path in doc_paths:
                # Upload elk document
                pass
        
        time.sleep(1)
    
    def fill_ondertekenaar_section(self, data: Dict[str, Any]):
        """Vul de ondertekenaar sectie in."""
        print("Invullen ondertekenaar sectie...")
        
        if 'tekenbevoegdheid' in data:
            self.click_radio_button('tekenbevoegdheid', data['tekenbevoegdheid'])
        
        if 'voornaam_ondertekenaar' in data:
            self.fill_text_field('voornaam_ondertekenaar', data['voornaam_ondertekenaar'])
        
        if 'tussenvoegsel_ondertekenaar' in data:
            self.fill_text_field('tussenvoegsel_ondertekenaar', data['tussenvoegsel_ondertekenaar'])
        
        if 'achternaam_ondertekenaar' in data:
            self.fill_text_field('achternaam_ondertekenaar', data['achternaam_ondertekenaar'])
        
        if 'functie_ondertekenaar' in data:
            self.fill_text_field('functie_ondertekenaar', data['functie_ondertekenaar'])
        
        if 'email_ondertekenaar' in data:
            self.fill_text_field('email_ondertekenaar', data['email_ondertekenaar'])
        
        if 'telefoon_ondertekenaar' in data:
            self.fill_text_field('telefoon_ondertekenaar', data['telefoon_ondertekenaar'])
        
        time.sleep(1)
    
    def fill_complete_form(self, form_data: Dict[str, Any], costs_data: List[Dict[str, Any]] = None, 
                          documents_dir: Optional[str] = None):
        """Vul het complete formulier in."""
        try:
            self.start_browser()
            self.navigate_to_form(voorbeeldversie=True)
            
            # Doorloop alle secties
            if 'aanvrager' in form_data:
                self.fill_aanvrager_section(form_data['aanvrager'])
                self.click_next_button()
            
            if 'contact' in form_data:
                self.fill_contact_section(form_data['contact'])
                self.click_next_button()
            
            if 'bank' in form_data:
                self.fill_bank_section(form_data['bank'])
                self.click_next_button()
            
            if costs_data:
                self.fill_kosten_section(costs_data, documents_dir)
                self.click_next_button()
            
            if 'ondertekenaar' in form_data:
                self.fill_ondertekenaar_section(form_data['ondertekenaar'])
            
            print("Formulier invullen voltooid!")
            return True
            
        except Exception as e:
            print(f"Fout bij invullen formulier: {e}")
            return False
    
    def click_next_button(self):
        """Klik op de volgende knop."""
        try:
            # Zoek naar de volgende knop - dit kan variëren per pagina
            next_buttons = self.driver.find_elements(By.XPATH, "//button[contains(text(), 'Volgende')]")
            if next_buttons:
                next_buttons[0].click()
                time.sleep(2)  # Wacht tot volgende pagina geladen is
                return True
        except Exception as e:
            print(f"Fout bij klikken op volgende: {e}")
        return False
    
    def save_form(self):
        """Klik op de opslaan knop."""
        try:
            save_buttons = self.driver.find_elements(By.XPATH, "//button[contains(text(), 'Opslaan')]")
            if save_buttons:
                save_buttons[0].click()
                time.sleep(2)
                return True
        except Exception as e:
            print(f"Fout bij opslaan: {e}")
        return False

