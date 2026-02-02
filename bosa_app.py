"""
Flask applicatie voor BOSA formulier automatisch invullen.
Interactieve web interface voor het beheren en invullen van BOSA subsidie aanvragen.
"""
import os
import json
from flask import Flask, render_template, request, jsonify, send_file
from pathlib import Path
from bosa_data_manager import BOSADataManager
from bosa_form_filler_improved import BOSAFormFillerImproved as BOSAFormFiller
import pandas as pd


app = Flask(__name__, 
            static_folder="bosa_static", 
            template_folder="bosa_templates",
            static_url_path="/static")
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

data_manager = BOSADataManager()


@app.route("/")
def index():
    """Hoofdpagina met formulier interface."""
    return render_template("bosa_index.html")


@app.route("/api/load-data", methods=["GET"])
def load_data():
    """Laad opgeslagen formulierdata."""
    data = data_manager.load_form_data()
    if data:
        return jsonify({"success": True, "data": data})
    return jsonify({"success": False, "message": "Geen opgeslagen data gevonden"})


@app.route("/api/save-data", methods=["POST"])
def save_data():
    """Sla formulierdata op."""
    try:
        form_data = request.json
        file_path = data_manager.save_form_data(form_data)
        return jsonify({"success": True, "message": f"Data opgeslagen in {file_path}"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/load-costs", methods=["GET"])
def load_costs():
    """Laad kosten data uit Excel."""
    costs = data_manager.load_costs_data()
    return jsonify({"success": True, "costs": costs})


@app.route("/api/save-costs", methods=["POST"])
def save_costs():
    """Sla kosten data op in Excel."""
    try:
        costs = request.json.get("costs", [])
        file_path = data_manager.save_costs_data(costs)
        return jsonify({"success": True, "message": f"Kosten opgeslagen in {file_path}"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/upload-costs-excel", methods=["POST"])
def upload_costs_excel():
    """Upload een Excel bestand met kosten data."""
    try:
        if 'file' not in request.files:
            return jsonify({"success": False, "message": "Geen bestand geüpload"}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({"success": False, "message": "Geen bestand geselecteerd"}), 400
        
        # Sla tijdelijk op
        temp_path = Path("temp") / file.filename
        temp_path.parent.mkdir(exist_ok=True)
        file.save(str(temp_path))
        
        # Lees Excel
        df = pd.read_excel(temp_path, engine='openpyxl')
        costs = df.to_dict('records')
        
        # Sla op
        data_manager.save_costs_data(costs)
        
        # Verwijder temp bestand
        temp_path.unlink()
        
        return jsonify({"success": True, "costs": costs, "message": "Kosten Excel geladen"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/get-documents", methods=["GET"])
def get_documents():
    """Haal lijst van documenten op uit kosten directory."""
    documents = data_manager.get_cost_documents()
    return jsonify({"success": True, "documents": documents})


@app.route("/api/fill-form", methods=["POST"])
def fill_form():
    """Start het automatisch invullen van het formulier."""
    try:
        data = request.json
        form_data = data.get("formData", {})
        costs_data = data.get("costsData", [])
        documents_dir = data.get("documentsDir")
        use_saved_data = data.get("useSavedData", False)
        
        # Als gebruik gemaakt moet worden van opgeslagen data
        if use_saved_data:
            saved_data = data_manager.load_form_data()
            if saved_data:
                # Merge met nieuwe data (nieuwe data heeft voorrang)
                for key, value in saved_data.items():
                    if key not in form_data:
                        form_data[key] = value
        
        # Als er geen kosten data is, laad uit Excel
        if not costs_data:
            costs_data = data_manager.load_costs_data()
        
        # Start browser automation
        filler = BOSAFormFiller(headless=False)
        success = filler.fill_complete_form(form_data, costs_data, documents_dir)
        
        if success:
            return jsonify({
                "success": True,
                "message": "Formulier invullen gestart. Controleer de browser."
            })
        else:
            return jsonify({
                "success": False,
                "message": "Fout bij invullen formulier. Controleer de console."
            }), 500
            
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/api/download-excel", methods=["GET"])
def download_excel():
    """Download het Excel bestand met formulierdata."""
    excel_file = data_manager.excel_file
    if excel_file.exists():
        return send_file(str(excel_file), as_attachment=True, 
                        download_name="bosa_formulier_data.xlsx")
    return jsonify({"success": False, "message": "Geen Excel bestand gevonden"}), 404


@app.route("/api/download-costs-excel", methods=["GET"])
def download_costs_excel():
    """Download het Excel bestand met kosten data."""
    excel_file = data_manager.costs_excel_file
    if excel_file.exists():
        return send_file(str(excel_file), as_attachment=True,
                        download_name="bosa_kosten.xlsx")
    return jsonify({"success": False, "message": "Geen kosten Excel bestand gevonden"}), 404


if __name__ == "__main__":
    # Zorg dat directories bestaan
    os.makedirs("bosa_static", exist_ok=True)
    os.makedirs("bosa_templates", exist_ok=True)
    os.makedirs("bosa_data", exist_ok=True)
    
    app.run(host="0.0.0.0", port=8001, debug=True)

