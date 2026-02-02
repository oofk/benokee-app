"""
Script om de BOSA formulier structuur te analyseren en alle velden te identificeren.
Dit helpt bij het maken van een betere automatische invul functie.
"""
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import time
import json


def analyze_form_structure():
    """Analyseer de formulier structuur en verzamel alle veld informatie van alle pagina's."""
    
    # Start browser
    chrome_options = Options()
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=chrome_options)
    driver.maximize_window()
    
    try:
        # Navigeer naar formulier
        url = "https://formulierdus-i.nl/bosa26/?voorbeeldversie=1"
        driver.get(url)
        time.sleep(3)
        
        form_structure = {
            "sections": [],
            "all_fields": [],
            "pages": []
        }
        
        page_number = 1
        max_pages = 20  # Veilige limiet om oneindige loops te voorkomen
        visited_urls = set()
        previous_field_count = 0
        
        print(f"\n=== FORMULIER ANALYSE ===")
        print("Start met analyseren van alle pagina's...\n")
        
        while page_number <= max_pages:
            current_url = driver.current_url
            # Voor single-page apps: check of we echt op een nieuwe stap zijn
            # door te kijken naar zichtbare velden
            time.sleep(2)  # Wacht tot JavaScript animaties klaar zijn
            
            # Tel zichtbare input velden
            visible_inputs = driver.find_elements(By.CSS_SELECTOR, 
                "input:not([type='hidden']):not([style*='display: none']), "
                "select:not([style*='display: none']), "
                "textarea:not([style*='display: none'])")
            
            current_field_count = len([e for e in visible_inputs if e.is_displayed()])
            
            # Als URL hetzelfde is maar we hebben nieuwe velden, dan zijn we op een nieuwe stap
            if current_url in visited_urls and current_field_count == previous_field_count:
                print(f"\nPagina {page_number}: Geen nieuwe velden gevonden, einde van formulier.")
                break
            
            visited_urls.add(current_url)
            previous_field_count = current_field_count
            
            print(f"\n--- Pagina {page_number} ---")
            print(f"URL: {current_url}")
            
            # Wacht tot pagina geladen is
            time.sleep(2)
            
            # Haal pagina titel/header op
            page_title = "Onbekend"
            try:
                headers = driver.find_elements(By.TAG_NAME, "h1")
                if headers:
                    page_title = headers[0].text
                else:
                    # Probeer andere headers
                    headers = driver.find_elements(By.TAG_NAME, "h2")
                    if headers:
                        page_title = headers[0].text
            except:
                pass
            
            print(f"Titel: {page_title}")
            
            # Analyseer huidige pagina
            page_fields = []
            
            # Zoek alle input velden
            inputs = driver.find_elements(By.TAG_NAME, "input")
            selects = driver.find_elements(By.TAG_NAME, "select")
            textareas = driver.find_elements(By.TAG_NAME, "textarea")
            
            print(f"  Gevonden: {len(inputs)} inputs, {len(selects)} selects, {len(textareas)} textareas")
            
            # Analyseer inputs
            for inp in inputs:
                # Skip hidden fields
                if inp.get_attribute("type") == "hidden":
                    continue
                
                field_info = {
                    "page": page_number,
                    "page_title": page_title,
                    "type": inp.get_attribute("type") or "text",
                    "name": inp.get_attribute("name"),
                    "id": inp.get_attribute("id"),
                    "placeholder": inp.get_attribute("placeholder"),
                    "value": inp.get_attribute("value"),
                    "label": None,
                    "required": inp.get_attribute("required") is not None,
                    "class": inp.get_attribute("class")
                }
                
                # Zoek bijbehorend label - meerdere strategieën (specifiek voor Gravity Forms)
                label_text = None
                
                # Strategie 1: label for attribuut (standaard HTML)
                if field_info["id"]:
                    try:
                        label = driver.find_element(By.XPATH, f"//label[@for='{field_info['id']}']")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 2: Gravity Forms specifiek - gfield_label
                if not label_text:
                    try:
                        # Zoek naar parent gfield container
                        parent = inp.find_element(By.XPATH, "./ancestor::li[contains(@class, 'gfield')][1]")
                        label = parent.find_element(By.CSS_SELECTOR, "label.gfield_label, .gfield_label")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 3: label die input bevat
                if not label_text:
                    try:
                        label = inp.find_element(By.XPATH, "./ancestor::label[1]")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 4: vorige sibling label
                if not label_text:
                    try:
                        label = driver.find_element(By.XPATH, 
                            f"//input[@id='{field_info['id']}']/preceding-sibling::label[1] | "
                            f"//input[@name='{field_info['name']}']/preceding-sibling::label[1]")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 5: parent div/li met label (algemeen)
                if not label_text:
                    try:
                        parent = inp.find_element(By.XPATH, 
                            "./ancestor::div[contains(@class, 'field') or contains(@class, 'form-group') or contains(@class, 'gfield')][1] | "
                            "./ancestor::li[contains(@class, 'gfield')][1]")
                        label = parent.find_element(By.CSS_SELECTOR, "label, .label, .gfield_label")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 6: Zoek via field name naar label (Gravity Forms gebruikt vaak field IDs)
                if not label_text and field_info["name"]:
                    try:
                        # Extract field number from name (e.g., input_112 -> 112)
                        field_num = field_info["name"].replace("input_", "").split(".")[0]
                        # Zoek label in gfield met dit nummer
                        label = driver.find_element(By.XPATH, 
                            f"//li[contains(@id, 'field_2656_{field_num}')]//label[1] | "
                            f"//div[contains(@id, 'field_2656_{field_num}')]//label[1] | "
                            f"//li[@id='field_2656_{field_num}']//label[1]")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 7: Zoek naar gfield_label in dezelfde container
                if not label_text:
                    try:
                        # Zoek naar dichtstbijzijnde gfield_label
                        parent_container = inp.find_element(By.XPATH, "./ancestor::*[contains(@class, 'gfield')][1]")
                        labels = parent_container.find_elements(By.CSS_SELECTOR, 
                            "label.gfield_label, .gfield_label, label[for], .ginput_complex label")
                        for lbl in labels:
                            lbl_text = lbl.text.strip()
                            if lbl_text and len(lbl_text) > 2:  # Minimaal 3 karakters
                                label_text = lbl_text
                                break
                    except:
                        pass
                
                # Strategie 8: Voor radio buttons, zoek label naast de input
                if not label_text and field_info["type"] == "radio":
                    try:
                        # Radio buttons hebben vaak een label direct na de input
                        label = inp.find_element(By.XPATH, "./following-sibling::label[1]")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 9: Zoek naar aria-label of title attribuut
                if not label_text:
                    aria_label = inp.get_attribute("aria-label")
                    title = inp.get_attribute("title")
                    if aria_label and aria_label.strip():
                        label_text = aria_label.strip()
                    elif title and title.strip():
                        label_text = title.strip()
                
                # Strategie 7: Zoek label via aria-label of aria-labelledby
                if not label_text:
                    try:
                        aria_label = inp.get_attribute("aria-label")
                        if aria_label:
                            label_text = aria_label.strip()
                    except:
                        pass
                
                # Strategie 8: Zoek via placeholder (als fallback)
                if not label_text and field_info.get("placeholder"):
                    label_text = field_info["placeholder"].strip()
                
                field_info["label"] = label_text
                
                if field_info["name"] or field_info["id"]:
                    page_fields.append(field_info)
                    form_structure["all_fields"].append(field_info)
                    print(f"    Input: {field_info['name'] or field_info['id']} ({field_info['type']}) - {label_text or 'Geen label'}")
            
            # Analyseer selects
            for sel in selects:
                field_info = {
                    "page": page_number,
                    "page_title": page_title,
                    "type": "select",
                    "name": sel.get_attribute("name"),
                    "id": sel.get_attribute("id"),
                    "options": [],
                    "label": None,
                    "required": sel.get_attribute("required") is not None
                }
                
                # Haal opties op
                from selenium.webdriver.support.ui import Select
                try:
                    select_obj = Select(sel)
                    for option in select_obj.options:
                        field_info["options"].append({
                            "value": option.get_attribute("value"),
                            "text": option.text.strip()
                        })
                except:
                    pass
                
                # Zoek label (zelfde strategieën als bij inputs, aangepast voor select)
                label_text = None
                
                # Strategie 1: label for attribuut
                if field_info["id"]:
                    try:
                        label = driver.find_element(By.XPATH, f"//label[@for='{field_info['id']}']")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 2: Gravity Forms gfield_label
                if not label_text:
                    try:
                        parent = sel.find_element(By.XPATH, "./ancestor::li[contains(@class, 'gfield')][1]")
                        label = parent.find_element(By.CSS_SELECTOR, "label.gfield_label, .gfield_label")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 3: parent div/li met label
                if not label_text:
                    try:
                        parent = sel.find_element(By.XPATH, 
                            "./ancestor::div[contains(@class, 'field') or contains(@class, 'gfield')][1] | "
                            "./ancestor::li[contains(@class, 'gfield')][1]")
                        label = parent.find_element(By.CSS_SELECTOR, "label, .label, .gfield_label")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 4: Zoek via field name
                if not label_text and field_info["name"]:
                    try:
                        field_num = field_info["name"].replace("input_", "")
                        label = driver.find_element(By.XPATH, 
                            f"//li[contains(@id, 'field_2656_{field_num}')]//label[1] | "
                            f"//div[contains(@id, 'field_2656_{field_num}')]//label[1]")
                        label_text = label.text.strip()
                    except:
                        pass
                
                field_info["label"] = label_text
                
                if field_info["name"] or field_info["id"]:
                    page_fields.append(field_info)
                    form_structure["all_fields"].append(field_info)
                    opties_preview = [opt['text'] for opt in field_info["options"][:3]]
                    print(f"    Select: {field_info['name'] or field_info['id']} - {label_text or 'Geen label'} ({len(field_info['options'])} opties: {opties_preview}...)")
            
            # Analyseer textareas
            for ta in textareas:
                field_info = {
                    "page": page_number,
                    "page_title": page_title,
                    "type": "textarea",
                    "name": ta.get_attribute("name"),
                    "id": ta.get_attribute("id"),
                    "label": None,
                    "required": ta.get_attribute("required") is not None
                }
                
                # Zoek label (zelfde strategieën als bij inputs, aangepast voor textarea)
                label_text = None
                
                # Strategie 1: label for attribuut
                if field_info["id"]:
                    try:
                        label = driver.find_element(By.XPATH, f"//label[@for='{field_info['id']}']")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 2: Gravity Forms gfield_label
                if not label_text:
                    try:
                        parent = ta.find_element(By.XPATH, "./ancestor::li[contains(@class, 'gfield')][1]")
                        label = parent.find_element(By.CSS_SELECTOR, "label.gfield_label, .gfield_label")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 3: parent div/li met label
                if not label_text:
                    try:
                        parent = ta.find_element(By.XPATH, 
                            "./ancestor::div[contains(@class, 'field') or contains(@class, 'gfield')][1] | "
                            "./ancestor::li[contains(@class, 'gfield')][1]")
                        label = parent.find_element(By.CSS_SELECTOR, "label, .label, .gfield_label")
                        label_text = label.text.strip()
                    except:
                        pass
                
                # Strategie 4: Zoek via field name
                if not label_text and field_info["name"]:
                    try:
                        field_num = field_info["name"].replace("input_", "")
                        label = driver.find_element(By.XPATH, 
                            f"//li[contains(@id, 'field_2656_{field_num}')]//label[1] | "
                            f"//div[contains(@id, 'field_2656_{field_num}')]//label[1]")
                        label_text = label.text.strip()
                    except:
                        pass
                
                field_info["label"] = label_text
                
                if field_info["name"] or field_info["id"]:
                    page_fields.append(field_info)
                    form_structure["all_fields"].append(field_info)
                    print(f"    Textarea: {field_info['name'] or field_info['id']} - {label_text or 'Geen label'}")
            
            # Sla pagina info op
            form_structure["pages"].append({
                "page_number": page_number,
                "title": page_title,
                "url": current_url,
                "field_count": len(page_fields)
            })
            
            # Zoek "Volgende" knop - meerdere strategieën voor Gravity Forms
            next_button = None
            next_button_texts = ["Volgende", "Next", ">", "→"]
            
            # Strategie 1: Zoek naar Gravity Forms next button (meest specifiek)
            try:
                # Gravity Forms gebruikt vaak: input met id zoals "gform_next_button_2656_31"
                next_buttons = driver.find_elements(By.CSS_SELECTOR, 
                    "input[id*='gform_next_button'], input[id*='next_button'], "
                    "button[id*='gform_next_button'], button[id*='next_button']")
                for btn in next_buttons:
                    if btn.is_displayed() and btn.is_enabled():
                        btn_id = btn.get_attribute("id") or ""
                        if "previous" not in btn_id.lower() and "prev" not in btn_id.lower():
                            next_button = btn
                            print(f"  Gravity Forms next button gevonden: {btn_id}")
                            break
            except Exception as e:
                print(f"  Fout bij zoeken Gravity Forms button: {e}")
            
            # Strategie 2: Zoek naar button met tekst
            if not next_button:
                for button_text in next_button_texts:
                    try:
                        buttons = driver.find_elements(By.XPATH, f"//button[contains(text(), '{button_text}')]")
                        for btn in buttons:
                            if btn.is_displayed() and btn.is_enabled():
                                next_button = btn
                                print(f"  Button met tekst gevonden: {button_text}")
                                break
                        if next_button:
                            break
                    except:
                        continue
            
            # Strategie 3: Zoek naar input type button/submit met value
            if not next_button:
                for button_text in next_button_texts:
                    try:
                        inputs = driver.find_elements(By.XPATH, 
                            f"//input[@type='button' and contains(@value, '{button_text}')] | "
                            f"//input[@type='submit' and contains(@value, '{button_text}')]")
                        for inp in inputs:
                            if inp.is_displayed() and inp.is_enabled():
                                next_button = inp
                                print(f"  Input button gevonden: {button_text}")
                                break
                        if next_button:
                            break
                    except:
                        continue
            
            # Strategie 4: Zoek naar element met class die "next" bevat
            if not next_button:
                try:
                    next_elements = driver.find_elements(By.CSS_SELECTOR, 
                        ".gform_next_button, [class*='next'], [class*='Next'], "
                        "[class*='gform_next'], [class*='gform-button-next']")
                    for elem in next_elements:
                        if elem.is_displayed() and elem.is_enabled():
                            next_button = elem
                            print(f"  Element met next class gevonden: {elem.get_attribute('class')}")
                            break
                except:
                    pass
            
            # Strategie 5: Zoek naar link met tekst
            if not next_button:
                for button_text in next_button_texts:
                    try:
                        links = driver.find_elements(By.XPATH, f"//a[contains(text(), '{button_text}')]")
                        for link in links:
                            if link.is_displayed() and link.is_enabled():
                                next_button = link
                                print(f"  Link gevonden: {button_text}")
                                break
                        if next_button:
                            break
                    except:
                        continue
            
            if next_button:
                try:
                    # Scroll naar knop
                    driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", next_button)
                    time.sleep(0.5)
                    
                    # Sla huidige zichtbare velden op voor vergelijking
                    before_click_fields = len([e for e in driver.find_elements(By.CSS_SELECTOR, 
                        "input:not([type='hidden']), select, textarea") if e.is_displayed()])
                    
                    # Klik met JavaScript (betrouwbaarder voor Gravity Forms)
                    driver.execute_script("arguments[0].click();", next_button)
                    print(f"  Klikte op 'Volgende' knop (Gravity Forms)")
                    
                    # Wacht tot nieuwe stap zichtbaar is (max 10 seconden)
                    time.sleep(2)
                    for wait_attempt in range(10):
                        after_click_fields = len([e for e in driver.find_elements(By.CSS_SELECTOR, 
                            "input:not([type='hidden']), select, textarea") if e.is_displayed()])
                        if after_click_fields != before_click_fields:
                            print(f"  Nieuwe stap gedetecteerd (veld count: {before_click_fields} -> {after_click_fields})")
                            break
                        time.sleep(1)
                    
                    page_number += 1
                except Exception as e:
                    print(f"  Kon niet klikken op volgende knop: {e}")
                    break
            else:
                print(f"  Geen 'Volgende' knop gevonden. Einde van formulier bereikt.")
                break
        
        # Sla structuur op
        with open("bosa_form_structure.json", "w", encoding="utf-8") as f:
            json.dump(form_structure, f, indent=2, ensure_ascii=False)
        
        print(f"\n\n=== SAMENVATTING ===")
        print(f"Totaal pagina's geanalyseerd: {len(form_structure['pages'])}")
        print(f"Totaal velden gevonden: {len(form_structure['all_fields'])}")
        print(f"Structuur opgeslagen in bosa_form_structure.json")
        
        # Groepeer velden per pagina
        print(f"\n=== VELDEN PER PAGINA ===")
        for page_info in form_structure["pages"]:
            page_fields = [f for f in form_structure["all_fields"] if f["page"] == page_info["page_number"]]
            print(f"Pagina {page_info['page_number']}: {page_info['title']} - {len(page_fields)} velden")
        
        # Wacht zodat gebruiker kan zien
        print("\n\nBrowser blijft 30 seconden open voor inspectie...")
        time.sleep(30)
        
    finally:
        driver.quit()


if __name__ == "__main__":
    analyze_form_structure()

