# App Store Deployment Guide
## Chapter Locator USA

### Current App Configuration
- **App Name**: Chapter Locator USA
- **Bundle Identifier**: com.Ben.SwiftChapterUSA-finder
- **Version**: 1.0
- **Build**: 1
- **Platform**: iOS 18.5+

---

## Pre-Deployment Checklist

### 1. App Store Connect Setup
Before submitting, ensure you have:
- [ ] Active Apple Developer Program membership ($99/year)
- [ ] App created in App Store Connect (https://appstoreconnect.apple.com)
- [ ] Bundle ID registered in your Apple Developer account
- [ ] App Store listing prepared (description, screenshots, keywords)

### 2. Required Assets

#### App Icons
Your app needs icons in these sizes:
- **iPhone**: 60x60 (@2x and @3x)
- **App Store**: 1024x1024 (single image)
- **Settings**: 29x29, 40x40, 58x58, 80x80, 87x87

Current Status: ✅ Assets folder exists at `SwiftChapterUSA_finder/SwiftChapterUSA_finder/Assets.xcassets/AppIcon.appiconset/`

#### Screenshots Required
For App Store listing (must provide for at least one device size):
- iPhone 6.7" Display (1290 x 2796 pixels) - iPhone 16 Pro Max
- iPhone 6.5" Display (1284 x 2778 pixels)
- iPhone 5.5" Display (1242 x 2208 pixels)

Minimum: 3-10 screenshots per device size

### 3. App Store Information Needed

#### Required Metadata
```
App Name: Chapter Locator USA
Subtitle: Find TPUSA Chapters Near You
Category: Social Networking or Education
Age Rating: 4+ (or appropriate rating)
Privacy Policy URL: [Required - must provide]
Support URL: [Required - must provide]
```

#### Description Template
```
Chapter Locator USA helps you discover and connect with Turning Point USA (TPUSA) chapters across the United States. 

FEATURES:
• Browse chapters by state and university
• View chapter details and meeting information
• Join your local chapter
• Connect with other members
• Stay updated with chapter blogs and activities
• Find universities with active TPUSA presence

Whether you're a student looking to get involved or simply interested in connecting with like-minded individuals, Chapter Locator USA makes it easy to find and join your local chapter.

DISCLAIMER: This is an unofficial community tool. For official TPUSA information, visit tpusa.com.
```

#### Keywords (max 100 characters)
```
tpusa,conservative,chapter,university,college,political,student,activism,freedom,liberty
```

---

## Deployment Steps

### Step 1: Open Xcode Project
```bash
cd /Users/benh/Documents/SwiftChapterUSA_finder
open SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj
```

### Step 2: Configure Signing & Capabilities

1. Select your project in the navigator
2. Select the target "SwiftChapterUSA_finder"
3. Go to "Signing & Capabilities" tab
4. **Automatic Signing**:
   - Enable "Automatically manage signing"
   - Select your Team (your Apple Developer account)
   - Xcode will automatically create and manage provisioning profiles

5. **Bundle Identifier**: 
   - Verify it shows: `com.Ben.SwiftChapterUSA-finder`
   - ⚠️ Note: You may want to change "com.Ben" to your actual developer name or company

### Step 3: Select Device and Scheme

1. In Xcode toolbar, select **"Any iOS Device (arm64)"** as the destination
2. Ensure scheme is set to **"SwiftChapterUSA_finder"**
3. Ensure build configuration is **"Release"** (Product > Scheme > Edit Scheme > Run > Build Configuration)

### Step 4: Archive the App

1. **Product** → **Archive**
2. Wait for the build to complete (may take several minutes)
3. If successful, the Organizer window will open showing your archive

### Step 5: Validate the Archive

In the Organizer:
1. Select your archive
2. Click **"Validate App"**
3. Choose your distribution method: **"App Store Connect"**
4. Select your team
5. Choose automatic signing
6. Click **"Validate"**
7. Wait for validation to complete
8. Fix any errors or warnings that appear

### Step 6: Upload to App Store Connect

1. Click **"Distribute App"**
2. Select **"App Store Connect"**
3. Select **"Upload"**
4. Choose automatic signing
5. Review the app information
6. Click **"Upload"**
7. Wait for upload to complete (may take 10-30 minutes)

### Step 7: Submit for Review in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Select **"My Apps"**
3. Click on your app
4. Fill in required information:
   - App Information
   - Pricing and Availability
   - App Privacy
   - App Review Information (demo account if needed)
   - Version Information
   - Screenshots
   - Description
5. Click **"Add for Review"** or **"Submit for Review"**

---

## Common Issues & Solutions

### Issue: "No signing identity found"
**Solution**: 
- Ensure you're logged into your Apple Developer account in Xcode
- Xcode → Settings → Accounts → Add your Apple ID
- Download certificates if needed

### Issue: "Bundle identifier is already in use"
**Solution**: 
- Change the bundle identifier in Xcode to something unique
- Recommend: `com.YourName.ChapterFinder` or `com.YourCompany.ChapterFinder`

### Issue: "Missing required icon"
**Solution**:
- Add all required icon sizes to Assets.xcassets/AppIcon.appiconset/
- Use an icon generator tool or design app

### Issue: "Invalid binary - Missing required architecture"
**Solution**:
- Ensure "Any iOS Device (arm64)" is selected as deployment target
- Clean build folder: Product → Clean Build Folder
- Rebuild archive

### Issue: "Missing Privacy Policy URL"
**Solution**:
- Create a simple privacy policy webpage
- Add URL to App Store Connect
- Can use free hosting: GitHub Pages, Netlify, etc.

---

## Privacy Policy Template

You'll need a privacy policy URL. Here's a basic template:

```markdown
# Privacy Policy for Chapter Locator USA

Last updated: November 16, 2025

## Information We Collect
Chapter Locator USA stores the following information locally on your device:
- Your name and email address
- Your selected state and university
- Your chapter membership selection

## How We Use Information
- All data is stored locally on your device
- No information is transmitted to external servers
- Chapter information is hardcoded sample data for demonstration

## Data Sharing
We do not share, sell, or transmit your personal information to any third parties.

## Contact
For questions about this privacy policy, contact: [your-email@example.com]
```

---

## Post-Submission

### Review Timeline
- Initial review: 24-48 hours
- Full review process: 1-3 days typically
- Status updates available in App Store Connect

### Possible Review Outcomes
1. **Approved**: App will be available on App Store
2. **Rejected**: Review feedback will explain issues
3. **Pending Developer Release**: You control when to release

### After Approval
- App appears on App Store within 24 hours
- Monitor reviews and ratings
- Plan updates based on user feedback

---

## Quick Command Reference

```bash
# Navigate to project
cd /Users/benh/Documents/SwiftChapterUSA_finder

# Open in Xcode
open SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj

# Commit current changes
git add -A
git commit -m "Prepare for App Store submission v1.0"
git push origin main

# Tag release version
git tag -a v1.0 -m "App Store Release 1.0"
git push origin v1.0
```

---

## Next Steps

1. ✅ Ensure you have an Apple Developer account
2. ✅ Create app in App Store Connect
3. ✅ Prepare app icons (1024x1024 required)
4. ✅ Take screenshots on iPhone simulator
5. ✅ Write/host privacy policy
6. ✅ Follow deployment steps above
7. ✅ Submit for review

**Estimated Time**: 2-4 hours for first submission

Good luck with your App Store submission! 🚀
