import json
from pathlib import Path
from typing import List, Dict, Any

from data.seed_data import (
    INITIAL_DISHES,
    INITIAL_STANDARD_ITEMS,
    INITIAL_INCIDENTAL_ITEMS,
)


DATA_DIR = Path(__file__).parent
FILES = {
    "dishes": DATA_DIR / "dishes.json",
    "standard_items": DATA_DIR / "standard_items.json",
    "incidental_items": DATA_DIR / "incidental_items.json",
}


def _load_or_empty(path: Path) -> List[Dict[str, Any]]:
    if not path.exists():
        return []
    with path.open("r", encoding="utf-8") as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return []


def _save(path: Path, data: List[Dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def ensure_seed_data() -> None:
    seeds = {
        FILES["dishes"]: INITIAL_DISHES,
        FILES["standard_items"]: INITIAL_STANDARD_ITEMS,
        FILES["incidental_items"]: INITIAL_INCIDENTAL_ITEMS,
    }
    for path, seed in seeds.items():
        if not path.exists():
            _save(path, seed)


def load_collection(name: str) -> List[Dict[str, Any]]:
    path = FILES[name]
    return _load_or_empty(path)


def save_collection(name: str, data: List[Dict[str, Any]]) -> None:
    path = FILES[name]
    _save(path, data)


def upsert_item(name: str, item: Dict[str, Any]) -> Dict[str, Any]:
    data = load_collection(name)
    existing = {obj["id"]: obj for obj in data}
    existing[item["id"]] = item
    save_collection(name, list(existing.values()))
    return item


def delete_item(name: str, item_id: str) -> bool:
    data = load_collection(name)
    new_data = [obj for obj in data if obj.get("id") != item_id]
    if len(new_data) != len(data):
        save_collection(name, new_data)
        return True
    return False

