import uuid
from flask import Flask, jsonify, request, send_from_directory, render_template

from data.storage import (
    ensure_seed_data,
    load_collection,
    save_collection,
    upsert_item,
    delete_item,
)
from services.bonus_service import fetch_bonus_offers
from services.list_generation_service import generate_weekly_list


app = Flask(__name__, static_folder="static", template_folder="templates")


def _generate_id(prefix: str) -> str:
    return f"{prefix}-{uuid.uuid4().hex[:8]}"


@app.before_first_request
def bootstrap():
    ensure_seed_data()


@app.route("/")
def index():
    return render_template("index.html")


# --- Dishes endpoints ---
@app.route("/api/dishes", methods=["GET"])
def list_dishes():
    return jsonify(load_collection("dishes"))


@app.route("/api/dishes", methods=["POST"])
def create_dish():
    data = request.json or {}
    dish_id = data.get("id") or _generate_id("dish")
    dish = {
        "id": dish_id,
        "name": data.get("name", ""),
        "ingredients": data.get("ingredients", []),
        "persons": data.get("persons", 4),
        "note": data.get("note", ""),
    }
    upsert_item("dishes", dish)
    return jsonify(dish), 201


@app.route("/api/dishes/<dish_id>", methods=["PUT"])
def update_dish(dish_id):
    data = request.json or {}
    dish = {
        "id": dish_id,
        "name": data.get("name", ""),
        "ingredients": data.get("ingredients", []),
        "persons": data.get("persons", 4),
        "note": data.get("note", ""),
    }
    upsert_item("dishes", dish)
    return jsonify(dish)


@app.route("/api/dishes/<dish_id>", methods=["DELETE"])
def delete_dish(dish_id):
    deleted = delete_item("dishes", dish_id)
    return ("", 204) if deleted else (jsonify({"error": "Not found"}), 404)


# --- Standard items ---
@app.route("/api/standard-items", methods=["GET"])
def list_standard_items():
    category = request.args.get("category")
    items = load_collection("standard_items")
    if category:
        items = [i for i in items if i.get("category") == category]
    return jsonify(items)


@app.route("/api/standard-items", methods=["POST"])
def create_standard_item():
    data = request.json or {}
    item_id = data.get("id") or _generate_id("std")
    item = {
        "id": item_id,
        "category": data.get("category", "Overig"),
        "name": data.get("name", ""),
        "note": data.get("note", ""),
        "forWhom": data.get("forWhom", ""),
        "isFrequent": bool(data.get("isFrequent", False)),
    }
    upsert_item("standard_items", item)
    return jsonify(item), 201


@app.route("/api/standard-items/<item_id>", methods=["PUT"])
def update_standard_item(item_id):
    data = request.json or {}
    item = {
        "id": item_id,
        "category": data.get("category", "Overig"),
        "name": data.get("name", ""),
        "note": data.get("note", ""),
        "forWhom": data.get("forWhom", ""),
        "isFrequent": bool(data.get("isFrequent", False)),
    }
    upsert_item("standard_items", item)
    return jsonify(item)


@app.route("/api/standard-items/<item_id>", methods=["DELETE"])
def delete_standard_item(item_id):
    deleted = delete_item("standard_items", item_id)
    return ("", 204) if deleted else (jsonify({"error": "Not found"}), 404)


# --- Incidental items ---
@app.route("/api/incidental-items", methods=["GET"])
def list_incidental_items():
    category = request.args.get("category")
    items = load_collection("incidental_items")
    if category:
        items = [i for i in items if i.get("category") == category]
    return jsonify(items)


@app.route("/api/incidental-items", methods=["POST"])
def create_incidental_item():
    data = request.json or {}
    item_id = data.get("id") or _generate_id("inc")
    item = {
        "id": item_id,
        "category": data.get("category", "Overig"),
        "name": data.get("name", ""),
        "note": data.get("note", ""),
        "forWhom": data.get("forWhom", ""),
    }
    upsert_item("incidental_items", item)
    return jsonify(item), 201


@app.route("/api/incidental-items/<item_id>", methods=["PUT"])
def update_incidental_item(item_id):
    data = request.json or {}
    item = {
        "id": item_id,
        "category": data.get("category", "Overig"),
        "name": data.get("name", ""),
        "note": data.get("note", ""),
        "forWhom": data.get("forWhom", ""),
    }
    upsert_item("incidental_items", item)
    return jsonify(item)


@app.route("/api/incidental-items/<item_id>", methods=["DELETE"])
def delete_incidental_item(item_id):
    deleted = delete_item("incidental_items", item_id)
    return ("", 204) if deleted else (jsonify({"error": "Not found"}), 404)


@app.route("/api/bonus", methods=["GET"])
def bonus_offers():
    offers = fetch_bonus_offers()
    return jsonify(offers)


@app.route("/api/generate-list", methods=["POST"])
def generate_list():
    payload = request.json or {}
    dish_ids = payload.get("dishIds", [])
    standard_ids = payload.get("standardItemIds", [])
    incidental_ids = payload.get("incidentalItemIds", [])
    include_bonus = bool(payload.get("includeBonusSuggestions", True))

    all_dishes = {d["id"]: d for d in load_collection("dishes")}
    selected_dishes = [all_dishes[i] for i in dish_ids if i in all_dishes]

    std_map = {i["id"]: i for i in load_collection("standard_items")}
    selected_std = [std_map[i] for i in standard_ids if i in std_map]

    inc_map = {i["id"]: i for i in load_collection("incidental_items")}
    selected_inc = [inc_map[i] for i in incidental_ids if i in inc_map]

    offers = fetch_bonus_offers() if include_bonus else []

    result = generate_weekly_list(selected_dishes, selected_std, selected_inc, offers, include_bonus)
    return jsonify(result)


@app.route("/favicon.ico")
def favicon():
    return send_from_directory(app.static_folder, "favicon.ico", mimetype="image/vnd.microsoft.icon")


if __name__ == "__main__":
    ensure_seed_data()
    app.run(host="0.0.0.0", port=8000, debug=True)

