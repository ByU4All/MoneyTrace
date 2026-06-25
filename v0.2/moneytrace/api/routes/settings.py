"""
Settings endpoints.

GET  /settings   - Get app settings
PUT  /settings   - Update settings
GET  /export     - Export all data
POST /import     - Import data backup
POST /data/clear - Clear all data
"""

import json
from fastapi import APIRouter, HTTPException, UploadFile, File
from fastapi.responses import JSONResponse

from ..schemas import SettingsResponse, SettingsUpdate, ExportResponse, ClearDataRequest
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
            budget_reset_day=db.get_budget_reset_day(),
            budget_reset_enabled=db.get_budget_reset_enabled(),
            carry_over_enabled=db.get_carry_over_enabled(),
            carry_over_cap=db.get_carry_over_cap(),
            carry_over_negative=db.get_carry_over_negative(),
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

        if settings.budget_reset_day is not None:
            db.set_budget_reset_day(settings.budget_reset_day)

        if settings.budget_reset_enabled is not None:
            db.set_budget_reset_enabled(settings.budget_reset_enabled)

        if settings.carry_over_enabled is not None:
            db.set_carry_over_enabled(settings.carry_over_enabled)

        if settings.carry_over_cap is not None:
            # 0 means unlimited
            db.set_carry_over_cap(settings.carry_over_cap if settings.carry_over_cap > 0 else None)

        if settings.carry_over_negative is not None:
            db.set_carry_over_negative(settings.carry_over_negative)

        return SettingsResponse(
            base_budget=db.get_base_budget(),
            currency_symbol="₹",
            budget_reset_day=db.get_budget_reset_day(),
            budget_reset_enabled=db.get_budget_reset_enabled(),
            carry_over_enabled=db.get_carry_over_enabled(),
            carry_over_cap=db.get_carry_over_cap(),
            carry_over_negative=db.get_carry_over_negative(),
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


@router.post("/data/clear")
def clear_data(request: ClearDataRequest):
    """
    Clear all transaction data.

    Requires confirmation by passing confirm="DELETE".
    Keeps settings and categories.
    Optionally keeps friends list.
    """
    if request.confirm != "DELETE":
        raise HTTPException(
            status_code=400,
            detail="Confirmation required. Set confirm='DELETE' to proceed."
        )

    try:
        db = get_db()
        db.clear_all_data(keep_friends=request.keep_friends)

        return {
            "status": "ok",
            "message": "All data cleared successfully",
            "kept_friends": request.keep_friends
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


