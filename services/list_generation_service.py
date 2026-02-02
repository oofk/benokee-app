from collections import defaultdict
from typing import Dict, List

from services.bonus_service import match_bonus, bonus_suggestions


def combine_items(dish_ingredients: List[Dict], standard_items: List[Dict], incidental_items: List[Dict]) -> List[Dict]:
    combined: Dict[str, Dict] = {}

    def add_item(item: Dict):
        key = item["name"].strip().lower()
        if key not in combined:
            combined[key] = {**item}

    for ing in dish_ingredients:
        add_item(ing)

    for it in standard_items:
        add_item(it)

    for it in incidental_items:
        add_item(it)

    return list(combined.values())


def group_by_category(items: List[Dict]) -> Dict[str, List[Dict]]:
    grouped: Dict[str, List[Dict]] = defaultdict(list)
    for item in items:
        category = item.get("category") or "Overig"
        grouped[category].append(item)
    return grouped


def generate_weekly_list(selected_dishes: List[Dict], standard_items: List[Dict], incidental_items: List[Dict], offers: List[Dict], include_bonus: bool):
    dish_ingredients = []
    for dish in selected_dishes:
        for ing in dish.get("ingredients", []):
            dish_ingredients.append({"category": "Gerechten", "name": ing, "note": dish.get("name", "")})

    combined = combine_items(dish_ingredients, standard_items, incidental_items)

    if include_bonus:
        combined = match_bonus(combined, offers)
        suggestions = bonus_suggestions(combined)
    else:
        for item in combined:
            item["isOnBonus"] = False
            item["bonusOffer"] = None
        suggestions = []

    grouped = group_by_category(combined)
    return {
        "items": combined,
        "grouped": grouped,
        "bonusSuggestions": suggestions,
    }

