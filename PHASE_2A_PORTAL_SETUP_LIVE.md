# Phase 2A: Apple Portal Setup - Live Walkthrough

**Status:** 🔴 NOT STARTED
**Estimated Time:** 2-3 hours
**Complexity:** Easy (copy-paste instructions)
**Date Started:** October 24, 2026

---

## Overview

You're going to:
1. Go to Apple Developer Portal
2. Enable CloudKit on your app
3. Create CloudKit schema (3 record types)
4. Configure permissions
5. Deploy to production
6. Verify it worked

---

## Prerequisites Checklist

Before you start, verify you have:
- [ ] Apple Developer account access
- [ ] Can access https://developer.apple.com
- [ ] Can access https://icloud.developer.apple.com
- [ ] Know your app ID: com.holsinger.chapterfinder
- [ ] Know your container ID: iCloud.com.holsinger.chapterfinder

---

## STEP 1: Enable CloudKit on App ID

### 1.1 Go to Certificates, Identifiers & Profiles
```
URL: https://developer.apple.com/account
Login with your Apple Developer account
Navigate to: Certificates, Identifiers & Profiles
Click: Identifiers
```

**Screenshot this step for debugging if needed**

### 1.2 Find Your App ID
```
In the Identifiers list, search for: com.holsinger.chapterfinder
Click to open it
```

### 1.3 Enable CloudKit
```
Scroll down to: iCloud
Find the CloudKit checkbox (☑)
Status should say: ☑ CloudKit
If not checked, check it now
```

**IMPORTANT:** Look for this section:
```
iCloud
☑ CloudKit
```

### 1.4 Save Changes
```
Scroll to bottom
Click: Save
Wait for: "Identifier updated successfully"
```

**If you see an error:** Take a screenshot and share it. We'll debug.

---

## STEP 2: Create iCloud Container

### 2.1 Still in App ID Details
```
Scroll down to: iCloud Containers
Look for section that says "iCloud Containers"
```

### 2.2 Add Container
```
Click the: + (plus icon) next to iCloud Containers
```

### 2.3 Select Container
```
A dialog should appear asking "Which container?"
Select: iCloud.com.holsinger.chapterfinder
(This should be the only option for your app)
```

### 2.4 Confirm
```
Click: Add
Wait for: "Container added successfully"
Scroll down to verify: iCloud.com.holsinger.chapterfinder appears in list
```

### 2.5 Save App ID Changes
```
Click: Save (at bottom of page)
Wait for: "Identifier updated successfully"
```

---

## STEP 3: Go to CloudKit Dashboard

### 3.1 Navigate to CloudKit
```
URL: https://icloud.developer.apple.com
Login with your Apple Developer account
```

### 3.2 Select Your Container
```
The page should show your containers
Find: iCloud.com.holsinger.chapterfinder
Click to open it
```

### 3.3 You Should See
```
Dashboard showing:
  • Schema tab
  • Data tab
  • Logs tab
  • etc
```

**If not:** Take a screenshot and share. We'll debug.

---

## STEP 4: Create Record Type 1 - Users

### 4.1 Go to Schema Tab
```
Click: Schema (top navigation)
```

### 4.2 Create New Record Type
```
Click: + Add Record Type (or similar button)
```

### 4.3 Name It
```
Record Type Name: Users
Description: (optional) "User accounts with sign-in info"
Click: Create
```

### 4.4 Add Fields to Users
Add these fields in order:

**Field 1:**
```
Field Name: appleUserID
Field Type: String
Index: YES (this is your primary key)
```

**Field 2:**
```
Field Name: email
Field Type: String
Index: YES
```

**Field 3:**
```
Field Name: firstName
Field Type: String
Index: NO
```

**Field 4:**
```
Field Name: lastName
Field Type: String
Index: NO
```

**Field 5:**
```
Field Name: chapterID
Field Type: String
Index: NO
```

**Field 6:**
```
Field Name: isAdmin
Field Type: Int (for boolean)
Index: NO
```

**Field 7:**
```
Field Name: referralCode
Field Type: String
Index: NO
```

**Field 8:**
```
Field Name: createdAt
Field Type: DateTime
Index: NO
```

**Field 9:**
```
Field Name: lastLoginAt
Field Type: DateTime
Index: NO
```

### 4.5 Set Users Permissions

After all fields are added:
```
Click: Permissions (button in Users record type)
```

Set these permissions:

**Public Permissions:**
```
Query: ALLOW
Fetch: ALLOW
Create: DENY
Update: DENY
Delete: DENY
```

**Private Permissions:**
```
Query: ALLOW (own records only)
Fetch: ALLOW
Create: ALLOW
Update: ALLOW
Delete: ALLOW
```

**Admin Permissions:**
```
Query: ALLOW
Fetch: ALLOW
Create: ALLOW
Update: ALLOW
Delete: ALLOW
```

Then:
```
Click: Save Permissions
Wait for: "Permissions saved"
```

---

## STEP 5: Create Record Type 2 - ChapterTags

### 5.1 Create New Record Type
```
Click: + Add Record Type
Record Type Name: ChapterTags
Description: (optional) "Tags assigned to chapters by admins"
Click: Create
```

### 5.2 Add Fields to ChapterTags

**Field 1:**
```
Field Name: tagID
Field Type: String
Index: YES (primary key)
```

**Field 2:**
```
Field Name: chapterID
Field Type: String
Index: YES
```

**Field 3:**
```
Field Name: tagName
Field Type: String
Index: NO
```

**Field 4:**
```
Field Name: color
Field Type: String
Index: NO
```

**Field 5:**
```
Field Name: createdBy
Field Type: String
Index: NO
```

**Field 6:**
```
Field Name: createdAt
Field Type: DateTime
Index: NO
```

**Field 7:**
```
Field Name: isActive
Field Type: Int (boolean)
Index: NO
```

### 5.3 Set ChapterTags Permissions

```
Click: Permissions
```

**Public Permissions:**
```
Query: ALLOW
Fetch: ALLOW
Create: DENY
Update: DENY
Delete: DENY
```

**Private Permissions:**
```
Query: DENY
Fetch: DENY
Create: DENY
Update: DENY
Delete: DENY
```

**Admin Permissions:**
```
Query: ALLOW
Fetch: ALLOW
Create: ALLOW
Update: ALLOW
Delete: ALLOW
```

```
Click: Save Permissions
```

---

## STEP 6: Create Record Type 3 - Chapters

### 6.1 Create New Record Type
```
Click: + Add Record Type
Record Type Name: Chapters
Description: (optional) "Chapter information and metadata"
Click: Create
```

### 6.2 Add Fields to Chapters

**Field 1:**
```
Field Name: chapterID
Field Type: String
Index: YES (primary key)
```

**Field 2:**
```
Field Name: name
Field Type: String
Index: YES
```

**Field 3:**
```
Field Name: state
Field Type: String
Index: NO
```

**Field 4:**
```
Field Name: city
Field Type: String
Index: NO
```

**Field 5:**
```
Field Name: tagIDs
Field Type: String Array
Index: NO
```

**Field 6:**
```
Field Name: createdAt
Field Type: DateTime
Index: NO
```

**Field 7:**
```
Field Name: updatedAt
Field Type: DateTime
Index: NO
```

### 6.3 Set Chapters Permissions

```
Click: Permissions
```

**Public Permissions:**
```
Query: ALLOW
Fetch: ALLOW
Create: DENY
Update: DENY
Delete: DENY
```

**Private Permissions:**
```
Query: DENY
Fetch: DENY
Create: DENY
Update: DENY
Delete: DENY
```

**Admin Permissions:**
```
Query: ALLOW
Fetch: ALLOW
Create: ALLOW
Update: ALLOW
Delete: ALLOW
```

```
Click: Save Permissions
```

---

## STEP 7: Deploy Schema to Production

### 7.1 Deploy
```
Look for a: Deploy or Publish button
This is usually at the top or bottom of the Schema page
Click: Deploy to Production
```

### 7.2 Confirm
```
A dialog should appear asking: "Are you sure?"
Click: Yes, Deploy
```

### 7.3 Wait for Deployment
```
You should see a status indicator:
"Deployment in progress..."
Wait for: "Schema deployed successfully"
This takes 5-10 minutes usually
```

### 7.4 Verify Deployment
```
Refresh the page
Go back to Schema tab
You should see all 3 record types:
  ✅ Users
  ✅ ChapterTags
  ✅ Chapters
All with status: Deployed
```

**IMPORTANT:** Don't move to Phase 2B until you see "Deployed" for all 3 record types!

---

## STEP 8: Verify Everything Works

### 8.1 Check Users Record Type
```
Click: Users
Verify: All 9 fields appear
Verify: Permissions show your settings
Status should show: Deployed ✅
```

### 8.2 Check ChapterTags Record Type
```
Click: ChapterTags
Verify: All 7 fields appear
Verify: Permissions show your settings
Status should show: Deployed ✅
```

### 8.3 Check Chapters Record Type
```
Click: Chapters
Verify: All 7 fields appear
Verify: Permissions show your settings
Status should show: Deployed ✅
```

### 8.4 Go to Data Tab
```
Click: Data
You should see empty tables for:
  • Users
  • ChapterTags
  • Chapters
```

---

## ✅ Phase 2A Complete When:

- [x] CloudKit enabled on app ID
- [x] iCloud container created
- [x] Users record type created with 9 fields
- [x] ChapterTags record type created with 7 fields
- [x] Chapters record type created with 7 fields
- [x] All permissions configured
- [x] Schema deployed to production
- [x] All 3 record types show "Deployed ✅"
- [x] Data tab accessible and empty

---

## 🔴 Troubleshooting

### Issue: "Bad Container" Error
**Solution:**
1. Verify container ID matches: iCloud.com.holsinger.chapterfinder
2. Check app ID has CloudKit enabled
3. Check container is linked to app ID
4. Refresh page and retry

### Issue: Permission Changes Not Saving
**Solution:**
1. Click Save Permissions button (don't just close)
2. Wait for "Permissions saved" message
3. Verify changes persisted by clicking Permissions again

### Issue: Schema Won't Deploy
**Solution:**
1. Verify all 3 record types created
2. Verify all fields added correctly
3. Check permissions are set for each type
4. Click Deploy to Production button
5. Wait 5-10 minutes
6. Refresh page

### Issue: Can't See CloudKit Dashboard
**Solution:**
1. Verify you're logged in
2. Try clearing browser cache
3. Try incognito/private browsing
4. Use URL: https://icloud.developer.apple.com

---

## 📸 Take Screenshots

When you complete each step, take a screenshot:

1. After enabling CloudKit on app ID
2. After creating container
3. After each record type is created
4. After deployment shows "Deployed ✅"
5. Of Data tab showing 3 empty tables

Share these if anything goes wrong!

---

## ⏱️ Estimated Progress

```
Step 1: Enable CloudKit       ← 5 minutes
Step 2: Create container      ← 5 minutes
Step 3: Go to Dashboard       ← 2 minutes
Step 4: Users record type     ← 15 minutes
Step 5: ChapterTags type      ← 10 minutes
Step 6: Chapters type         ← 10 minutes
Step 7: Deploy schema         ← 10 minutes (wait)
Step 8: Verify everything     ← 10 minutes
                              ———————————
TOTAL:                           ~67 minutes
```

---

## 🎯 When Phase 2A is Complete:

✅ Your CloudKit schema is deployed
✅ Ready for Phase 2B (code changes)
✅ Come back to this chat and I'll guide Phase 2B

---

**Let me know when you're done with Phase 2A!** 

Take your time, follow each step carefully, and share any errors or screenshots if something doesn't work.

🚀 You've got this!
