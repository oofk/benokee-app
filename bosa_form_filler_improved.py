"""
Verbeterde browser automation service voor het automatisch invullen van het BOSA formulier.
Gebruikt meerdere strategieën om velden te vinden en heeft betere error handling.
"""
import time
import json
import logging
from typing import Dict, Any, Optional, List, Tuple
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException, NoSuchElementException, ElementNotInteractableException
from webdriver_manager.chrome import ChromeDriverManager
from pathlib import Path


# Configureer logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('bosa_form_filler.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class BOSAFormFillerImproved:
    """Verbeterde versie voor automatisch invullen van BOSA subsidie formulier."""
    
    def __init__(self, headless: bool = False, wait_time: int = 2):
        self.driver = None
        self.headless = headless
        self.wait_time = wait_time
        self.base_url = "https://formulierdus-i.nl/bosa26/"
        self.field_mapping = self._load_field_mapping()
        
    def _load_field_mapping(self) -> Dict[str, Dict[str, Any]]:
        """Laad field mapping uit JSON bestand als het bestaat."""
        mapping_file = Path("bosa_field_mapping.json")
        if mapping_file.exists():
            try:
                with open(mapping_file, 'r', encoding='utf-8') as f:
                    mapping = json.load(f)
                    logger.info(f"Field mapping geladen: {len(mapping)} velden")
                    return mapping
            except Exception as e:
                logger.warning(f"Kon field mapping niet laden: {e}")
        else:
            logger.info("Geen field mapping bestand gevonden, gebruik standaard strategieën")
        return {}
    
    def start_browser(self):
        """Start de browser met optimale instellingen."""
        chrome_options = Options()
        if self.headless:
            chrome_options.add_argument('--headless')
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument('--disable-blink-features=AutomationControlled')
        chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
        chrome_options.add_experimental_option('useAutomationExtension', False)
        # User agent om detectie te vermijden
        chrome_options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
        
        try:
            service = Service(ChromeDriverManager().install())
            self.driver = webdriver.Chrome(service=service, options=chrome_options)
            self.driver.maximize_window()
            logger.info("Browser gestart")
        except Exception as e:
            logger.error(f"Fout bij starten browser: {e}")
            raise
    
    def close_browser(self):
        """Sluit de browser."""
        if self.driver:
            try:
                self.driver.quit()
                logger.info("Browser gesloten")
            except Exception as e:
                logger.warning(f"Fout bij sluiten browser: {e}")
            finally:
                self.driver = None
    
    def navigate_to_form(self, voorbeeldversie: bool = True):
        """Navigeer naar het formulier."""
        url = self.base_url
        if voorbeeldversie:
            url += "?voorbeeldversie=1"
        logger.info(f"Navigeren naar: {url}")
        self.driver.get(url)
        time.sleep(self.wait_time)
        # Wacht tot pagina geladen is
        WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )
        logger.info("Pagina geladen")
    
    def find_field(self, field_identifier: str, strategies: List[Tuple[By, str]] = None) -> Optional[Any]:
        """
        Zoek een veld met meerdere strategieën.
        
        Args:
            field_identifier: Naam of ID van het veld
            strategies: Lijst van (By, value) tuples om te proberen
        
        Returns:
            WebElement of None
        """
        if strategies is None:
            # Standaard strategieën: name, id, placeholder, label text
            strategies = [
                (By.NAME, field_identifier),
                (By.ID, field_identifier),
                (By.XPATH, f"//input[@placeholder='{field_identifier}']"),
                (By.XPATH, f"//label[contains(text(), '{field_identifier}')]/following-sibling::input[1]"),
                (By.XPATH, f"//label[contains(text(), '{field_identifier}')]/../input"),
            ]
        
        # Check field mapping eerst
        if field_identifier in self.field_mapping:
            mapping = self.field_mapping[field_identifier]
            if 'selector' in mapping:
                try:
                    by_type = getattr(By, mapping['selector']['by'].upper())
                    return self.driver.find_element(by_type, mapping['selector']['value'])
                except:
                    pass
        
        # Probeer alle strategieën
        for by_type, value in strategies:
            try:
                element = self.driver.find_element(by_type, value)
                if element.is_displayed() and element.is_enabled():
                    logger.debug(f"Veld gevonden: {field_identifier} via {by_type}={value}")
                    return element
            except (NoSuchElementException, ElementNotInteractableException):
                continue
        
        logger.warning(f"Veld niet gevonden: {field_identifier}")
        return None
    
    def fill_text_field(self, field_identifier: str, value: str, clear_first: bool = True) -> bool:
        """Vul een tekstveld in met meerdere zoekstrategieën."""
        if not value or value is None:
            return True  # Lege waarde, skip
        
        element = self.find_field(field_identifier)
        if not element:
            return False
        
        try:
            # Scroll naar element
            self.driver.execute_script("arguments[0].scrollIntoView(true);", element)
            time.sleep(0.3)
            
            if clear_first:
                element.clear()
            element.send_keys(str(value))
            logger.info(f"Veld ingevuld: {field_identifier} = {value}")
            return True
        except Exception as e:
            logger.error(f"Fout bij invullen {field_identifier}: {e}")
            return False
    
    def select_dropdown(self, field_identifier: str, value: str, match_partial: bool = True) -> bool:
        """Selecteer een waarde in een dropdown."""
        if not value:
            return True
        
        element = self.find_field(field_identifier)
        if not element:
            return False
        
        try:
            select = Select(element)
            
            # Probeer exacte match
            try:
                select.select_by_visible_text(str(value))
                logger.info(f"Dropdown geselecteerd: {field_identifier} = {value}")
                return True
            except:
                pass
            
            # Probeer partial match
            if match_partial:
                for option in select.options:
                    if str(value).lower() in option.text.lower():
                        select.select_by_visible_text(option.text)
                        logger.info(f"Dropdown geselecteerd (partial): {field_identifier} = {option.text}")
                        return True
            
            # Probeer via value attribuut
            try:
                select.select_by_value(str(value))
                logger.info(f"Dropdown geselecteerd (by value): {field_identifier} = {value}")
                return True
            except:
                pass
            
            logger.warning(f"Geen match gevonden in dropdown {field_identifier} voor waarde: {value}")
            return False
        except Exception as e:
            logger.error(f"Fout bij selecteren dropdown {field_identifier}: {e}")
            return False
    
    def click_radio_button(self, field_identifier: str, value: str) -> bool:
        """Klik op een radio button."""
        if not value:
            return True
        
        try:
            # Zoek naar radio buttons
            strategies = [
                (By.XPATH, f"//input[@type='radio' and @name='{field_identifier}' and @value='{value}']"),
                (By.XPATH, f"//input[@type='radio' and @name='{field_identifier}' and contains(@value, '{value}')]"),
                (By.XPATH, f"//label[contains(text(), '{value}')]/preceding-sibling::input[@type='radio']"),
                (By.XPATH, f"//label[contains(text(), '{value}')]/../input[@type='radio']"),
            ]
            
            for by_type, xpath in strategies:
                try:
                    radios = self.driver.find_elements(by_type, xpath)
                    for radio in radios:
                        if radio.is_displayed() and radio.is_enabled():
                            if not radio.is_selected():
                                self.driver.execute_script("arguments[0].scrollIntoView(true);", radio)
                                time.sleep(0.2)
                                radio.click()
                                logger.info(f"Radio button geklikt: {field_identifier} = {value}")
                                return True
                except:
                    continue
            
            logger.warning(f"Radio button niet gevonden: {field_identifier} = {value}")
            return False
        except Exception as e:
            logger.error(f"Fout bij klikken radio {field_identifier}: {e}")
            return False
    
    def click_checkbox(self, field_identifier: str, should_check: bool = True) -> bool:
        """Klik op een checkbox."""
        element = self.find_field(field_identifier)
        if not element:
            return False
        
        try:
            is_checked = element.is_selected()
            if (should_check and not is_checked) or (not should_check and is_checked):
                self.driver.execute_script("arguments[0].scrollIntoView(true);", element)
                time.sleep(0.2)
                element.click()
                logger.info(f"Checkbox {'aangevinkt' if should_check else 'uitgevinkt'}: {field_identifier}")
            return True
        except Exception as e:
            logger.error(f"Fout bij checkbox {field_identifier}: {e}")
            return False
    
    def upload_file(self, field_identifier: str, file_path: str) -> bool:
        """Upload een bestand."""
        if not file_path or not Path(file_path).exists():
            logger.warning(f"Bestand niet gevonden: {file_path}")
            return False
        
        element = self.find_field(field_identifier)
        if not element:
            return False
        
        try:
            # Zorg dat het een file input is
            if element.get_attribute("type") != "file":
                logger.warning(f"Veld {field_identifier} is geen file input")
                return False
            
            absolute_path = str(Path(file_path).absolute())
            element.send_keys(absolute_path)
            logger.info(f"Bestand geüpload: {field_identifier} = {absolute_path}")
            time.sleep(1)  # Wacht tot upload verwerkt is
            return True
        except Exception as e:
            logger.error(f"Fout bij uploaden {field_identifier}: {e}")
            return False
    
    def click_button(self, button_text: str, partial_match: bool = True) -> bool:
        """Klik op een knop met gegeven tekst."""
        try:
            # Meerdere strategieën om knop te vinden
            strategies = []
            
            if partial_match:
                strategies.extend([
                    (By.XPATH, f"//button[contains(text(), '{button_text}')]"),
                    (By.XPATH, f"//button[contains(., '{button_text}')]"),
                    (By.XPATH, f"//a[contains(text(), '{button_text}')]"),
                    (By.XPATH, f"//input[@type='button' and contains(@value, '{button_text}')]"),
                    (By.XPATH, f"//input[@type='submit' and contains(@value, '{button_text}')]"),
                ])
            else:
                strategies.extend([
                    (By.XPATH, f"//button[text()='{button_text}']"),
                    (By.XPATH, f"//a[text()='{button_text}']"),
                    (By.XPATH, f"//input[@type='button' and @value='{button_text}']"),
                    (By.XPATH, f"//input[@type='submit' and @value='{button_text}']"),
                ])
            
            for by_type, xpath in strategies:
                try:
                    buttons = self.driver.find_elements(by_type, xpath)
                    for button in buttons:
                        if button.is_displayed() and button.is_enabled():
                            # Scroll naar knop
                            self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", button)
                            time.sleep(0.3)
                            
                            # Probeer eerst JavaScript click (betrouwbaarder)
                            try:
                                self.driver.execute_script("arguments[0].click();", button)
                            except:
                                button.click()
                            
                            logger.info(f"Knop geklikt: {button_text}")
                            time.sleep(self.wait_time)  # Wacht tot volgende pagina geladen is
                            self.wait_for_page_load()
                            return True
                except Exception as e:
                    logger.debug(f"Strategie {xpath} faalde: {e}")
                    continue
            
            logger.warning(f"Knop niet gevonden: {button_text}")
            return False
        except Exception as e:
            logger.error(f"Fout bij klikken knop {button_text}: {e}")
            return False
    
    def wait_for_page_load(self, timeout: int = 10):
        """Wacht tot pagina volledig geladen is."""
        try:
            WebDriverWait(self.driver, timeout).until(
                lambda d: d.execute_script("return document.readyState") == "complete"
            )
            time.sleep(self.wait_time)
        except TimeoutException:
            logger.warning("Timeout bij wachten op pagina laden")
    
    def fill_section(self, section_name: str, data: Dict[str, Any], field_mapping: Dict[str, str] = None) -> Dict[str, bool]:
        """
        Vul een hele sectie in.
        
        Args:
            section_name: Naam van de sectie (voor logging)
            data: Dictionary met veld -> waarde mapping
            field_mapping: Optionele mapping van data keys naar formulier veldnamen
        
        Returns:
            Dictionary met resultaten per veld
        """
        logger.info(f"Invullen sectie: {section_name}")
        results = {}
        
        # Gebruik field mapping uit JSON bestand als beschikbaar
        if not field_mapping and self.field_mapping:
            # Gebruik de geladen field mapping
            for data_key, value in data.items():
                if value is None or value == "":
                    continue
                
                if data_key in self.field_mapping:
                    mapping = self.field_mapping[data_key]
                    field_name = mapping['selector']['value']
                    field_type = mapping.get('type', 'text')
                    
                    if field_type == 'radio':
                        # Voor radio buttons, gebruik click_radio_button
                        results[data_key] = self.click_radio_button(field_name, str(value).lower())
                    elif field_type == 'checkbox':
                        # Voor checkboxes
                        results[data_key] = self.click_checkbox(field_name, bool(value))
                    elif field_type == 'select':
                        # Voor dropdowns
                        results[data_key] = self.select_dropdown(field_name, str(value))
                    else:
                        # Voor tekstvelden
                        results[data_key] = self.fill_text_field(field_name, str(value))
                else:
                    # Geen mapping gevonden, probeer direct
                    if isinstance(value, bool):
                        results[data_key] = self.click_checkbox(data_key, value)
                    else:
                        results[data_key] = self.fill_text_field(data_key, str(value))
        elif field_mapping:
            # Gebruik custom mapping (parameter)
            for data_key, field_name in field_mapping.items():
                if data_key in data:
                    value = data[data_key]
                    # Bepaal type actie op basis van veld type
                    if isinstance(value, bool):
                        results[data_key] = self.click_checkbox(field_name, value)
                    elif isinstance(value, (list, dict)):
                        # Complexe velden, skip voor nu
                        results[data_key] = False
                    else:
                        results[data_key] = self.fill_text_field(field_name, str(value))
        else:
            # Directe mapping: data key = field name
            for field_name, value in data.items():
                if value is None or value == "":
                    continue
                
                if isinstance(value, bool):
                    results[field_name] = self.click_checkbox(field_name, value)
                else:
                    results[field_name] = self.fill_text_field(field_name, str(value))
        
        # Log resultaten
        success_count = sum(1 for v in results.values() if v)
        total_count = len(results)
        logger.info(f"Sectie {section_name}: {success_count}/{total_count} velden succesvol ingevuld")
        
        return results
    
    def fill_complete_form(self, form_data: Dict[str, Any], costs_data: List[Dict[str, Any]] = None,
                          documents_dir: Optional[str] = None, auto_advance: bool = True) -> bool:
        """
        Vul het complete formulier in door alle stappen te doorlopen.
        
        Args:
            form_data: Dictionary met alle formulier data
            costs_data: Lijst met kosten data
            documents_dir: Directory met documenten
            auto_advance: Automatisch naar volgende pagina gaan
        
        Returns:
            True als succesvol
        """
        try:
            self.start_browser()
            self.navigate_to_form(voorbeeldversie=True)
            
            # Start op eerste pagina - klik op "Start" of eerste "Volgende" als nodig
            # (In voorbeeldversie kan je direct beginnen)
            
            # Doorloop alle secties in volgorde zoals ze in het formulier voorkomen
            sections = [
                ("Aanvrager", "aanvrager", 2),  # Stap 2
                ("Contact", "contact", 3),      # Stap 3
                ("Bank", "bank", 4),            # Stap 4
                ("Amateursport", "sport", 5),    # Stap 5
                ("Activiteiten", "activiteiten", 6),  # Stap 6
            ]
            
            for section_display, section_key, step_number in sections:
                logger.info(f"Invullen stap {step_number}: {section_display}")
                
                if section_key in form_data and form_data[section_key]:
                    self.fill_section(section_display, form_data[section_key])
                else:
                    logger.info(f"Geen data voor {section_display}, overslaan")
                
                if auto_advance:
                    if not self.click_button("Volgende"):
                        logger.warning(f"Kon 'Volgende' knop niet vinden in stap {step_number}")
                    self.wait_for_page_load()
            
            # Kosten sectie (stap 7)
            logger.info("Invullen stap 7: Kosten")
            if costs_data:
                self._fill_costs_section(costs_data, documents_dir)
            else:
                logger.info("Geen kosten data, overslaan")
            
            if auto_advance:
                if not self.click_button("Volgende"):
                    logger.warning("Kon 'Volgende' knop niet vinden na kosten sectie")
                self.wait_for_page_load()
            
            # Ondertekenaar (stap 8)
            logger.info("Invullen stap 8: Ondertekenen")
            if "ondertekenaar" in form_data:
                self.fill_section("Ondertekenaar", form_data["ondertekenaar"])
            else:
                logger.info("Geen ondertekenaar data, overslaan")
            
            if auto_advance:
                if not self.click_button("Volgende"):
                    logger.warning("Kon 'Volgende' knop niet vinden na ondertekenaar")
                self.wait_for_page_load()
            
            # Laatste stap: Controleren/Versturen (stap 9)
            logger.info("Bereikt laatste stap: Controleren/Versturen")
            
            logger.info("Formulier invullen voltooid!")
            logger.info("LET OP: Controleer handmatig alle ingevulde gegevens voordat u verzendt!")
            return True
            
        except Exception as e:
            logger.error(f"Fout bij invullen formulier: {e}", exc_info=True)
            return False
    
    def _fill_costs_section(self, costs_data: List[Dict[str, Any]], documents_dir: Optional[str] = None):
        """Vul de kosten sectie in (vereist specifieke implementatie)."""
        logger.info("Invullen kosten sectie...")
        # TODO: Implementeer specifieke logica voor kosten sectie
        # Dit hangt af van hoe het formulier gestructureerd is
        pass
    
    def save_form(self) -> bool:
        """Klik op de opslaan knop."""
        return self.click_button("Opslaan")
    
    def get_form_link(self) -> Optional[str]:
        """Haal de opslag link op na opslaan."""
        try:
            # Zoek naar link element of tekst met link
            # Dit hangt af van hoe het formulier de link toont
            time.sleep(2)
            # TODO: Implementeer specifieke logica
            return None
        except Exception as e:
            logger.error(f"Fout bij ophalen formulier link: {e}")
            return None

