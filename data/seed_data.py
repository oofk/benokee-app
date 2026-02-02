"""
Initial seed data representing the legacy Excel sheets.
The JSON structures here are written to local files on first run.
"""

INITIAL_DISHES = [
    {
        "id": "pasta-gehakt",
        "name": "Pasta met gehakt",
        "ingredients": [
            "Rundergehakt",
            "Pastasaus",
            "Pasta",
            "Mutti tomatenpuree",
            "Strooikaas",
        ],
        "persons": 4,
        "note": "Ook glutenvrije pasta voor Lein",
    },
    {
        "id": "boerenkool-stamppot",
        "name": "Boerenkool stamppot",
        "ingredients": ["Boerenkool", "Aardappels", "Rookworst", "Spekjes", "Mosterd"],
        "persons": 4,
        "note": "",
    },
    {
        "id": "wraps-mexicaans",
        "name": "Wraps Mexicaans",
        "ingredients": ["Wraps", "Kip", "Paprika", "Bonen", "Mais", "Salsa", "Kaas"],
        "persons": 4,
        "note": "Glutenvrije wraps voor Lein",
    },
    {
        "id": "poke-bowl",
        "name": "Poke bowl",
        "ingredients": ["Sushi rijst", "Sojasaus", "Zalm", "Komkommer", "Avocado", "Sesam"],
        "persons": 4,
        "note": "Glutenvrije sojasaus",
    },
    {
        "id": "gamba-wok",
        "name": "Gamba's wokgerecht",
        "ingredients": ["Gamba's", "Rijst", "Groentepakket", "Knoflook", "Sojasaus"],
        "persons": 4,
        "note": "",
    },
    {
        "id": "pizza-avond",
        "name": "Pizza-avond",
        "ingredients": ["Pizzabodems", "Tomatensaus", "Mozzarella", "Salami", "Paprika"],
        "persons": 4,
        "note": "Neem glutenvrije bodem mee",
    },
    {
        "id": "tosti-avond",
        "name": "Tosti-avond",
        "ingredients": ["Brood", "Kaas", "Ham", "Ketchup", "Glutenvrij brood"],
        "persons": 4,
        "note": "Voor Lein glutenvrij brood",
    },
    {
        "id": "hamburger-friet",
        "name": "Hamburgers + friet",
        "ingredients": ["Hamburgers", "Friet", "Sla", "Tomaat", "Hamburgerbroodjes"],
        "persons": 4,
        "note": "Glutenvrije broodjes voor Lein",
    },
    {
        "id": "zalm-aardappels",
        "name": "Zalm + aardappels",
        "ingredients": ["Zalm", "Aardappels", "Broccoli", "Citroen", "Dille"],
        "persons": 4,
        "note": "",
    },
    {
        "id": "salade-zalm",
        "name": "Salade + zalm",
        "ingredients": ["Sla", "Zalm", "Komkommer", "Avocado", "Ei", "Dressing"],
        "persons": 4,
        "note": "",
    },
]

INITIAL_STANDARD_ITEMS = [
    # Brood & beleg (frequent)
    {
        "id": "std-brood-week",
        "category": "Brood & beleg",
        "name": "Brood week",
        "note": "Minimaal 2",
        "forWhom": "",
        "isFrequent": True,
    },
    {
        "id": "std-brood-weekend",
        "category": "Brood & beleg",
        "name": "Brood weekend",
        "note": "",
        "forWhom": "",
        "isFrequent": True,
    },
    {
        "id": "std-beleg-week",
        "category": "Brood & beleg",
        "name": "Beleg week",
        "note": "",
        "forWhom": "",
        "isFrequent": True,
    },
    # Glutenvrij (Lein) (frequent)
    {
        "id": "std-gv-brood-wit",
        "category": "Glutenvrij (Lein)",
        "name": "Glutenvrij brood wit",
        "note": "",
        "forWhom": "Lein",
        "isFrequent": True,
    },
    {
        "id": "std-gv-pasta",
        "category": "Glutenvrij (Lein)",
        "name": "Glutenvrije pasta",
        "note": "",
        "forWhom": "Lein",
        "isFrequent": True,
    },
    # Fruit & groente (frequent)
    {
        "id": "std-appels-mooie",
        "category": "Fruit & groente",
        "name": "Appels (mooie)",
        "note": "",
        "forWhom": "",
        "isFrequent": True,
    },
    {
        "id": "std-bananen",
        "category": "Fruit & groente",
        "name": "Bananen",
        "note": "",
        "forWhom": "",
        "isFrequent": True,
    },
    {
        "id": "std-broccoli",
        "category": "Fruit & groente",
        "name": "Broccoli",
        "note": "",
        "forWhom": "",
        "isFrequent": True,
    },
    # Basisproducten (frequent)
    {
        "id": "std-chili-bonen",
        "category": "Basisproducten",
        "name": "Chili bonen blik",
        "note": "",
        "forWhom": "",
        "isFrequent": True,
    },
    {
        "id": "std-mutti-blikjes",
        "category": "Basisproducten",
        "name": "Mutti tomatenblikjes",
        "note": "",
        "forWhom": "",
        "isFrequent": True,
    },
    {
        "id": "std-aluminium-folie",
        "category": "Basisproducten",
        "name": "Aluminiumfolie",
        "note": "",
        "forWhom": "",
        "isFrequent": True,
    },
    # Zuivel & eieren (less frequent)
    {
        "id": "std-yoghurt",
        "category": "Zuivel & eieren",
        "name": "Yoghurt",
        "note": "",
        "forWhom": "",
        "isFrequent": False,
    },
    {
        "id": "std-kaas",
        "category": "Zuivel & eieren",
        "name": "Kaas",
        "note": "",
        "forWhom": "",
        "isFrequent": False,
    },
    # Drinken (less frequent)
    {
        "id": "std-limonadesiroop",
        "category": "Drinken",
        "name": "Limonadesiroop",
        "note": "",
        "forWhom": "",
        "isFrequent": False,
    },
    {
        "id": "std-koffiebonen",
        "category": "Drinken",
        "name": "Koffiebonen",
        "note": "",
        "forWhom": "",
        "isFrequent": False,
    },
    # Snacks & koek (less frequent)
    {
        "id": "std-venz-hagel",
        "category": "Snacks & koek",
        "name": "Venz hagelslag/blauwe hagel",
        "note": "",
        "forWhom": "Pom/jeugd",
        "isFrequent": False,
    },
    {
        "id": "std-chips-mix",
        "category": "Snacks & koek",
        "name": "Chips mix",
        "note": "",
        "forWhom": "",
        "isFrequent": False,
    },
    # Huishouden (less frequent)
    {
        "id": "std-afwasmiddel",
        "category": "Huishouden",
        "name": "Afwasmiddel",
        "note": "",
        "forWhom": "",
        "isFrequent": False,
    },
    {
        "id": "std-wc-papier",
        "category": "Huishouden",
        "name": "WC papier",
        "note": "",
        "forWhom": "",
        "isFrequent": False,
    },
]

INITIAL_INCIDENTAL_ITEMS = [
    # Feest & evenementen
    {
        "id": "inc-fruitsalade",
        "category": "Feest & evenementen",
        "name": "Ingrediënten fruitsalade",
        "note": "Diepenveen/feestjes",
        "forWhom": "",
    },
    {
        "id": "inc-extra-chips-snoep",
        "category": "Feest & evenementen",
        "name": "Extra chips & snoep",
        "note": "Borrel/feest",
        "forWhom": "",
    },
    # Seizoensgebonden
    {
        "id": "inc-pepernoten-gewone",
        "category": "Seizoensgebonden",
        "name": "Pepernoten gewoon",
        "note": "Sinterklaas/winter",
        "forWhom": "",
    },
    {
        "id": "inc-pepernoten-choco",
        "category": "Seizoensgebonden",
        "name": "Pepernoten choco",
        "note": "Sinterklaas/winter",
        "forWhom": "",
    },
    {
        "id": "inc-kerst-kransjes",
        "category": "Seizoensgebonden",
        "name": "Kerstkransjes",
        "note": "Kerst",
        "forWhom": "",
    },
    # Hygiëne & schoonmaak
    {
        "id": "inc-maandverband",
        "category": "Hygiëne & schoonmaak",
        "name": "Maandverband/tampons",
        "note": "",
        "forWhom": "",
    },
    {
        "id": "inc-schoonmaakdoekjes",
        "category": "Hygiëne & schoonmaak",
        "name": "Schoonmaakdoekjes",
        "note": "",
        "forWhom": "",
    },
    # Speciale wensen
    {
        "id": "inc-glutenvrij-pils",
        "category": "Speciale wensen",
        "name": "Glutenvrij pils",
        "note": "Voor Lein",
        "forWhom": "Lein",
    },
    {
        "id": "inc-teriyaki-saus",
        "category": "Speciale wensen",
        "name": "Teriyaki saus",
        "note": "Regelmatig",
        "forWhom": "",
    },
]


