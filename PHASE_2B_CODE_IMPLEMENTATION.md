# Phase 2B: Code Implementation - CloudKit Integration

**Status:** 🔴 NOT STARTED
**Estimated Time:** 2 hours
**Date Started:** October 24, 2026

---

## Overview

You're going to update your app code to:
1. Check internet connectivity
2. Try CloudKit when online
3. Fall back to local storage when offline
4. Show sync status to user

---

## What We're Building

### Architecture

```
┌──────────────────────────────────┐
│     User Interface               │
│  (LoginView, ProfileView, etc)   │
└────────────┬─────────────────────┘
             │
┌────────────▼─────────────────────┐
│  AuthenticationManager           │
│  • Checks internet connectivity  │
│  • Routes to cloud or local      │
│  • Manages auth state            │
└────────────┬─────────────────────┘
             │
    ┌────────┴────────┐
    │                 │
┌───▼─────────┐  ┌──▼──────────────────┐
│ UserDefaults│  │ CloudKitSyncService │
│ (Local)     │  │ (Cloud + Sync)      │
└─────────────┘  └──┬───────────────────┘
                 │
          ┌──────▼────────┐
          │ CloudKit      │
          │ (Production)  │
          └───────────────┘
```

---

## Files We're Creating/Modifying

### NEW Files
1. **CloudKitSyncService.swift** - Handles sync logic
2. **SyncStatusView.swift** - UI showing sync status

### MODIFIED Files
1. **AuthenticationManager.swift** - Add internet check + routing
2. **CloudKitUserService.swift** - Update with smart routing

---

## Step-by-Step Implementation

### Step 1: Create Reachability Helper

First, we need a way to check internet connectivity.

**File to create:** `Packages/Common/Sources/Common/Utilities/Reachability.swift`

This will let us check if device has internet.

### Step 2: Update AuthenticationManager

**File to update:** `Packages/Authentication/Sources/Authentication/Services/AuthenticationManager.swift`

Changes:
- Import Reachability
- Add `isOnline` property
- Check internet before sign-in
- Route to CloudKit or local based on connectivity

### Step 3: Create CloudKitSyncService

**File to create:** `Packages/Authentication/Sources/Authentication/Services/CloudKitSyncService.swift`

Purpose: Handle all sync logic
- Save to both local + cloud
- Fetch from cloud with fallback
- Track sync status

### Step 4: Update CloudKitUserService

**File to update:** `Packages/Authentication/Sources/Authentication/Services/CloudKitUserService.swift`

Changes:
- Use CloudKitSyncService
- Better error handling
- Log sync status

### Step 5: Create SyncStatusView

**File to create:** `Packages/App/Sources/App/Views/SyncStatusView.swift`

Purpose: Show user sync indicator
- ✅ Synced (green)
- ⏳ Syncing (animation)
- ❌ Not Synced (red)
- 🔴 Offline (grey)

### Step 6: Build & Test

- Build in Xcode
- Run on simulator
- Verify no errors

---

## Code Implementation

Let me provide the exact code for each file...

[Continue in next message with actual code files]

---

## Testing Checklist

After implementing:

- [ ] Code compiles with 0 errors
- [ ] Code compiles with 0 warnings
- [ ] App launches on simulator
- [ ] Sign-in works with local storage
- [ ] Sync status view appears
- [ ] No crashes on CloudKit errors

---

## Timeline

This is Phase 2B, broken into parts:

**Part 1: Create Reachability** (10 min)
**Part 2: Update AuthenticationManager** (20 min)
**Part 3: Create CloudKitSyncService** (30 min)
**Part 4: Update CloudKitUserService** (20 min)
**Part 5: Create SyncStatusView** (20 min)
**Part 6: Build & Verify** (20 min)

**TOTAL: ~2 hours**

---

## Next: I'll provide all the code files ready to copy/paste

