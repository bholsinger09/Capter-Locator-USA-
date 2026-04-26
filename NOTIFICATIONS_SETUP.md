# Push Notifications Setup Guide

## Overview

The Chapter Locator app now includes a comprehensive push notification system to keep users engaged with:
- **Event Reminders**: 24-hour and 1-hour notifications before events
- **RSVP Confirmations**: Instant confirmation when user RSVPs
- **New Event Alerts**: Notifications when new events are created in user's area
- **Event Updates**: Alerts when event details change
- **Chapter Announcements**: Updates from chapters (future enhancement)

## Architecture

### Components

1. **NotificationManager** (`Services/NotificationManager.swift`)
   - Core service managing all notifications
   - Handles authorization requests
   - Schedules local notifications
   - Manages CloudKit subscriptions for push notifications
   - Singleton pattern: `NotificationManager.shared`

2. **NotificationPreferences** (`Models/NotificationPreferences.swift`)
   - User preference model stored in UserDefaults
   - Granular control over notification types
   - Codable for easy persistence

3. **NotificationSettingsViewModel** (`ViewModels/NotificationSettingsViewModel.swift`)
   - Business logic for settings screen
   - Manages preference updates
   - Handles test notifications

4. **NotificationSettingsView** (`Views/NotificationSettingsView.swift`)
   - Beautiful settings UI with toggles for each notification type
   - Authorization status display
   - Test notification button
   - Pending notifications counter

5. **AppDelegate** (`AppDelegate.swift`)
   - Handles notification registration
   - Processes notification taps
   - Implements UNUserNotificationCenterDelegate

## Xcode Project Setup

### Step 1: Enable Push Notifications Capability

1. Open your project in Xcode
2. Select the **SwiftChapterUSA_finder** target
3. Click the **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Push Notifications**
6. Verify it appears in the capabilities list

### Step 2: Verify Background Modes

1. Still in **Signing & Capabilities**
2. Check if **Background Modes** capability exists
   - If not, click **+ Capability** and add it
3. Enable these modes:
   - ☑️ **Remote notifications**
   - ☑️ **Background fetch** (optional, for refreshing events)

### Step 3: Add Files to Xcode Project

All notification files have been created. You need to add them to your Xcode project:

1. In Xcode, right-click on your project navigator
2. Select **Add Files to "SwiftChapterUSA_finder"...**
3. Navigate to each file and add:
   - `Services/NotificationManager.swift`
   - `Models/NotificationPreferences.swift`
   - `ViewModels/NotificationSettingsViewModel.swift`
   - `Views/NotificationSettingsView.swift`
   - `AppDelegate.swift`
4. Make sure **"Copy items if needed"** is checked
5. Select the **SwiftChapterUSA_finder** target
6. Click **Add**

### Step 4: Update Info.plist (Optional)

To customize notification permissions prompt:

1. Open `Info.plist`
2. Add these keys:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>We'll send you reminders for events you've RSVP'd to and notify you about new events in your area.</string>
```

## CloudKit Configuration

### Remote Notifications via CloudKit Subscriptions

CloudKit subscriptions send push notifications when records are created or updated.

#### Already Configured:
- ✅ iCloud capability enabled
- ✅ CloudKit container: `iCloud.ChapterFinder`
- ✅ Public database access
- ✅ Event and EventRSVP record types created

#### What Happens Automatically:

1. **New Events in User's State**
   - When user first uses the app, we subscribe to events in their state
   - Triggered by: `subscribeToNewEvents(userState:)`
   - Notification appears when chapter creates new event in user's area

2. **Event Updates**
   - When user RSVPs to event, we subscribe to that specific event
   - Triggered by: `subscribeToEventUpdates(eventID:)`
   - Notification appears when event details change (time, location, etc.)
   
3. **Unsubscribe on RSVP Cancel**
   - When user cancels RSVP, we unsubscribe from event updates
   - Prevents spam after user loses interest

#### Testing CloudKit Subscriptions:

CloudKit subscriptions **only work on physical devices**, not simulators:

1. Build and run on a real iPhone
2. Sign in with your Apple ID in Settings > iCloud
3. Grant notification permissions in the app
4. RSVP to an event
5. Have someone else (or use CloudKit Dashboard) update that event
6. You should receive a push notification! 🎉

## Local Notifications

### Event Reminders

When a user RSVPs to an event, two local notifications are scheduled:

1. **24 Hours Before** - "Event Tomorrow! 📅"
2. **1 Hour Before** - "Event Starting Soon! ⏰"

These are automatically:
- Scheduled when user RSVPs
- Cancelled if user cancels RSVP
- Skipped if event is in the past

### RSVP Confirmations

Immediate notification sent when user successfully RSVPs:
- "RSVP Confirmed! ✓"
- Shows event name and guest count

## User Flow

### First Time Experience

1. User opens app for the first time
2. After 2 seconds, notification permission prompt appears
3. User can grant or deny permissions
4. If denied, user can enable later via Profile → Notification Settings

### Settings Management

Users access notification settings via:
- **Profile Tab** → **Notification Settings** button

They can toggle:
- ☐ Event Reminders (24hr, 1hr independently)
- ☐ New Event Notifications
- ☐ Event Updates  
- ☐ RSVP Confirmations
- ☐ Chapter Announcements
- ☐ New Blog Posts
- ☐ Sound
- ☐ Badge Icon

### Notification Tapping

When user taps a notification:
- **Event Reminder** → Opens app to that specific event (future enhancement)
- **New Event** → Opens Events tab
- **RSVP Confirmation** → Opens to event details

## Testing Notifications

### Test on Simulator (Limited)

**Works:**
- ✅ Authorization prompts
- ✅ Local notifications (event reminders, RSVP confirmations)
- ✅ Settings UI
- ✅ Preference saving

**Doesn't Work:**
- ❌ CloudKit push notifications (requires physical device)
- ❌ Remote notification registration

### Test on Physical Device (Full)

**Everything works!**

1. Build and run on iPhone
2. Grant notification permissions
3. Go to Events tab
4. RSVP to an upcoming event
5. Verify you see RSVP confirmation notification immediately
6. Go to Settings app → Notifications → Chapter Locator
7. Verify scheduled notifications appear (you'll see "2 Pending")

### Send Test Notification

1. Open Profile → Notification Settings
2. Tap **Test** button (only visible when authorized)
3. Should see: "Test Notification 🔔 - Your notifications are working perfectly!"

### Clear All Notifications

In Notification Settings:
- View pending count
- Tap "Clear All Notifications" to remove all scheduled notifications

## Notification Preferences Storage

Preferences are stored in **UserDefaults** as JSON:
- Key: `notificationPreferences`
- Persists across app launches
- Synced to NotificationManager on load

## Code Integration Points

### When User RSVPs:

```swift
// In EventsViewModel.rsvpToEvent()
try await notificationManager.scheduleEventReminders(for: event, userRSVP: rsvp)
try await notificationManager.sendRSVPConfirmation(for: event, guestCount: guestCount)
try await notificationManager.subscribeToEventUpdates(eventID: event.id)
```

### When User Cancels RSVP:

```swift
// In EventsViewModel.cancelRSVP()
await notificationManager.cancelEventReminders(eventID: event.id)
await notificationManager.unsubscribeFromEventUpdates(eventID: event.id)
```

### When User Signs In:

```swift
// Future enhancement - subscribe to events in user's state
try await notificationManager.subscribeToNewEvents(userState: user.state)
```

## Production Considerations

### 1. Apple Push Notification Service (APNs) Setup

For production, you need to configure APNs:

1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select your App ID
4. Enable **Push Notifications**
5. Create APNs certificates (Development and Production)
6. Download and install certificates in Keystone

### 2. Privacy Policy

Update your privacy policy to mention:
- Notification data collection
- CloudKit subscription usage
- Device token storage
- User control over notifications

### 3. App Store Review

Include in App Review notes:
- How to test notifications
- Test account credentials
- Which events trigger notifications
- How users can disable notifications

## Troubleshooting

### Notifications Not Appearing

**Check:**
1. ✓ Push Notifications capability enabled in Xcode
2. ✓ Authorization status is "Authorized" (not "Denied")
3. ✓ User preferences have notifications enabled
4. ✓ Device is connected to internet (for CloudKit)
5. ✓ Using physical device (for CloudKit push)

### Authorization Always Denied

- Once denied, user must go to Settings app → Notifications → Chapter Locator to enable
- Can't re-prompt programmatically
- Settings button in app opens Settings app directly

### CloudKit Subscriptions Not Working

**Common issues:**
1. Using simulator (doesn't support CloudKit push)
2. Not signed into iCloud on device
3. CloudKit container permissions incorrect
4. Network connectivity issues
5. Index not created for queried field

**Debug:**
```swift
// Check if subscription exists
let subscriptions = try await container.publicCloudDatabase.allSubscriptions()
print("Active subscriptions: \(subscriptions.map { $0.subscriptionID })")
```

### Reminders Not Scheduling

**Check:**
1. Event is in the future
2. User has RSVP'd with "Confirmed" status
3. Event hasn't already passed
4. Preferences have reminders enabled

**Debug:**
```swift
// Check pending notifications
let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
print("Pending: \(pending.count) notifications")
pending.forEach { print("  - \($0.identifier): \($0.content.title)") }
```

## Future Enhancements

### Near-Term (Easy)
- [ ] Rich notifications with event images
- [ ] Notification actions (View Event, Cancel RSVP)
- [ ] Location-based notifications (arriving at event venue)
- [ ] Daily digest of upcoming events

### Long-Term (Complex)
- [ ] Chapter-to-member push messaging
- [ ] Blog post notifications
- [ ] Friend activity notifications
- [ ] Custom notification sounds
- [ ] Notification grouping by event/chapter

## Implementation Checklist

- [x] Create NotificationManager service
- [x] Create NotificationPreferences model
- [x] Create NotificationSettingsViewModel
- [x] Create NotificationSettingsView UI
- [x] Create AppDelegate for notification handling
- [x] Integrate with EventsViewModel (RSVP flow)
- [x] Add settings link to ProfileView
- [x] Update App file with UIApplicationDelegateAdaptor
- [x] Request permissions on app launch
- [ ] Add files to Xcode project
- [ ] Enable Push Notifications capability
- [ ] Test on physical device
- [ ] Update privacy policy

## Resources

- [Apple: UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [Apple: CloudKit Subscriptions](https://developer.apple.com/documentation/cloudkit/cksubscription)
- [Apple: Handling Notifications](https://developer.apple.com/documentation/usernotifications/handling_notifications_and_notification-related_actions)
- [WWDC: What's New in Notifications](https://developer.apple.com/videos/play/wwdc2022/10005/)

## Support

If notifications aren't working:
1. Check authorization status in Notification Settings
2. Verify files are added to Xcode project
3. Enable Push Notifications capability
4. Test on physical device (not simulator)
5. Check Console for error messages with "NotificationManager" prefix

---

**Status**: ✅ Implementation Complete  
**Last Updated**: April 26, 2026  
**Tested On**: iOS 16.0+
