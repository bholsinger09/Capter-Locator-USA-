# App Store Resubmission Checklist
## Version 2.0 - Build 2

---

## ✅ Code Changes Complete

### Issue 1: Demo Account Access (Guideline 2.1)
- ✅ Added hardcoded demo account support in AuthenticationManager
- ✅ Credentials: demo@appstore.com / AppReview2025
- ✅ Tested and verified working in simulator
- ✅ Demo user profile: Demo Reviewer, California, Stanford University

### Issue 2: Apple Trademark Violation (Guideline 5.2.5)
- ✅ Changed app display name from "Chapter Finder" to "Chapter Locator USA"
- ✅ Updated Info.plist CFBundleDisplayName
- ✅ Updated AuthenticationView title
- ✅ Updated ProfileView app name display
- ✅ Updated all documentation (README, deployment guide, privacy policy)
- ✅ Tested and verified in simulator

---

## 📋 App Store Connect Checklist

### Before You Submit:

#### 1. App Information
- [ ] **App Name**: Change to "Chapter Locator USA"
- [ ] **Subtitle**: Ensure no "Finder" references (e.g., "Find TPUSA Chapters Near You")
- [ ] **Keywords**: Remove "finder" if present, add "locator, chapters, TPUSA"

#### 2. App Description
Update to remove all "Finder" references:

```
Chapter Locator USA helps you discover and connect with Turning Point USA (TPUSA) chapters across the United States.

Features:
• Browse 50+ chapters across multiple states
• Search by location, university, or chapter name
• View detailed chapter information and meeting schedules
• Connect with local members and leaders
• Access university chapter listings
• Share updates and engage with the community

Important: This is NOT the official Turning Point USA application. This is an independent tool created to help people find local TPUSA chapters and connect with other members. For official TPUSA resources, visit www.tpusa.com.

Whether you're a student looking to get involved or simply interested in connecting with like-minded individuals, Chapter Locator USA makes it easy to find and join your local chapter.
```

#### 3. Version & Build
- [ ] **Version**: 2.0 (or keep current if already 2.0)
- [ ] **Build Number**: Increment to next number (e.g., if was 1, change to 2)

#### 4. Screenshots
- [ ] Review all screenshots - they should show "Chapter Locator USA" in the login screen
- [ ] If old screenshots show "SwiftChapter USA Finder", take new ones
- [ ] Recommended: Take fresh screenshots from the simulator showing the updated name

#### 5. App Review Information
- [ ] **Demo Account Username**: demo@appstore.com
- [ ] **Demo Account Password**: AppReview2025
- [ ] **Notes**: "Demo account credentials have been updated and verified. The account provides immediate access without requiring registration. App name has been changed to remove 'Finder' trademark issue."

#### 6. Promotional Text (Optional)
```
Now available as "Chapter Locator USA" - discover and connect with Turning Point USA chapters across all 50 states!
```

---

## 🔨 Build Instructions

### Option 1: Archive via Xcode GUI
```bash
cd /Users/benh/Documents/SwiftChapterUSA_finder
open SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj
```

1. In Xcode, select **Product > Archive**
2. Ensure scheme is set to **SwiftChapterUSA_finder**
3. Ensure device is set to **Any iOS Device (arm64)**
4. Wait for archive to complete
5. In Organizer, click **Distribute App**
6. Select **App Store Connect**
7. Upload to App Store Connect

### Option 2: Command Line Build (Advanced)
```bash
cd /Users/benh/Documents/SwiftChapterUSA_finder

# Clean build
xcodebuild clean -project SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj \
  -scheme SwiftChapterUSA_finder

# Archive
xcodebuild archive \
  -project SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj \
  -scheme SwiftChapterUSA_finder \
  -archivePath build/ChapterLocatorUSA.xcarchive \
  -configuration Release \
  CODE_SIGN_IDENTITY="Apple Distribution" \
  DEVELOPMENT_TEAM="PL58734CZ4"

# Upload (requires export options plist)
xcodebuild -exportArchive \
  -archivePath build/ChapterLocatorUSA.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist exportOptions.plist
```

---

## 📝 Response to Apple Review Team

**Subject: Re: Submission a013b326-d921-4c38-a0b1-af12523f5d8f**

Dear App Review Team,

Thank you for your feedback. We have addressed both issues:

**Regarding Guideline 2.1 - Demo Account:**
The demo account credentials are now fully functional. Please use:
- Username: demo@appstore.com
- Password: AppReview2025

The account will authenticate immediately without requiring prior registration and provides full access to all app features.

**Regarding Guideline 5.2.5 - Trademark:**
We have removed the term "Finder" from our app name and all metadata. The app is now named "Chapter Locator USA" to avoid any confusion with Apple products. We have updated:
- App display name (CFBundleDisplayName)
- All user-facing text in the app
- App Store metadata and descriptions
- Marketing materials and documentation

We have reviewed Apple's Guidelines for Using Apple's Trademarks and Copyrights and ensured full compliance.

Thank you for your patience. We look forward to your review.

Best regards

---

## ✅ Final Verification

Before submitting, verify in the simulator:

1. **Login Screen**
   - [ ] Shows "Chapter Locator USA" (not "SwiftChapter USA Finder")
   - [ ] Demo login works: demo@appstore.com / AppReview2025
   - [ ] No "Invalid credentials" error

2. **Profile Screen**
   - [ ] Shows "Chapter Locator USA" at bottom
   - [ ] Shows correct version number

3. **All Features Accessible**
   - [ ] Chapters tab works
   - [ ] Universities tab works
   - [ ] Members tab works
   - [ ] Blog tab works
   - [ ] Profile tab works

4. **No Trademark Issues**
   - [ ] No visible "Finder" text in UI
   - [ ] App name consistently shows as "Chapter Locator USA"

---

## 🚀 Ready to Submit

Once all checkboxes above are complete:
1. Upload new build to App Store Connect
2. Update app metadata with new name and description
3. Verify demo credentials are entered correctly
4. Submit for review
5. Respond to review team with message above

**Estimated Timeline**: 1-3 business days for review

---

**Build Status**: ✅ READY FOR SUBMISSION
**Date**: November 24, 2025
**Issues Resolved**: 2/2
