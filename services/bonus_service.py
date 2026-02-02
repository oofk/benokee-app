import json
import re
import unicodedata
from typing import List, Dict

import requests
from bs4 import BeautifulSoup

BONUS_URLS = [
    "https://www.ah.nl/bonus",
    "https://www.ah.nl/bonus/folder",
]


def normalize(text: str) -> str:
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii")
    return re.sub(r"[^a-z0-9]+", " ", text.lower()).strip()


def fetch_bonus_offers() -> List[Dict]:
    offers: List[Dict] = []
    for url in BONUS_URLS:
        try:
            resp = requests.get(
                url,
                timeout=8,
                headers={
                    "User-Agent": "Mozilla/5.0 (compatible; Boodschappenplanner/1.0)",
                    "Accept": "text/html,application/json",
                },
            )
            resp.raise_for_status()
        except Exception:
            continue

        soup = BeautifulSoup(resp.text, "html.parser")
        offers.extend(_parse_offers_from_dom(soup))
        offers.extend(_parse_ld_json(soup))

    # Deduplicate by name + price
    unique = {}
    for offer in offers:
        key = f"{offer['name']}|{offer.get('price','')}"
        unique[key] = offer
    return list(unique.values())


def _parse_offers_from_dom(soup: BeautifulSoup) -> List[Dict]:
    parsed: List[Dict] = []

    # Try known AH hooks first
    product_cards = soup.select('[data-testhook="bonus-product"], article[data-testhook]')
    for card in product_cards:
        name = card.get("data-title") or card.get("aria-label")
        if not name:
            title_node = card.select_one("h3, h4, .title, .product-card__title")
            name = title_node.get_text(strip=True) if title_node else None
        if not name:
            continue

        price_node = card.select_one('[data-testhook="product-price"], .price, .product-card-price')
        price = price_node.get_text(" ", strip=True) if price_node else ""

        description_node = card.select_one(".product-card__description, .description")
        description = description_node.get_text(" ", strip=True) if description_node else ""

        parsed.append(
            {
                "name": name,
                "price": price,
                "description": description,
                "validFrom": "",
                "validTo": "",
            }
        )

    # Fallback: look for list items with bonus class names
    if not parsed:
        for li in soup.select("li"):
            text = li.get_text(" ", strip=True)
            if "bonus" in text.lower() and len(text) < 140:
                parsed.append(
                    {
                        "name": text,
                        "price": "",
                        "description": "",
                        "validFrom": "",
                        "validTo": "",
                    }
                )
    return parsed


def _parse_ld_json(soup: BeautifulSoup) -> List[Dict]:
    """Fallback: read structured data blocks if present."""
    parsed: List[Dict] = []
    scripts = soup.find_all("script", type="application/ld+json")
    for tag in scripts:
        try:
            data = json.loads(tag.string or "{}")
        except Exception:
            continue
        blocks = data if isinstance(data, list) else [data]
        for block in blocks:
            if isinstance(block, dict) and block.get("@type") in {"Product", "Offer"}:
                name = block.get("name") or block.get("description")
                if not name:
                    continue
                offer = block.get("offers") or {}
                price = ""
                if isinstance(offer, dict):
                    price = offer.get("price") or offer.get("priceSpecification", {}).get("price", "")
                parsed.append(
                    {
                        "name": name,
                        "price": str(price),
                        "description": block.get("description", ""),
                        "validFrom": offer.get("priceValidFrom", "") if isinstance(offer, dict) else "",
                        "validTo": offer.get("priceValidUntil", "") if isinstance(offer, dict) else "",
                    }
                )
    return parsed


def match_bonus(items: List[Dict], offers: List[Dict]) -> List[Dict]:
    offer_terms = [(offer, set(normalize(offer["name"]).split())) for offer in offers]
    enriched = []
    for item in items:
        item_terms = set(normalize(item["name"]).split())
        best_offer = None
        best_overlap = 0
        for offer, terms in offer_terms:
            overlap = len(item_terms & terms)
            if overlap > best_overlap and overlap > 0:
                best_overlap = overlap
                best_offer = offer
        if best_offer:
            enriched.append({**item, "isOnBonus": True, "bonusOffer": best_offer})
        else:
            enriched.append({**item, "isOnBonus": False, "bonusOffer": None})
    return enriched


def bonus_suggestions(items: List[Dict]) -> List[str]:
    suggestions = []
    for item in items:
        if item.get("isOnBonus"):
            suggestions.append(f"{item['name']} staat in de bonus; overweeg extra in te slaan.")
    return suggestions

