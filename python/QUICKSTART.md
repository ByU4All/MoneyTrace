# 🚀 Quick Start Guide - MoneyTrace PWA

## Start the Application

```bash
cd /home/prakhar/LukeDev/MoneyTrace/python
python moneytrace/server.py
```

Expected output:
```
Static directory: /home/prakhar/LukeDev/MoneyTrace/python/moneytrace/static/pwa
Static directory exists: True
✓ Static files mounted from /home/prakhar/LukeDev/MoneyTrace/python/moneytrace/static/pwa
✓ Database initialized
INFO:     Started server process [12345]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

## Access the Application

Open your browser and go to:
**http://127.0.0.1:8000**

## What You'll See

### Initial Page Load
- Header: "MoneyTrace"
- Bottom Navigation: 📊 Dashboard | ➕ Add | 👥 Friends | 📂 Categories
- Main content showing "Loading dashboard..."

### Navigation
Click any button in the bottom navigation to switch screens:
- **Dashboard**: Shows monthly summary (budget, spend, liabilities, receivables)
- **Add Event**: Form to create financial events
- **Friends**: List of friends with balances
- **Categories**: Monthly spending by category

## Test the App

### Test 1: Create an Expense
1. Click "➕ Add" button
2. Select "Expense" from type dropdown
3. Enter amount: `50.75` (you'll see "= 5,075 paise")
4. Enter category: `food`
5. Enter description: `Lunch` (optional)
6. Click "Add Event"
7. You'll be redirected to dashboard

### Test 2: Create a Friend Liability
1. First create a friend:
   - Click "👥 Friends"
   - (Friend creation UI may not be complete yet)
2. Click "➕ Add"
3. Select "I Owe Someone"
4. Friend dropdown appears
5. Select a friend
6. Enter amount and details
7. Click "Add Event"

## Troubleshooting

### Buttons Don't Work?

1. **Check Browser Console (Press F12)**
   - Look for errors
   - Should see no red error messages

2. **Check Network Tab (F12 → Network)**
   - Reload page (Ctrl+R)
   - All files should show 200 OK status
   - Look for: index.html, app.css, api.js, screens.js, app.js

3. **Test in Console**
   Open browser console and type:
   ```javascript
   window.App
   ```
   Should show the App object, not `undefined`

4. **Try Test Page**
   Go to: http://127.0.0.1:8000/test.html
   Should show which scripts loaded successfully

### Still Not Working?

Run the diagnostic script:
```bash
cd /home/prakhar/LukeDev/MoneyTrace/python
python test_static.py
```

All files should show ✓ with status 200.

See **TROUBLESHOOTING.md** for more details.

## API Endpoints

The app uses these API endpoints:

- `GET /api/health` - Health check
- `GET /api/summary?month=1&year=2026` - Monthly summary
- `GET /api/categories?month=1&year=2026` - Category spending
- `GET /api/events` - List events
- `POST /api/events` - Create event
- `GET /api/friends` - List friends
- `POST /api/friends` - Create friend

Test in browser console:
```javascript
// Test API
fetch('/api/health').then(r => r.json()).then(console.log)
```

## Development

### Run Tests
```bash
cd /home/prakhar/LukeDev/MoneyTrace/python
python -m pytest -v
```

Should show 40+ tests passing.

### File Structure
```
moneytrace/
├── api/
│   ├── main.py          # FastAPI app
│   ├── routes/          # API endpoints
│   └── schemas.py       # Request/response models
├── static/pwa/
│   ├── index.html       # Main HTML
│   ├── css/app.css      # Styles
│   └── js/
│       ├── api.js       # API client
│       ├── screens.js   # Screen renderers
│       └── app.js       # App logic
├── tests/               # Test files
└── db.py               # Database operations
```

## Next Steps

After verifying the app works:

1. **Step 5**: Implement Dashboard Summary UI (in progress)
2. Add more features as per `readme.md`
3. Install as PWA (manifest + service worker)

## Quick Reference

| Action | Command |
|--------|---------|
| Start server | `python moneytrace/server.py` |
| Run tests | `python -m pytest -v` |
| Test static files | `python test_static.py` |
| Check health | `curl http://127.0.0.1:8000/api/health` |

## Success!

If you see the MoneyTrace interface and can click buttons to switch screens, **Step 4 is complete!** 🎉

The Event Creation UI is fully functional with:
- ✅ All 6 event types
- ✅ Type-safe amount handling (paise)
- ✅ Smart friend selection
- ✅ Real-time amount conversion
- ✅ Full test coverage

Ready for Step 5! 🚀

