# Demo Account Test Instructions

## Test Build Information
- **App Name**: Chapter Locator USA
- **Build Date**: November 24, 2025
- **iOS Deployment Target**: 16.0+
- **Bundle ID**: com.holsinger.chapterfinder

## Demo Credentials
- **Email**: demo@appstore.com
- **Password**: AppReview2025

## Testing Steps

### 1. Launch the App
The app should open to the authentication screen.

### 2. Test Demo Login
1. Enter the demo credentials:
   - Email: `demo@appstore.com`
   - Password: `AppReview2025`
2. Tap the "Login" button
3. The app should authenticate immediately without requiring registration

### 3. Verify Demo User Profile
After login, the demo account has these details:
- **Name**: Demo Reviewer
- **State**: California
- **University**: Stanford University

### 4. Test All Features
Verify full access to:
- ✅ **Chapters Tab**: Browse 50+ pre-loaded chapters across multiple states
- ✅ **Universities Tab**: View university listings with chapter availability
- ✅ **Members Tab**: See membership status and chapter information
- ✅ **Blog Tab**: View and create posts
- ✅ **Profile Tab**: View and edit profile information

### 5. Test Search and Filters
- Search for chapters by name, city, or state
- Filter chapters by state
- Filter universities by state and chapter availability
- Filter blog posts by "All", "Your Chapter", or "Your State"

### 6. Test Navigation
- Navigate between all tabs
- View chapter details
- View university details
- Create a new chapter (if applicable)
- Create a blog post

## Expected Results

✅ **Demo login should work immediately** without any "Invalid credentials" or "Please register first" errors

✅ **All features should be accessible** - no locked or restricted sections

✅ **Demo user profile** should display correctly in the Profile tab

✅ **App name** should display as "Chapter Locator USA" (not "Chapter Finder")

## Known Issues
None - Both review issues have been resolved:
1. ✅ Demo account credentials now work
2. ✅ App name changed to avoid Apple trademark violation

## Build Commands (for resubmission)

```bash
# Navigate to project
cd /Users/benh/Documents/SwiftChapterUSA_finder

# Open in Xcode
open SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj

# Or build from command line
xcodebuild -project SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj \
  -scheme SwiftChapterUSA_finder \
  -configuration Release \
  clean archive \
  -archivePath build/ChapterLocatorUSA.xcarchive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath build/ChapterLocatorUSA.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist exportOptions.plist
```

## App Store Connect Updates Required

1. **Change App Name**: Update to "Chapter Locator USA"
2. **Update Description**: Remove any references to "Finder"
3. **Update Screenshots**: Verify they show "Chapter Locator USA"
4. **Increment Build Number**: Change from 1 to 2
5. **Demo Account**: Confirm credentials in App Review Information section

## Test Results

- [ ] Demo login successful
- [ ] All tabs accessible
- [ ] Profile displays correctly
- [ ] Search and filters work
- [ ] Chapter browsing works
- [ ] University browsing works
- [ ] Blog/chat features work
- [ ] App displays as "Chapter Locator USA"

---

**Test Status**: Ready for App Store resubmission
**Date Tested**: November 24, 2025
