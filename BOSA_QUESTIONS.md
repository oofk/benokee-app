# Vragen voor BOSA Formulier Automatisering

Om het programma optimaal te maken, heb ik de volgende informatie nodig:

## 1. Formulier Velden Mapping
- **Welke exacte veldnamen (name/id attributen) worden gebruikt in het formulier?**
  - Moet ik een script maken dat automatisch alle velden analyseert?
  - Of heb je al een lijst met veldnamen?

## 2. Kosten Sectie (Tabblad 7)
- **Hoe ziet de Excel structuur eruit voor de kosten?**
  - Welke kolommen moeten erin staan? (bijv: Activiteit, Bedrag, Categorie, etc.)
  - Zijn er verschillende soorten kosten (energiebesparing, algemeen, etc.)?
  
- **Hoe worden kosten ingevoerd in het formulier?**
  - Is er een "Toevoegen" knop per kostenitem?
  - Moeten documenten (facturen/offertes) per kostenitem geüpload worden?
  - Of is er één upload voor alle documenten?

- **Wat moet er uit de directory met documenten gehaald worden?**
  - Moeten bestandsnamen gekoppeld worden aan specifieke kosten?
  - Of worden alle documenten in één keer geüpload?

## 3. Data Opslag
- **Welke gegevens blijven hetzelfde elk jaar?**
  - Aanvrager gegevens (naam, KVK, adres)?
  - Contactpersoon?
  - Bankgegevens?
  - Ondertekenaar?

- **Welke gegevens veranderen elk jaar?**
  - Alleen de kosten/activiteiten?
  - Of ook andere secties?

## 4. Workflow Vragen
- **Wanneer moet het formulier opgeslagen worden?**
  - Automatisch na elke sectie?
  - Alleen aan het einde?
  - Moet de gebruiker handmatig opslaan?

- **Moet het programma wachten tussen secties?**
  - Sommige formulieren laden dynamisch, hebben we wachttijden nodig?

- **Hoe moet omgegaan worden met validatie fouten?**
  - Moet het programma stoppen bij een fout?
  - Of doorgaan en fouten rapporteren?

## 5. Excel Structuur Voorstellen

Ik stel voor om de volgende Excel structuur te gebruiken:

### `bosa_formulier_data.xlsx`
- **Sheet "Aanvrager"**: Naam, KVK, BTW info, adres, etc.
- **Sheet "Contact"**: Contactpersoon gegevens
- **Sheet "Bank"**: IBAN, banknaam, rekeninghouder
- **Sheet "Amateursport"**: Sport specifieke gegevens
- **Sheet "Activiteiten"**: Beschrijving activiteiten
- **Sheet "Ondertekenaar"**: Ondertekenaar gegevens

### `bosa_kosten.xlsx`
- Kolommen: Activiteit, Categorie, Bedrag, BTW, Subtotaal, Document (pad)
- Of een andere structuur die jij prefereert?

## 6. Interface Vragen
- **Wil je een wizard-achtige interface (stap voor stap)?**
- **Of één overzichtspagina met alle velden?**
- **Moet er een preview zijn van wat ingevuld gaat worden?**

## 7. Browser Automatisering
- **Moet de browser zichtbaar zijn tijdens invullen?** (aanbevolen voor controle)
- **Of volledig achter de schermen?**
- **Moet er een optie zijn om handmatig tussen te komen?**

---

**Mijn voorstel voor nu:**
1. Maak een script dat automatisch alle formuliervelden analyseert
2. Maak een flexibele mapping systeem (veldnaam -> data mapping)
3. Implementeer een stap-voor-stap invul proces met wachttijden
4. Maak een duidelijke Excel structuur voor data opslag
5. Voeg error handling en logging toe

Wil je dat ik hiermee begin, of heb je eerst antwoorden op de vragen?

