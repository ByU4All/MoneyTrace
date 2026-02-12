"""
Friend endpoints.

POST /friends           - Create a new friend
GET  /friends           - List all friends with balances
GET  /friends/{id}      - Get friend details
"""

from fastapi import APIRouter, HTTPException, Path

from ..schemas import FriendCreate, FriendResponse, FriendWithBalance, EventResponse
from ..deps import get_db
from ...core.engine import compute_friend_balances

router = APIRouter(prefix="/friends", tags=["friends"])


@router.post("", response_model=FriendResponse, status_code=201)
def create_friend(friend: FriendCreate):
    """Create a new friend."""
    try:
        db = get_db()
        friend_id = db.create_friend(name=friend.name, phone=friend.phone)
        return FriendResponse(id=friend_id, name=friend.name, phone=friend.phone)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create friend: {str(e)}")


@router.get("", response_model=list[FriendWithBalance])
def list_friends():
    """Get all friends with their balances."""
    try:
        db = get_db()
        friends = db.get_friends()
        events = db.get_events_for_engine()

        # Compute balances
        balances = compute_friend_balances(events)

        return [
            FriendWithBalance(
                id=f["id"],
                name=f["name"],
                phone=f.get("phone"),
                balance=balances.get(f["id"], 0),
            )
            for f in friends
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch friends: {str(e)}")


@router.get("/{friend_id}", response_model=dict)
def get_friend_details(friend_id: str = Path(..., description="Friend ID")):
    """Get detailed information about a friend including their events."""
    try:
        db = get_db()
        friend = db.get_friend(friend_id)

        if not friend:
            raise HTTPException(status_code=404, detail="Friend not found")

        events = db.get_events_by_friend(friend_id)
        all_events = db.get_events_for_engine()
        balances = compute_friend_balances(all_events)

        return {
            "friend": FriendResponse(
                id=friend["id"],
                name=friend["name"],
                phone=friend.get("phone"),
            ),
            "balance": balances.get(friend_id, 0),
            "events": [
                EventResponse(
                    id=e["id"],
                    type=e["type"],
                    amount=e["amount"],
                    category=e["category"],
                    description=e["description"],
                    friend_id=e["friend_id"],
                    event_date=e["event_date"],
                )
                for e in events
            ],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch friend: {str(e)}")


