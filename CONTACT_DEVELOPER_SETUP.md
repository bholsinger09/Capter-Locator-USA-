# Contact Developer Feature - Setup Guide

## Overview

This feature allows users to submit chapter contact updates through the app, which are stored in CloudKit and can be reviewed by admins.

## Features Implemented

### 1. **Contact Developer View** (User-Facing)
- Located in new "Contact" tab in the main TabView
- Dropdown to select state
- Dropdown to select university (filtered by selected state)
- Text fields for contact name and email
- Form validation
- Submit button with loading state
- Success/error alerts

### 2. **Admin Submissions View** (Admin-Only)
- Accessible from Profile tab (Admin Tools section)
- Lists all submitted chapter updates
- Filter by status (Pending, Reviewed, Approved, Rejected)
- Change submission status
- Delete submissions
- Refresh functionality
- Detailed submission information display

### 3. **CloudKit Backend**
- Stores submissions in iCloud
- Public database for accessibility
- Automatic syncing across devices
- Persistent storage

## Setup Instructions

### Step 1: Configure CloudKit in Xcode

1. **Open your project in Xcode**
   
2. **Select your project in the navigator**
   
3. **Select your target** (SwiftChapterUSA_finder)
   
4. **Go to the "Signing & Capabilities" tab**
   
5. **Click "+ Capability"** and add:
   - **iCloud**
   
6. **In the iCloud capability**:
   - Check "CloudKit"
   - Under "Containers", click "+"
   - Create a new container or use existing: `iCloud.com.yourcompany.SwiftChapterUSA`
   - Make sure the container is checked

### Step 2: Configure CloudKit Dashboard

1. **Go to** [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
   
2. **Select your container** (`iCloud.com.yourcompany.SwiftChapterUSA`)
   
3. **Go to Schema** → **Record Types**
   
4. **Create a new Record Type** named: `ChapterUpdateSubmission`
   
5. **Add the following fields**:
   
   | Field Name     | Field Type | Indexed | Sortable |
   |---------------|------------|---------|----------|
   | id            | String     | Yes     | No       |
   | state         | String     | Yes     | Yes      |
   | university    | String     | Yes     | Yes      |
   | contactName   | String     | No      | No       |
   | contactEmail  | String     | No      | No       |
   | submittedBy   | String     | Yes     | No       |
   | submittedAt   | Date/Time  | Yes     | Yes      |
   | status        | String     | Yes     | Yes      |

6. **Deploy to Production**:
   - After creating the schema in Development
   - Go to "Deploy Schema Changes"
   - Deploy to Production environment

### Step 3: Update Admin Emails

1. **Open** `ProfileView.swift`
   
2. **Find the `isAdmin` computed property**:
   ```swift
   private var isAdmin: Bool {
       guard let email = authManager.currentUser?.email else { return false }
       let adminEmails = ["your-admin@email.com", "admin@swiftchapterusa.com"]
       return adminEmails.contains(email)
   }
   ```

3. **Replace the admin emails** with your actual admin email addresses

### Step 4: Update Container Identifier (Optional)

If you want to use a different CloudKit container:

1. **Open** `SubmissionManager.swift`
   
2. **Update the container identifier**:
   ```swift
   container = CKContainer(identifier: "iCloud.com.yourcompany.SwiftChapterUSA")
   ```
   Replace with your actual container identifier

3. **Update** `SwiftChapterUSA_finder.entitlements` to match

### Step 5: Test the Feature

#### Testing User Submissions:

1. **Sign in** with a regular user account
2. **Go to the "Contact" tab**
3. **Select a state** from the dropdown
4. **Select a university** from the filtered list
5. **Enter contact name and email**
6. **Tap "Submit Update"**
7. **Verify the success message appears**

#### Testing Admin Review:

1. **Sign out and sign in** with an admin account (email in the admin list)
2. **Go to Profile tab**
3. **You should see "Admin Tools" section**
4. **Tap "Chapter Update Submissions"**
5. **Verify you can see the submission(s)**
6. **Test changing status**
7. **Test deleting submissions**
8. **Test the filter dropdown**

## How It Works

### User Flow:
1. User opens the "Contact" tab
2. Selects their state and university
3. Enters contact information
4. Submits the form
5. Data is saved to CloudKit
6. User receives confirmation

### Admin Flow:
1. Admin logs in
2. Profile shows "Admin Tools" section
3. Opens "Chapter Update Submissions"
4. Views all submissions with details
5. Can filter by status
6. Can change submission status
7. Can delete submissions
8. Can refresh to get latest data

### Data Flow:
```
User Input → ContactDeveloperView 
    ↓
SubmissionManager.submitUpdate()
    ↓
CloudKit Public Database
    ↓
SubmissionManager.fetchAllSubmissions()
    ↓
AdminSubmissionsView (Admin only)
```

## Files Created/Modified

### New Files:
- `Models/ChapterUpdateSubmission.swift` - Data model
- `Services/SubmissionManager.swift` - CloudKit integration
- `Views/ContactDeveloperView.swift` - User submission form
- `Views/AdminSubmissionsView.swift` - Admin review interface

### Modified Files:
- `Views/MainTabView.swift` - Added Contact tab
- `Views/ProfileView.swift` - Added admin section
- `SwiftChapterUSA_finder.entitlements` - Added CloudKit capabilities

## Troubleshooting

### Issue: "CloudKit access denied"
**Solution**: Make sure you're signed in with an Apple ID in Settings → iCloud on your device/simulator

### Issue: "Record type not found"
**Solution**: Verify you created the CloudKit schema in the CloudKit Dashboard and deployed it

### Issue: "Admin section not showing"
**Solution**: Check that your email is in the `adminEmails` array in `ProfileView.swift`

### Issue: Submissions not appearing
**Solution**: 
- Check CloudKit Dashboard to see if records were created
- Try pulling down to refresh in AdminSubmissionsView
- Verify you're using the correct container identifier

### Issue: Build errors about CloudKit
**Solution**: 
- Clean build folder (Cmd+Shift+K)
- Ensure iCloud capability is properly configured
- Check that entitlements file has CloudKit entries

## Next Steps & Enhancements

### Possible Future Improvements:

1. **Email Notifications**: Send email to admin when new submission arrives
2. **Bulk Actions**: Approve/reject multiple submissions at once
3. **Search & Filter**: Add search by university name or state
4. **Export Data**: Export submissions to CSV
5. **Auto-Apply**: Automatically update chapter data when admin approves
6. **Analytics**: Track submission metrics
7. **Push Notifications**: Notify admins of new submissions
8. **Comments**: Add admin notes to submissions

## Security Notes

- Submissions are stored in CloudKit's **public database** (anyone can read)
- Only authenticated users can submit updates
- Only admins can change status or delete submissions
- Submitter's email is recorded for accountability
- CloudKit handles data encryption and security

## Support

For issues or questions:
1. Check CloudKit Dashboard for backend issues
2. Review Xcode console for error messages
3. Verify all setup steps were completed
4. Ensure proper entitlements are configured

---

**Version**: 3.0  
**Last Updated**: April 21, 2026  
**Feature**: Contact Developer with Chapter Updates
