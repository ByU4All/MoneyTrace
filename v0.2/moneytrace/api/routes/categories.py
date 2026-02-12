"""
Category management endpoints.

GET    /categories      - List all categories (with spending)
GET    /categories/list - List all categories (simple)
POST   /categories      - Add new category
PUT    /categories/{id} - Rename category
DELETE /categories/{id} - Delete category
"""

from fastapi import APIRouter, HTTPException, Query

from ..schemas import CategoryCreate, CategoryUpdate, CategoryResponse, CategoryDeleteRequest
from ..deps import get_db

router = APIRouter(prefix="/categories", tags=["categories"])


@router.post("", response_model=CategoryResponse, status_code=201)
def create_category(category: CategoryCreate):
    """Create a new category."""
    try:
        db = get_db()

        # Check if category already exists
        existing = db.get_category_by_name(category.name)
        if existing:
            raise HTTPException(
                status_code=400,
                detail=f"Category '{category.name}' already exists"
            )

        cat_id = db.add_category(category.name)

        return CategoryResponse(
            id=cat_id,
            name=category.name,
            is_default=False,
            usage_count=0
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{category_id}", response_model=CategoryResponse)
def update_category(category_id: str, update: CategoryUpdate):
    """Rename a category."""
    try:
        db = get_db()

        # Check if category exists
        existing = db.get_category(category_id)
        if not existing:
            raise HTTPException(status_code=404, detail="Category not found")

        # Check if new name already exists
        name_check = db.get_category_by_name(update.name)
        if name_check and name_check["id"] != category_id:
            raise HTTPException(
                status_code=400,
                detail=f"Category '{update.name}' already exists"
            )

        success = db.rename_category(category_id, update.name)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to rename category")

        usage = db.get_category_usage(category_id)

        return CategoryResponse(
            id=category_id,
            name=update.name,
            is_default=bool(existing["is_default"]),
            usage_count=usage
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{category_id}")
def delete_category(
    category_id: str,
    reassign_to: str = Query("Other", description="Category to reassign events to")
):
    """
    Delete a category and reassign its events to another category.

    Default categories cannot be deleted.
    """
    try:
        db = get_db()

        # Check if category exists
        existing = db.get_category(category_id)
        if not existing:
            raise HTTPException(status_code=404, detail="Category not found")

        # Prevent deleting default categories
        if existing["is_default"]:
            raise HTTPException(
                status_code=400,
                detail="Cannot delete default categories"
            )

        # Check if reassign target exists
        target = db.get_category_by_name(reassign_to)
        if not target:
            raise HTTPException(
                status_code=400,
                detail=f"Reassignment category '{reassign_to}' not found"
            )

        # Get usage count before deleting
        usage = db.get_category_usage(category_id)

        success = db.delete_category(category_id, reassign_to)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to delete category")

        return {
            "status": "ok",
            "message": f"Category deleted, {usage} events reassigned to '{reassign_to}'"
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/list")
def list_categories():
    """Get simple list of all categories."""
    try:
        db = get_db()
        return db.get_categories()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("")
def get_categories_with_usage():
    """Get all categories with usage counts."""
    try:
        db = get_db()
        categories = db.get_categories()

        result = []
        for cat in categories:
            usage = db.get_category_usage(cat["id"])
            result.append(CategoryResponse(
                id=cat["id"],
                name=cat["name"],
                is_default=bool(cat["is_default"]),
                usage_count=usage
            ))

        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

