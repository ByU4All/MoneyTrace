# MoneyTrace Mobile App Conversion Plan

> **Version**: Planning Document  
> **Created**: February 13, 2026  
> **Status**: Planning Phase

---

## Overview

This document outlines the options and steps to convert MoneyTrace from a Python/FastAPI PWA into a standalone mobile app. The app will be **local-only** (no cloud sync) - all data stays on the user's device.

---

## Current Architecture

| Layer | Technology | Files |
|-------|------------|-------|
| Backend | Python/FastAPI | `server.py`, `engine.py`, `db.py` |
| Database | SQLite | `~/.moneytrace/moneytrace.db` |
| Frontend | Vanilla JS + CSS | `app.js`, `screens.js`, `api.js`, `app.css` |
| PWA | Service Worker | `sw.js`, `manifest.json` |

---

## Table of Contents

1. [Option A: React Native + SQLite](#option-a-react-native--sqlite-recommended)
2. [Option B: Capacitor (Wrap Existing Web App)](#option-b-capacitor-wrap-existing-web-app)
3. [Option C: Kivy (Keep Python)](#option-c-kivy-keep-python)
4. [Option D: BeeWare/Toga](#option-d-beewaretoga-keep-python-native-ui)
5. [Recommendation Matrix](#recommendation-matrix)
6. [Recommended Approach](#recommended-approach)
7. [Further Considerations](#further-considerations)

---

## Option A: React Native + SQLite (Recommended)

**Best for**: Native feel, best performance, largest ecosystem

### Tech Stack
- **Framework**: React Native (or Expo for easier setup)
- **Database**: `react-native-sqlite-storage` or `expo-sqlite`
- **UI**: React Native Paper / NativeBase (Material Design)
- **Navigation**: React Navigation
- **Language**: TypeScript

### Pros
- ✅ Best native performance and feel
- ✅ Huge ecosystem and community support
- ✅ Hot reload for fast development
- ✅ Single codebase for iOS + Android
- ✅ Easy to add native features (notifications, file access)

### Cons
- ❌ Requires rewriting Python logic to TypeScript
- ❌ Steeper learning curve if new to React
- ❌ Larger initial setup time

### Implementation Steps

#### 1. Initialize React Native Project
```bash
# Using Expo (easier)
npx create-expo-app MoneyTrace --template blank-typescript

# Or using React Native CLI (more control)
npx react-native init MoneyTrace --template react-native-template-typescript
```

#### 2. Install Dependencies
```bash
# For Expo
npx expo install expo-sqlite expo-file-system

# For React Native CLI
npm install react-native-sqlite-storage
npm install @react-navigation/native @react-navigation/bottom-tabs
npm install react-native-paper
```

#### 3. Port Database Layer (Python → TypeScript)
Convert `moneytrace/storage/db.py` → `src/storage/database.ts`

```typescript
// src/storage/database.ts
import * as SQLite from 'expo-sqlite';

const db = SQLite.openDatabase('moneytrace.db');

export const initDatabase = () => {
  db.transaction(tx => {
    tx.executeSql(`
      CREATE TABLE IF NOT EXISTS events (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        category TEXT,
        description TEXT,
        friend_id TEXT,
        account_id TEXT,
        event_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    `);
    // ... more tables
  });
};

export const createEvent = (event: EventCreate): Promise<string> => {
  return new Promise((resolve, reject) => {
    db.transaction(tx => {
      tx.executeSql(
        `INSERT INTO events (id, type, amount, ...) VALUES (?, ?, ?, ...)`,
        [uuid(), event.type, event.amount, ...],
        (_, result) => resolve(result.insertId),
        (_, error) => reject(error)
      );
    });
  });
};
```

#### 4. Port Engine Logic (Python → TypeScript)
Convert `moneytrace/core/engine.py` → `src/core/engine.ts`

```typescript
// src/core/engine.ts
import { EventType, Event } from './types';

export const computeAvailableBudget = (
  baseBudget: number,
  events: Event[]
): number => {
  let budget = baseBudget;

  for (const e of events) {
    switch (e.type) {
      case EventType.EXPENSE:
        budget -= e.amount;
        break;
      case EventType.LIABILITY:
        budget -= e.amount;
        break;
      case EventType.SETTLEMENT_RECEIVED:
        budget += e.amount;
        break;
      case EventType.BUDGET_ADJUSTMENT:
        budget += e.amount;
        break;
      case EventType.EMI_PAYMENT:
        budget -= e.amount;
        break;
    }
  }

  return budget;
};
```

#### 5. Port Event Types (Python → TypeScript)
Convert `moneytrace/core/events.py` → `src/core/types.ts`

```typescript
// src/core/types.ts
export enum EventType {
  EXPENSE = 'expense',
  LIABILITY = 'liability',
  RECEIVABLE = 'receivable',
  SETTLEMENT_PAID = 'settlement_paid',
  SETTLEMENT_RECEIVED = 'settlement_received',
  BUDGET_ADJUSTMENT = 'budget_adjustment',
  TRANSFER = 'transfer',
  INCOME = 'income',
  CREDIT_CARD_PAYMENT = 'credit_card_payment',
  EMI_PAYMENT = 'emi_payment',
}

export interface Event {
  id: string;
  type: EventType;
  amount: number;
  category?: string;
  description?: string;
  friendId?: string;
  accountId?: string;
  eventDate: string;
  createdAt: string;
}
```

#### 6. Build React Native Screens
Port from `screens.js` to React Native components:

| Current (JS) | React Native |
|--------------|--------------|
| `Screens.dashboard()` | `src/screens/DashboardScreen.tsx` |
| `Screens.addEvent()` | `src/screens/AddEventScreen.tsx` |
| `Screens.accounts()` | `src/screens/AccountsScreen.tsx` |
| `Screens.recurring()` | `src/screens/RecurringScreen.tsx` |
| `Screens.settings()` | `src/screens/SettingsScreen.tsx` |
| `Screens.friends()` | `src/screens/FriendsScreen.tsx` |
| `Screens.history()` | `src/screens/HistoryScreen.tsx` |

#### 7. Build for Android/iOS
```bash
# Expo
npx expo build:android
npx expo build:ios  # Requires Mac

# React Native CLI
cd android && ./gradlew assembleRelease
```

---

## Option B: Capacitor (Wrap Existing Web App)

**Best for**: Fastest conversion, minimal rewrite

### Tech Stack
- **Wrapper**: Capacitor (by Ionic team)
- **Database**: `@capacitor-community/sqlite` or SQL.js
- **Existing**: Keep HTML/CSS/JS mostly as-is

### Pros
- ✅ Fastest path to working APK
- ✅ Reuse existing HTML/CSS/JS
- ✅ Familiar web technologies
- ✅ Good plugin ecosystem

### Cons
- ❌ Not as native-feeling as React Native
- ❌ Still need to port Python to JavaScript
- ❌ WebView performance limitations

### Implementation Steps

#### 1. Remove Python Backend Dependency
Port backend logic to client-side JavaScript:

```
moneytrace/storage/db.py    → static/js/db.js
moneytrace/core/engine.py   → static/js/engine.js
moneytrace/core/events.py   → static/js/types.js
```

#### 2. Update API Layer
Change `api.js` from HTTP calls to direct function calls:

```javascript
// Before (HTTP)
async getSummary() {
  return this.request('/summary');
}

// After (Local)
async getSummary() {
  const db = await getDatabase();
  const events = db.getEventsForEngine();
  const baseBudget = db.getBaseBudget();
  return {
    budget_remaining: computeAvailableBudget(baseBudget, events),
    // ...
  };
}
```

#### 3. Initialize Capacitor
```bash
cd v0.2/moneytrace/static
npm init -y
npm install @capacitor/core @capacitor/cli @capacitor/android
npm install @capacitor-community/sqlite

npx cap init MoneyTrace com.moneytrace.app --web-dir .
npx cap add android
```

#### 4. Configure Capacitor
```json
// capacitor.config.json
{
  "appId": "com.moneytrace.app",
  "appName": "MoneyTrace",
  "webDir": ".",
  "bundledWebRuntime": false,
  "plugins": {
    "CapacitorSQLite": {
      "iosDatabaseLocation": "Library/CapacitorDatabase"
    }
  }
}
```

#### 5. Build APK
```bash
npx cap sync
npx cap open android  # Opens Android Studio
# Build → Generate Signed APK
```

---

## Option C: Kivy (Keep Python)

**Best for**: Reuse Python code directly, minimal porting

### Tech Stack
- **Framework**: Kivy + KivyMD (Material Design)
- **Packaging**: Buildozer (for Android APK)
- **Database**: Same SQLite code (unchanged)

### Pros
- ✅ Keep all Python backend code unchanged
- ✅ Single Python codebase
- ✅ Good for Python developers

### Cons
- ❌ UI doesn't feel native
- ❌ Larger APK size (~30MB+)
- ❌ Slower than native
- ❌ Buildozer can be finicky

### Implementation Steps

#### 1. Install Kivy Dependencies
```bash
pip install kivy kivymd buildozer cython
```

#### 2. Create Kivy UI (Replace HTML/JS)
```python
# main.py
from kivy.app import App
from kivymd.app import MDApp
from kivymd.uix.screen import MDScreen
from kivymd.uix.card import MDCard
from kivymd.uix.label import MDLabel

from moneytrace.storage.db import Database
from moneytrace.core.engine import compute_available_budget

class DashboardScreen(MDScreen):
    def on_enter(self):
        db = Database()
        events = db.get_events_for_engine()
        budget = db.get_base_budget()
        remaining = compute_available_budget(budget, events)
        
        self.ids.budget_label.text = f"₹{remaining / 100:,.0f}"

class MoneyTraceApp(MDApp):
    def build(self):
        self.theme_cls.theme_style = "Dark"
        self.theme_cls.primary_palette = "Red"
        return DashboardScreen()

if __name__ == '__main__':
    MoneyTraceApp().run()
```

#### 3. Create Kivy Layout Files
```kv
# dashboard.kv
<DashboardScreen>:
    MDBoxLayout:
        orientation: 'vertical'
        padding: dp(16)
        
        MDCard:
            size_hint_y: None
            height: dp(150)
            MDLabel:
                id: budget_label
                text: "Loading..."
                halign: "center"
                font_style: "H3"
```

#### 4. Create buildozer.spec
```bash
buildozer init
```

Edit `buildozer.spec`:
```ini
[app]
title = MoneyTrace
package.name = moneytrace
package.domain = org.moneytrace
source.include_exts = py,kv,json
version = 0.4.2

requirements = python3,kivy,kivymd,sqlite3,pydantic

android.permissions = WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE
android.api = 33
android.minapi = 21
android.arch = arm64-v8a
```

#### 5. Build Android APK
```bash
buildozer android debug
# Output: bin/moneytrace-0.4.2-debug.apk
```

---

## Option D: BeeWare/Toga (Keep Python, Native UI)

**Best for**: Native UI widgets with Python, cleaner than Kivy

### Tech Stack
- **Framework**: BeeWare (Toga for UI, Briefcase for packaging)
- **Database**: Same SQLite code (unchanged)

### Pros
- ✅ Native UI widgets (not custom-drawn like Kivy)
- ✅ Keep Python codebase
- ✅ Single codebase for mobile + desktop

### Cons
- ❌ Smaller ecosystem than React Native
- ❌ Less mature than other options
- ❌ Limited UI component library

### Implementation Steps

#### 1. Install BeeWare
```bash
pip install briefcase toga
```

#### 2. Initialize Project
```bash
briefcase new
# Follow prompts: MoneyTrace, com.moneytrace, etc.
```

#### 3. Create Toga UI
```python
# src/moneytrace/app.py
import toga
from toga.style import Pack
from toga.style.pack import COLUMN, CENTER

from .storage.db import Database
from .core.engine import compute_available_budget

class MoneyTrace(toga.App):
    def startup(self):
        self.db = Database()
        
        self.main_window = toga.MainWindow(title=self.formal_name)
        
        # Budget card
        budget = self.get_budget_remaining()
        budget_label = toga.Label(
            f"₹{budget / 100:,.0f}",
            style=Pack(font_size=36, text_align=CENTER)
        )
        
        main_box = toga.Box(
            children=[budget_label],
            style=Pack(direction=COLUMN, padding=20)
        )
        
        self.main_window.content = main_box
        self.main_window.show()
    
    def get_budget_remaining(self):
        events = self.db.get_events_for_engine()
        base = self.db.get_base_budget()
        return compute_available_budget(base, events)

def main():
    return MoneyTrace()
```

#### 4. Build for Android
```bash
briefcase create android
briefcase build android
briefcase run android  # Or: briefcase package android
```

---

## Recommendation Matrix

| Criteria | React Native | Capacitor | Kivy | BeeWare |
|----------|:-----------:|:---------:|:----:|:-------:|
| **Native Feel** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **Development Speed** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Code Reuse** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **App Size** | ~15MB | ~10MB | ~30MB | ~20MB |
| **Ecosystem** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Future-proof** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Learning Curve** | Medium | Low | Medium | Low |
| **Notifications** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |

---

## Recommended Approach

### Phase 1: Quick MVP (1-2 days) - Capacitor

Use **Capacitor** to wrap the existing web app:
1. Port Python backend to JavaScript (db.js, engine.js)
2. Update api.js to call local functions
3. Package with Capacitor
4. Get working APK for testing

### Phase 2: Production App (1-2 weeks) - React Native

Migrate to **React Native** for better UX:
1. Set up React Native + TypeScript project
2. Port database layer
3. Port engine logic
4. Build native UI components
5. Add native features (notifications for bills)
6. Polish and publish to Play Store

---

## Further Considerations

### 1. Data Migration
How to handle existing Termux users' data?
- Add JSON export/import feature
- Read from standard path on Android

### 2. Notifications
For upcoming bill reminders:
- React Native: `expo-notifications` (excellent support)
- Capacitor: `@capacitor/local-notifications`
- Kivy: Limited support

### 3. Backup Strategy
Since no cloud sync:
- Local backup to Downloads folder
- Share via system file picker
- Scheduled auto-backup option

### 4. Offline Support
All options work offline since data is local. No additional work needed.

### 5. Platform Support

| Option | Android | iOS | Desktop |
|--------|:-------:|:---:|:-------:|
| React Native | ✅ | ✅ | ❌ |
| Capacitor | ✅ | ✅ | ✅ (Electron) |
| Kivy | ✅ | ✅ | ✅ |
| BeeWare | ✅ | ✅ | ✅ |

---

## Quick Start Commands

### React Native (Expo)
```bash
npx create-expo-app MoneyTraceMobile --template blank-typescript
cd MoneyTraceMobile
npx expo install expo-sqlite
npx expo start
```

### Capacitor
```bash
cd v0.2/moneytrace/static
npm init -y
npm install @capacitor/core @capacitor/cli @capacitor/android
npx cap init MoneyTrace com.moneytrace.app --web-dir .
npx cap add android
npx cap sync && npx cap open android
```

### Kivy
```bash
pip install kivy kivymd buildozer
buildozer init
# Edit buildozer.spec
buildozer android debug
```

### BeeWare
```bash
pip install briefcase toga
briefcase new
briefcase create android
briefcase build android
```

---

## Next Steps

1. **Choose approach** based on priorities (speed vs polish)
2. **Set up development environment** for chosen framework
3. **Port core logic** (db.py, engine.py)
4. **Build MVP** with essential screens
5. **Test on device**
6. **Add polish** (notifications, animations)
7. **Publish** to Play Store

---

*Last Updated: February 13, 2026*
