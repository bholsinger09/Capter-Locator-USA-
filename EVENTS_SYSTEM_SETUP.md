# Events & Calendar System - Setup Guide

## Overview

The Events & Calendar System allows chapter members to create, discover, and RSVP to TPUSA events. This feature includes event creation, RSVP management, calendar integration, and real-time updates through CloudKit.

## 🎯 Key Features

### User Features:
- **Browse Events**: View all upcoming TPUSA events with filtering by state, type, and date
- **RSVP System**: Reserve spots at events with guest count and capacity management
- **My Events**: Track all events you've RSVP'd to
- **Event Discovery**: Search events by keyword, location, or tags
- **Calendar Views**: List and calendar display modes
- **Event Details**: Rich event pages with maps, organizer info, and attendance stats
- **Share Events**: Share event details with friends
- **Real-time Updates**: Live RSVP counts and capacity tracking

### Chapter Admin Features:
- **Create Events**: Easy event creation with rich details
- **Manage Events**: Edit or delete events you created
- **Track RSVPs**: See who's attending your events
- **Flexible Settings**: Virtual/in-person, capacity limits, RSVP requirements
- **Event Types**: Meetings, Networking, Speakers, Workshops, Socials, Fundraisers, Protests, Volunteer, Conferences

## 📋 Setup Instructions

### Step 1: Configure CloudKit Schema

You need to create **TWO** CloudKit record types: `Event` and `EventRSVP`

#### 1.1 Go to CloudKit Dashboard

1. Visit [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
2. Sign in with your Apple Developer account
3. Select your container: `iCloud.ChapterFinder`
4. Navigate to **Schema** → **Record Types**

#### 1.2 Create Event Record Type

Click **"+"** to create a new record type named `Event`

Add the following fields:

| Field Name | Field Type | Add Index? | Index Type | Notes |
|------------|------------|------------|------------|-------|
| id | String | ✓ Yes | QUERYABLE | UUID for event |
| title | String | ✓ Yes | QUERYABLE + SORTABLE | Event title - needs sorting |
| description | String | No | - | Event details |
| eventDate | Date/Time | ✓ Yes | QUERYABLE + SORTABLE | Start date/time - needs sorting |
| endDate | Date/Time | No | - | Optional end time |
| location | String | ✓ Yes | QUERYABLE | Location name |
| address | String | No | - | Full address |
| latitude | Double | No | - | Map coordinates (optional, not queried) |
| longitude | Double | No | - | Map coordinates (optional, not queried) |
| chapterID | String | ✓ Yes | QUERYABLE | Associated chapter UUID |
| chapterName | String | ✓ Yes | QUERYABLE + SORTABLE | Chapter name |
| state | String | ✓ Yes | QUERYABLE + SORTABLE | State for filtering |
| university | String | ✓ Yes | QUERYABLE | University name |
| organizerName | String | No | - | Event organizer |
| organizerEmail | String | ✓ Yes | QUERYABLE | Contact email |
| imageURL | String | No | - | Event image (future) |
| capacity | Int(64) | No | - | Max attendees |
| rsvpCount | Int(64) | No | - | Current RSVPs |
| eventType | String | ✓ Yes | QUERYABLE | Event category |
| isVirtual | Int(64) | ✓ Yes | QUERYABLE | 1 = virtual, 0 = in-person |
| virtualMeetingURL | String | No | - | Zoom/Teams link |
| requiresRSVP | Int(64) | No | - | 1 = yes, 0 = no |
| createdAt | Date/Time | ✓ Yes | QUERYABLE + SORTABLE | Creation timestamp |
| createdBy | String | ✓ Yes | QUERYABLE | Creator email |
| isActive | Int(64) | ✓ Yes | QUERYABLE | 1 = active, 0 = deleted |
| tags | String | No | - | Comma-separated tags |

**How to Add Indexes**:
1. After creating all fields, go to the **Indexes** section
2. For each field marked "Add Index? ✓ Yes" above:
   - Click **"Add Index"**
   - Select **Record Type**: Event
   - Enter **Name**: fieldName (e.g., "title")
   - Select **Type**: As specified in "Index Type" column
   - Select **Field**: The field to index
   - Click **"Add"**
3. If a field needs multiple index types (e.g., "QUERYABLE + SORTABLE"):
   - Add the QUERYABLE index first
   - Then add a separate SORTABLE index for the same field

**Important**: Do NOT use SEARCHABLE for Int64 or Double fields - use QUERYABLE instead!

#### 1.3 Create EventRSVP Record Type

Click **"+"** to create a new record type named `EventRSVP`

Add the following fields:

| Field Name | Field Type | Add Index? | Index Type | Notes |
|------------|------------|------------|------------|-------|
| id | String | ✓ Yes | QUERYABLE | UUID for RSVP |
| eventID | String | ✓ Yes | QUERYABLE | Associated event UUID |
| eventTitle | String | No | - | Event name |
| userEmail | String | ✓ Yes | QUERYABLE | User's email |
| userName | String | No | - | User's full name |
| rsvpDate | Date/Time | ✓ Yes | QUERYABLE + SORTABLE | When RSVP was made |
| status | String | ✓ Yes | QUERYABLE | Confirmed/Waitlist/Cancelled |
| guestCount | Int(64) | No | - | Number of guests |
| checkedIn | Int(64) | No | - | 1 = checked in, 0 = not |
| checkedInAt | Date/Time | No | - | Check-in timestamp |
| notes | String | No | No | No | User notes |

**Important**: Make sure **eventID** and **userEmail** are indexed and queryable for fast lookups!

#### 1.4 Deploy to Production

1. After creating both record types in **Development** environment
2. Click **"Deploy Schema Changes"** in the top menu
3. Select both `Event` and `EventRSVP` record types
4. Click **"Deploy to Production"**
5. Confirm the deployment

**Warning**: Schema changes in Production are permanent! Double-check all fields before deploying.

### Step 2: Test the Feature

#### 2.1 Test Event Creation

1. **Build and run the app** in Xcode
2. **Sign in** with your account
3. **Go to the Events tab** (calendar icon)
4. **Tap the "+" button** in the top right
5. **Fill out event details**:
   - Title: "Test Chapter Meeting"
   - Type: Meeting
   - Select your chapter
   - Set date/time for tomorrow
   - Location: "Student Center"
   - Description: "Testing event creation"
6. **Tap "Create"**
7. **Verify** the event appears in the list

#### 2.2 Test RSVP System

1. **Tap on the event** you just created
2. **Tap "RSVP to Event"** button
3. **Set guest count** (default is 1)
4. **Add optional notes**
5. **Tap "Confirm"**
6. **Verify**:
   - Green checkmark appears next to event in list
   - Event shows in "My Upcoming Events" section
   - Attendance count updated

#### 2.3 Test Filtering

1. **Go to Events tab**
2. **Test state filter**: Select your state, verify only local events show
3. **Test event type filter**: Select "Meeting", verify only meetings show
4. **Test search**: Type part of event name, verify search works
5. **Toggle "Past Events"**: Verify filter works
6. **Tap "Clear"**: Verify all filters reset

#### 2.4 Test CloudKit Sync

1. **Open CloudKit Dashboard**
2. **Select Production environment**
3. **Navigate to Data** → **Event**
4. **Verify your test event** appears in the records
5. **Check all fields** are properly saved
6. **Navigate to Data** → **EventRSVP**
7. **Verify your RSVP** appears

### Step 3: Verify App Capabilities

Your entitlements file should already have CloudKit enabled, but verify:

1. **Open Xcode**
2. **Select project** → **Target** → **Signing & Capabilities**
3. **Ensure "iCloud" capability** is present
4. **Verify "CloudKit" checkbox** is checked
5. **Confirm container** `iCloud.ChapterFinder` is selected

## 🚀 Usage Guide

### For Users

#### Browsing Events

1. Open the **Events tab**
2. Scroll through upcoming events
3. Use **filters** to narrow down:
   - By state (find events near you)
   - By event type (meetings, networking, etc.)
   - By date (today, upcoming, past)
4. **Search** for specific events by keyword

#### RSVP to an Event

1. **Tap an event** to view details
2. Review event information
3. **Tap "RSVP to Event"** button
4. **Select guest count** if bringing friends
5. **Add notes** (optional) - dietary restrictions, questions, etc.
6. **Tap "Confirm"**
7. You'll receive confirmation

#### Managing Your RSVPs

1. Your upcoming events show at **top of Events tab**
2. **Tap any event** to view details
3. **Cancel RSVP** by tapping "Cancel RSVP" button
4. Green checkmarks show events you're attending

### For Event Organizers

#### Creating an Event

1. **Go to Events tab**
2. **Tap "+" button** (top right)
3. **Fill out event details**:
   - **Title**: Clear, descriptive name
   - **Type**: Choose category (Meeting, Social, etc.)
   - **Chapter**: Select your chapter
   - **Date & Time**: When it starts (and optionally ends)
   - **Virtual toggle**: Enable for online events
   - **Location**: Name of venue or "Zoom Meeting"
   - **Virtual URL**: Add Zoom/Teams link if virtual
   - **Description**: Detailed info about the event
   - **RSVP settings**: Require RSVP, set capacity
   - **Tags**: Add searchable tags
4. **Preview** your event at the bottom
5. **Tap "Create"**

#### Event Best Practices

**Good Event Titles:**
- ✅ "Weekly Chapter Meeting - Guest Speaker"
- ✅ "Networking Night at The Bistro"
- ✅ "Campus Free Speech Rally"

**Bad Event Titles:**
- ❌ "Meeting"
- ❌ "Event"
- ❌ "TBD"

**Description Tips:**
- Include **what**, **why**, **who** should attend
- Mention any **requirements** (student ID, RSVP, etc.)
- Add **parking/directions** for in-person events
- Include **agenda** if applicable

**Setting Capacity:**
- Enable capacity for **limited venues**
- Leave unlimited for **open events** (rallies, public meetings)
- Add **buffer** for no-shows (if venue holds 50, set capacity to 45)

#### Managing Your Events

1. **Open event details** (tap on event)
2. **Tap menu** (three dots, top right)
3. **Options**:
   - **Edit Event**: Update details (coming soon)
   - **Delete Event**: Permanently remove
   - **Share Event**: Send to others
   - **Add to Calendar**: Export to iOS Calendar

## 🎨 Event Types & When to Use Them

| Event Type | Icon | Use For | Examples |
|------------|------|---------|----------|
| **Meeting** | 👥 | Regular chapter meetings | Weekly meetings, planning sessions, member meetings |
| **Networking** | 🤝 | Professional networking | Meet & greets, alumni mixers, career nights |
| **Speaker Event** | 🎤 | Guest speakers | Lectures, panels, Q&A sessions |
| **Workshop** | 🔨 | Educational workshops | Training sessions, skill-building, how-tos |
| **Social** | 🎉 | Social gatherings | Parties, game nights, happy hours, dinners |
| **Fundraiser** | 💰 | Fundraising events | Donation drives, charity events, auctions |
| **Protest/Rally** | 📢 | Political action | Protests, rallies, marches, demonstrations |
| **Volunteer** | ✨ | Community service | Service projects, volunteering, cleanup events |
| **Conference** | 🏛️ | Large formal events | Conferences, summits, conventions |
| **Other** | 📅 | Anything else | Miscellaneous events |

## 📱 Feature Highlights

### Smart Filtering

Events automatically filter to show:
- ✅ Only **active** events (not deleted)
- ✅ **Future** events by default
- ✅ **Past events** only when toggled on

### Capacity Management

- **Real-time tracking** of available spots
- **Visual indicators** when events are filling up
- **Full capacity** prevents additional RSVPs
- **Waitlist** (coming soon)

### My Events Section

- See all events you've RSVP'd to at a glance
- Quick access from horizontal scroll
- Shows countdown to today's events

### Rich Event Details

- **Maps** for in-person events
- **Virtual meeting links** for online events
- **Organizer contact** info
- **Attendance stats**
- **Event tags** for discovery

## 🔮 Future Enhancements

### Coming Soon:

1. ✨ **Push Notifications**
   - Reminders 24hrs and 1hr before event
   - Updates when event details change
   - Notification when event is full

2. 📅 **Calendar Integration**
   - One-tap add to iOS Calendar
   - Sync with Google Calendar
   - iCal export

3. 🗺️ **Map View**
   - See all events on interactive map
   - Cluster nearby events
   - "Events near me" feature

4. 📊 **Analytics Dashboard**
   - Most popular events
   - Attendance trends
   - Chapter engagement metrics

5. 🎫 **QR Code Check-in**
   - Generate QR codes for events
   - Scan to check in attendees
   - Track actual attendance

6. 📧 **Email Notifications**
   - RSVP confirmations
   - Event reminders
   - Updates from organizers

7. 🔁 **Recurring Events**
   - Create repeating events
   - Weekly meetings made easy
   - Series management

8. 💬 **Event Comments**
   - Ask questions about events
   - Organizer can respond
   - Event discussion thread

## 🐛 Troubleshooting

### CloudKit Schema Errors

**Problem**: "invalid attempt to set field flags for field 'latitude', flags are not compatible with type NUMBER_DOUBLE"

**Solution**: 
1. Double and Int64 fields **cannot** be marked as **SEARCHABLE**
2. Only mark them as **INDEXED** and **SORTABLE**
3. Use **QUERYABLE** index type (not SEARCHABLE) when adding indexes
4. For the error shown:
   - Field: `latitude`
   - Type: SEARCHABLE ❌ (Wrong!)
   - Should be: Leave index type blank or use QUERYABLE ✅

**How to Fix**:
1. Don't add any index for `latitude` and `longitude` (they're optional for our queries)
2. Or if you need them indexed, use type **QUERYABLE** (not SEARCHABLE)

### Events Not Showing

**Problem**: No events appear in the list

**Solutions**:
1. Pull down to refresh
2. Check filters - clear all filters
3. Toggle "Past Events" if looking for old events
4. Verify CloudKit schema is deployed to Production
5. Check internet connection

### Can't Create Event

**Problem**: Create button is disabled

**Solutions**:
1. Ensure all **required fields** are filled:
   - Title
   - Description
   - Location
   - Chapter selection
2. For virtual events, add **meeting URL**
3. Verify you're **signed in**

### RSVP Failed

**Problem**: RSVP doesn't save or shows error

**Solutions**:
1. Check if event is **full**
2. Verify you haven't **already RSVP'd**
3. Ensure **guest count** doesn't exceed remaining spots
4. Check internet connection
5. Try again after a few seconds

### CloudKit Errors

**Problem**: "Failed to load events" or CloudKit errors

**Solutions**:
1. Verify CloudKit schema is **deployed to Production**
2. Check all fields are **properly indexed**
3. Ensure you're signed into **iCloud** on device
4. Check CloudKit Dashboard for any **quota issues**
5. Review Xcode console for specific error codes

## 📊 Analytics & Insights

### Metrics to Track:

- **Total Events Created**: Measure adoption
- **Average RSVPs per Event**: Gauge interest
- **Most Active Chapters**: See engagement leaders
- **Popular Event Types**: Understand preferences
- **RSVP to Attendance Ratio**: Track no-shows

### Success Indicators:

- ✅ Users create events regularly
- ✅ High RSVP rates (>30% of chapter)
- ✅ Low cancellation rates (<10%)
- ✅ Events shared frequently
- ✅ Repeat attendees

## 🎯 Best Practices for Chapter Growth

### Drive Engagement:

1. **Create Regular Events**: Weekly meetings build habit
2. **Vary Event Types**: Mix social, educational, and action
3. **Set Reasonable Capacity**: Creates urgency
4. **Use Compelling Titles**: Make it sound exciting
5. **Add Tags**: Help discoverability
6. **Promote Early**: Create events 2+ weeks ahead

### Promote Events:

1. **Share on Social Media**: Link to app
2. **Email Reminders**: Use app + external channels
3. **Leverage "Today" Badge**: Creates FOMO
4. **Highlight Limited Capacity**: "Only 5 spots left!"
5. **Feature Success Stories**: Post event photos

---

## 📚 Technical Details

### Files Created/Modified:

**New Files:**
- `Models/Event.swift` - Event data model
- `Models/EventRSVP.swift` - RSVP data model  
- `Services/EventManager.swift` - CloudKit integration
- `ViewModels/EventsViewModel.swift` - Business logic
- `Views/EventsView.swift` - Main events list
- `Views/EventDetailView.swift` - Event details & RSVP
- `Views/CreateEventView.swift` - Event creation form

**Modified Files:**
- `SwiftChapterUSA_finderApp.swift` - Added EventManager
- `Views/MainTabView.swift` - Added Events tab

### CloudKit Container:
- Container: `iCloud.ChapterFinder`
- Database: Public (for discoverability)
- Record Types: `Event`, `EventRSVP`

### Dependencies:
- CloudKit Framework
- MapKit (for event maps)
- Combine (for reactive updates)

---

**Version**: 4.1  
**Last Updated**: April 26, 2026  
**Feature**: Events & Calendar System

## 🎉 You're All Set!

Your Events & Calendar System is now ready to drive engagement and growth for TPUSA chapters across the nation. Happy event planning! 🎊
