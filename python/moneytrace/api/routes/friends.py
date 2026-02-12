# api/routes/friends.py
"""
Friend endpoints.

POST /friends - Create a new friend
GET /friends - List all friends
GET /friends/{friend_id} - Get friend details

Thin layer - validates input, delegates to db.py for persistence.
"""

from fastapi import APIRouter, HTTPException, Path
from ..schemas import FriendCreate, FriendResponse, FriendDetail, EventResponse
from ..deps import get_db_connection
from ...db import create_friend, get_all_friends, get_friend_by_id, get_events_by_friend

router = APIRouter(prefix="/friends", tags=["friends"])


@router.post("", response_model=FriendResponse, status_code=201)
def create_friend_endpoint(friend_data: FriendCreate):
    """Create a new friend."""
    try:
        with get_db_connection() as conn:
            friend_id = create_friend(conn, friend_data.name)
            return FriendResponse(id=friend_id, name=friend_data.name)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create friend: {str(e)}")


@router.get("", response_model=list[FriendResponse])
def list_friends_endpoint():
    """Get all friends."""
    try:
        with get_db_connection() as conn:
            friends = get_all_friends(conn)
            return [
                FriendResponse(id=f["id"], name=f["name"])
                for f in friends
            ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch friends: {str(e)}")


@router.get("/{friend_id}", response_model=FriendDetail)
def get_friend_details(friend_id: str = Path(..., description="Friend ID")):
    """Get detailed information about a specific friend including their events."""
    try:
        with get_db_connection() as conn:
            friend = get_friend_by_id(conn, friend_id)
            if not friend:
                raise HTTPException(status_code=404, detail="Friend not found")

            events = get_events_by_friend(conn, friend_id)

            return FriendDetail(
                friend=FriendResponse(id=friend["id"], name=friend["name"]),
                balance=0,  # Will be computed from events
                events=[
                    EventResponse(
                        id=e["id"],
                        timestamp=e["event_date"],
                        event_type=e["type"],
                        amount=e["amount"],
                        category=e["category"],
                        note=e["description"],
                        friend_id=e["friend_id"],
                        parent_event_id=None,
                    )
                    for e in events
                ],
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch friend details: {str(e)}")


