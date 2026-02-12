# Troubleshooting Static File Issues

## Quick Fix Instructions

### Step 1: Verify Static Files Are Being Served

Run this test:
```bash
cd /home/prakhar/LukeDev/MoneyTrace/python
python test_static.py
```

You should see all tests passing with status code 200.

### Step 2: Start the Server

```bash
cd /home/prakhar/LukeDev/MoneyTrace/python
python moneytrace/server.py
```

You should see:
```
Static directory: /home/prakhar/LukeDev/MoneyTrace/python/moneytrace/static/pwa
Static directory exists: True
✓ Static files mounted from /home/prakhar/LukeDev/MoneyTrace/python/moneytrace/static/pwa
✓ Database initialized
INFO:     Uvicorn running on http://127.0.0.1:8000
```

### Step 3: Open in Browser

1. Open: http://127.0.0.1:8000
2. Open Browser Developer Console (F12)
3. Check for JavaScript errors in the Console tab
4. Check the Network tab to see if files are loading

### Step 4: Test Page

If the main page doesn't work, try the test page:
- http://127.0.0.1:8000/test.html

This will show which scripts are loading successfully.

## Common Issues

### Issue 1: 404 Errors for Static Files

**Symptoms:**
```
GET /pwa/css/app.css HTTP/1.1" 404 Not Found
GET /pwa/js/app.js HTTP/1.1" 404 Not Found
```

**Solution:**
The paths in index.html should NOT have `/pwa/` prefix because the static mount is already at the PWA directory.

**Correct paths in index.html:**
```html
<link rel="stylesheet" href="/css/app.css">
<script src="/js/api.js"></script>
<script src="/js/screens.js"></script>
<script src="/js/app.js"></script>
```

**NOT:**
```html
<link rel="stylesheet" href="/pwa/css/app.css">  <!-- WRONG -->
```

### Issue 2: Buttons Not Working

**Symptoms:**
- Navigation buttons visible but don't respond to clicks
- No screen changes when clicking buttons

**Possible Causes:**

1. **JavaScript not loading**: Check browser console for errors
2. **CSS selector mismatch**: The HTML uses `id="app"` not `class="app"`
3. **Event listeners not binding**: Check if `App.init()` is being called

**Debug Steps:**

1. Open browser console (F12)
2. Type: `window.App`
   - Should show the App object
3. Type: `window.API`
   - Should show the API object
4. Type: `window.Screens`
   - Should show the Screens object

If any are undefined, those scripts didn't load.

### Issue 3: CORS Errors

**Symptoms:**
```
Access to fetch at 'http://127.0.0.1:8000/api/...' from origin '...' has been blocked
```

**Solution:**
CORS is already configured in main.py. Make sure you're accessing from `http://127.0.0.1:8000`, not `localhost:8000` or another origin.

## Files to Check

### 1. index.html
Should have:
```html
<div id="app">  <!-- NOT class="app" -->
```

And script tags WITHOUT `/pwa/` prefix:
```html
<script src="/js/api.js"></script>
<script src="/js/screens.js"></script>
<script src="/js/app.js"></script>
```

### 2. main.py
Should have at the end:
```python
static_dir = Path(__file__).parent.parent / "static" / "pwa"
static_dir = static_dir.resolve()

if static_dir.exists():
    app.mount("/", StaticFiles(directory=str(static_dir), html=True), name="static")
```

### 3. app.css
Should have:
```css
#app {
    /* styles for the main app container */
}
```

NOT `.app` (class selector).

## Manual Test

Run this in browser console after page loads:

```javascript
// Test 1: Check if objects exist
console.log('API:', typeof API);
console.log('Screens:', typeof Screens);
console.log('App:', typeof App);

// Test 2: Check if navigation is bound
const navButtons = document.querySelectorAll('.nav-btn');
console.log('Nav buttons found:', navButtons.length);

// Test 3: Try to manually trigger navigation
App.showScreen('add-event');
```

## Expected Behavior

When clicking a navigation button:
1. Button should get `active` class
2. Main content area should update with new screen
3. No errors in console

## Still Not Working?

If after all these steps it still doesn't work:

1. **Check browser console** for JavaScript errors
2. **Check network tab** - all files should return 200 OK
3. **Try a different browser** (Chrome, Firefox)
4. **Clear browser cache** (Ctrl+Shift+R or Cmd+Shift+R)
5. **Restart the server**

## Contact/Report

If you find a specific error, note:
- The exact error message from browser console
- The network request that failed (if any)
- Browser version
- Steps to reproduce

