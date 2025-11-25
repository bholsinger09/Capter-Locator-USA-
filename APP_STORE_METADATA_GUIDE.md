# App Store Connect Metadata Update Guide
## Addressing Guideline 5.2.5 - Apple Trademark Issue

---

## 🎯 What Apple Wants

Apple's review flagged: **"Terms for Finder in the app name in an inappropriate manner"**

You need to update ALL metadata in App Store Connect to remove "Finder" references.

---

## 📝 Step-by-Step: Update App Store Connect

### 1. Log into App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Click on **"My Apps"**
3. Select your app (currently named "Chapter Finder" or similar)

---

### 2. Update App Information

#### Navigate: App Information Section
Click **"App Information"** in the left sidebar

#### Update These Fields:

**Name** (Primary Display Name)
- ❌ OLD: "Chapter Finder" or "SwiftChapter USA Finder"
- ✅ NEW: **"Chapter Locator USA"**

**Subtitle** (if applicable)
- ❌ Remove: Any text containing "finder"
- ✅ NEW: "Find TPUSA Chapters Near You" or "Connect with TPUSA Chapters"

**Privacy Policy URL** (if you have one)
- Update to reference "Chapter Locator USA" instead of "Finder"

---

### 3. Update Version Information

#### Navigate: Version 2.0 (or current version)
Click the version you're submitting in the left sidebar

#### Update These Fields:

**What's New in This Version**
```
Version 2.0 Updates:

• App renamed to "Chapter Locator USA" for clarity
• Improved authentication with demo account support
• Enhanced user experience across all features
• Bug fixes and performance improvements

Note: This app is an independent tool and is not affiliated with Turning Point USA. For official TPUSA resources, visit www.tpusa.com.
```

---

### 4. Update App Description

**IMPORTANT:** Remove ALL instances of "Finder" from your description.

#### Recommended Description:

```
CHAPTER LOCATOR USA

Discover and connect with Turning Point USA (TPUSA) chapters across the United States.

IMPORTANT DISCLAIMER:
This is NOT the official Turning Point USA application. This is an independent tool created to help people find local TPUSA chapters. For official TPUSA resources, visit www.tpusa.com.

FEATURES:

🏛️ CHAPTER BROWSER
• Browse 50+ chapters across multiple states
• Search by location, university, or chapter name
• View detailed chapter information and meeting schedules
• See member counts and leadership contacts

🎓 UNIVERSITY DIRECTORY
• Comprehensive list of universities across the US
• Filter by state and chapter availability
• View which universities have active chapters
• Access student population and website information

👥 MEMBER COMMUNITY
• View your membership status
• Connect with your local chapter
• Find nearby chapters in your state
• Access member resources and links

💬 COMMUNITY ENGAGEMENT
• Create and share posts with other members
• Reply to discussions
• Filter content by your chapter or state
• Engage with like-minded individuals

🔐 SECURE & PRIVATE
• User registration and authentication
• Profile management
• Local data storage
• No personal information shared with third parties

Whether you're a student looking to get involved or simply interested in connecting with like-minded individuals in your community, Chapter Locator USA makes it easy to discover and join your local chapter.

ABOUT TURNING POINT USA:
Turning Point USA is a national organization dedicated to educating students about the principles of free markets and limited government. Visit www.tpusa.com for official information.

SUPPORT:
For app-related questions, contact: support@chapterlocatorusa.com
For TPUSA inquiries, visit: www.tpusa.com/contact
```

---

### 5. Update Keywords

#### Current Keywords (REMOVE these):
- finder
- find chapter
- chapter finder
- tpusa finder
- swiftchapter finder

#### Recommended Keywords (USE these):
```
locator, chapters, tpusa, turning point, university, college, conservative, community, political, networking, student organization, activism, chapter locator, nearby chapters, local chapters, discover chapters
```

**Note:** Maximum 100 characters, comma-separated, no spaces after commas.

---

### 6. Update Promotional Text (Optional)

```
Now available as Chapter Locator USA! Discover and connect with Turning Point USA chapters in all 50 states. Browse 50+ chapters, connect with members, and engage with your local community.
```

---

### 7. Update Screenshots (If Needed)

If your current screenshots show "SwiftChapter USA Finder" or "Chapter Finder":

1. **Take new screenshots** from the simulator or device showing "Chapter Locator USA"
2. **Required screenshots:**
   - Login screen (shows new name)
   - Chapters list view
   - Chapter detail view
   - Universities view
   - Profile/settings view

**Screenshot Sizes Needed:**
- 6.7" Display (iPhone 14 Pro Max, iPhone 15 Pro Max): 1290 x 2796 px
- 6.5" Display (iPhone 11 Pro Max, iPhone XS Max): 1242 x 2688 px
- 5.5" Display (iPhone 8 Plus): 1242 x 2208 px

---

### 8. Update App Review Information

#### Demo Account (CRITICAL - This was Issue #1)

**Sign-in required**
- ✅ Yes (Your app requires sign-in)

**Username:**
```
demo@appstore.com
```

**Password:**
```
AppReview2025
```

#### Notes for Review:
```
IMPORTANT REVIEW NOTES:

1. DEMO ACCOUNT: The demo account (demo@appstore.com / AppReview2025) is now fully functional and does not require prior registration. It provides immediate access to all app features.

2. APP NAME CHANGE: We have renamed the app from "Chapter Finder" to "Chapter Locator USA" to comply with Apple's trademark guidelines and avoid confusion with Apple's Finder application.

3. DISCLAIMER: This is an independent tool and is NOT affiliated with Turning Point USA. The app includes prominent disclaimers throughout.

4. FEATURES: The demo account has access to:
   - Browse 50+ TPUSA chapters across multiple states
   - Search and filter chapters by location
   - View university listings with chapter information
   - Access member resources and community features
   - Create posts and engage with content

5. DATA STORAGE: All user data is stored locally on the device. No backend server is required.

Thank you for your review!
```

---

### 9. Update Privacy Information

If you haven't already, ensure your Privacy Policy is updated:

**Data Types Collected:**
- Contact Info: Email address (for account creation)
- User Content: Posts, profile information

**Purpose:**
- App Functionality

**Tracking:**
- No tracking across apps or websites

---

### 10. Version & Build Number

**Version Number:**
```
2.0
```

**Build Number:**
```
2
```

(These should match your Info.plist)

---

## ✅ Pre-Submission Checklist

Before clicking "Submit for Review":

- [ ] App name changed to "Chapter Locator USA"
- [ ] Subtitle contains no "Finder" references
- [ ] Description updated (no "Finder" references)
- [ ] Keywords updated (removed "finder")
- [ ] What's New text updated
- [ ] Screenshots show correct app name (if applicable)
- [ ] Demo account credentials verified: demo@appstore.com / AppReview2025
- [ ] Review notes explain both fixes clearly
- [ ] Privacy information up to date
- [ ] Version 2.0, Build 2
- [ ] New build uploaded to App Store Connect

---

## 🚀 Submit for Review

Once all metadata is updated:

1. Click **"Add for Review"** (if not already added)
2. Click **"Submit for Review"**
3. Respond to the review team message (if there's a thread)

### Response to Review Team:

```
Dear App Review Team,

Thank you for your feedback on submission a013b326-d921-4c38-a0b1-af12523f5d8f.

We have addressed both issues:

1. DEMO ACCOUNT (Guideline 2.1):
   The credentials demo@appstore.com / AppReview2025 now work without requiring registration. The account provides full access to all features.

2. TRADEMARK (Guideline 5.2.5):
   We have removed the term "Finder" from our app name and all metadata. The app is now named "Chapter Locator USA" to avoid confusion with Apple products. We have updated:
   - App display name
   - All user-facing text
   - App Store metadata and descriptions
   - Keywords and promotional text

We have reviewed Apple's trademark guidelines and ensured full compliance.

Thank you for your patience.

Best regards
```

---

## 📱 Expected Timeline

- **Upload Build**: 5-15 minutes
- **Processing**: 10-60 minutes
- **Waiting for Review**: 1-2 days
- **In Review**: 12-48 hours
- **Total**: 2-4 days typically

---

## ⚠️ Common Mistakes to Avoid

1. ❌ Forgetting to update keywords (they still contain "finder")
2. ❌ Screenshots still show old "Chapter Finder" name
3. ❌ Subtitle or promotional text mentions "finder"
4. ❌ Not uploading a NEW build with version 2.0
5. ❌ Demo account credentials incorrect or not tested
6. ❌ Not responding to the review thread with explanation

---

## 📞 If You Need Help

**App Store Connect Help:**
- https://developer.apple.com/support/app-store-connect/

**Trademark Guidelines:**
- https://www.apple.com/legal/intellectual-property/guidelinesfor3rdparties.html

**App Review Process:**
- https://developer.apple.com/app-store/review/

---

**Status:** Ready for metadata update and resubmission
**Date:** November 24, 2025
