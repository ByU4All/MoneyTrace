"""
Settings endpoints.

GET  /settings   - Get app settings
PUT  /settings   - Update settings
GET  /export     - Export all data
POST /import     - Import data backup
"""

import json
from fastapi import APIRouter, HTTPException, UploadFile, File
from fastapi.responses import JSONResponse

from ..schemas import SettingsResponse, SettingsUpdate, ExportResponse
from ..deps import get_db

router = APIRouter(tags=["settings"])


@router.get("/settings", response_model=SettingsResponse)
def get_settings():
    """Get application settings."""
    try:
        db = get_db()
        return SettingsResponse(
            base_budget=db.get_base_budget(),
            currency_symbol="₹",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/settings", response_model=SettingsResponse)
def update_settings(settings: SettingsUpdate):
    """Update application settings."""
    try:
        db = get_db()

        if settings.base_budget is not None:
            db.set_base_budget(settings.base_budget)

        return SettingsResponse(
            base_budget=db.get_base_budget(),
            currency_symbol="₹",
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/export")
def export_data():
    """Export all data as JSON for backup."""
    try:
        db = get_db()
        data = db.export_all()
        return JSONResponse(content=data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/import")
async def import_data(file: UploadFile = File(...)):
    """Import data from a JSON backup file."""
    try:
        content = await file.read()
        data = json.loads(content)

        db = get_db()
        db.import_all(data)

        return {"status": "ok", "message": "Data imported successfully"}
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON file")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


