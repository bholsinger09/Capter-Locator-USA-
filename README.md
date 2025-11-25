# Chapter Locator USA

A SwiftUI application for iOS (11-16) and macOS that helps users find and connect with Turning Point USA chapters across the United States.

## ⚠️ Disclaimer

**This is NOT the official Turning Point USA application.** This is an independent tool created to help people find local TPUSA chapters and connect with other members. For the official Turning Point USA resources, please visit [www.tpusa.com](https://www.tpusa.com).

## Features

### 🔐 User Authentication
- User registration with email and password
- Secure login system
- Profile management
- State and university selection

### 🏛️ Chapter Locator
- 50+ pre-loaded chapters across multiple states
- Search chapters by name, city, state, or university
- Filter by state
- View detailed chapter information including:
  - Contact details
  - Meeting schedules and locations
  - Member counts
  - President information
- Create new chapters

### 🎓 University Browser
- Comprehensive list of universities across the US
- Filter by state and chapter availability
- View at least 3 universities per area
- See which universities have active chapters
- Student population and website information

### 👥 Members Section
- View membership status
- See your chapter information
- Find nearby chapters in your state
- Access member resources
- Links to official TPUSA resources

### 💬 Blog/Chat Section
- Create posts to share with other members
- Reply to posts
- Filter posts by:
  - All posts
  - Your chapter
  - Your state
- Like and comment on posts

### 👤 Profile Management
- Edit personal information
- Update location and university
- View account details
- Logout functionality

## Architecture

This application follows **MVVM (Model-View-ViewModel)** architecture with a **Test-Driven Development** approach:

- **Models**: Pure data structures (User, Chapter, University, BlogPost)
- **Views**: SwiftUI views that bind to ViewModels
- **ViewModels**: Business logic, form validation, data transformation
- **Services**: Data management and persistence
- **Protocols**: Service abstractions for dependency injection and testing

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.

## Technical Requirements

### Platform Support
- iOS 13+ (SwiftUI requirement)
- macOS (via Mac Catalyst)
- iPhone 11, 12, 13, 14, 15, 16

### Technologies
- **SwiftUI**: Declarative UI framework
- **Combine**: Reactive programming for data binding
- **MVVM**: Architecture pattern
- **XCTest**: Unit testing framework
- **Protocol-Oriented Design**: Dependency injection
- **UserDefaults**: Local data persistence

## Project Structure

```
SwiftChapterUSA_finder/
├── SwiftChapterUSA_finderApp.swift    # Main app entry point
├── ContentView.swift                  # Root view with navigation logic
├── Models/                            # Data models
│   ├── User.swift                     # User data model
│   ├── Chapter.swift                  # Chapter data model
│   ├── University.swift               # University data model
│   └── BlogPost.swift                 # Blog post and reply models
├── Views/                             # SwiftUI views (UI only)
│   ├── AuthenticationView.swift       # Login and registration
│   ├── DisclaimerView.swift          # Disclaimer screen
│   ├── MainTabView.swift             # Main tab navigation
│   ├── ChaptersView.swift            # Chapter list and search
│   ├── ChapterDetailView.swift       # Chapter details
│   ├── CreateChapterView.swift       # New chapter creation
│   ├── UniversitiesView.swift        # University browser
│   ├── MembersView.swift             # Member information
│   ├── BlogView.swift                # Blog/chat functionality
│   └── ProfileView.swift             # User profile
├── ViewModels/                        # Business logic layer (MVVM)
│   ├── AuthenticationViewModel.swift  # Auth form handling
│   ├── ChaptersViewModel.swift        # Chapter filtering/search
│   ├── CreateChapterViewModel.swift   # Chapter creation logic
│   ├── UniversitiesViewModel.swift    # University filtering
│   ├── MembersViewModel.swift         # Member data handling
│   ├── BlogViewModel.swift            # Blog post filtering
│   ├── CreatePostViewModel.swift      # Post creation logic
│   └── ProfileViewModel.swift         # Profile management
├── Services/                          # Data layer
│   ├── AuthenticationManager.swift    # Auth state management
│   └── ChapterManager.swift           # Chapter and post management
├── Protocols/                         # Service abstractions
│   ├── AuthenticationServiceProtocol.swift
│   └── ChapterServiceProtocol.swift
├── Data/                              # Sample data
│   ├── ChapterData.swift             # Sample chapter data
│   └── UniversityData.swift          # Sample university data
├── Tests/                             # Unit tests (TDD)
│   ├── ModelTests.swift              # Model tests
│   ├── AuthenticationViewModelTests.swift
│   ├── ChaptersViewModelTests.swift
│   ├── CreateChapterViewModelTests.swift
│   ├── UniversitiesViewModelTests.swift
│   ├── BlogViewModelTests.swift
│   ├── ProfileViewModelTests.swift
│   ├── ServiceTests.swift            # Service layer tests
│   ├── MockAuthenticationService.swift
│   └── MockChapterService.swift
├── Info.plist                        # App configuration
├── README.md                         # This file
└── ARCHITECTURE.md                   # Detailed architecture guide
```

## Setup Instructions

### Prerequisites
- Xcode 13.0 or later
- macOS 11.0 or later
- iOS 13.0+ SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/bholsinger09/Swift_Finda_Chapter_TurningPoint_Helper.git
   cd Swift_Finda_Chapter_TurningPoint_Helper
   ```

2. **Open in Xcode**
   ```bash
   open SwiftChapterUSA_finder.xcodeproj
   ```
   
   Or manually:
   - Launch Xcode
   - Select "Open a project or file"
   - Navigate to the project directory

3. **Configure the project**
   - Select the project in the navigator
   - Choose your development team under "Signing & Capabilities"
   - Ensure the bundle identifier is unique

### Building and Running

1. **Select target device**
   - Choose iPhone simulator or connected device
   - Or select "My Mac" for macOS build

2. **Build and run**
   - Press ⌘R or click the Run button
   - The app will compile and launch

### Running Tests

1. **Run all tests**
   ```
   ⌘ + U
   ```

2. **Run specific test suite**
   - Navigate to test file
   - Click the diamond icon next to test class
   - Or press ⌘ + U with test selected

3. **View test coverage**
   - Product → Test
   - View test reports in the Report Navigator

4. **Command line testing**
   ```bash
   xcodebuild test -scheme SwiftChapterUSA_finder -destination 'platform=iOS Simulator,name=iPhone 15'
   ```

### For iOS Deployment

To support iOS 11-16:
- Set Deployment Target to iOS 13.0 (minimum for SwiftUI)
- Note: iOS 11-12 require UIKit; this SwiftUI version supports iOS 13+

### For macOS Support

1. Add macOS target via Mac Catalyst:
   - Select project in navigator
   - Select target
   - Go to "Signing & Capabilities"
   - Check "Mac" under Supported Destinations

## Data Storage

Currently uses UserDefaults for local storage. For production use, consider:
- Firebase for real-time database
- CloudKit for iCloud sync
- Core Data for local persistence
- RESTful API backend

## Future Enhancements

- Push notifications for chapter events
- Map integration for chapter locations
- Event calendar
- Photo sharing
- Direct messaging between members
- Chapter leadership tools
- Integration with official TPUSA systems (with permission)

## Important Notes

1. **Not Official**: This app is not affiliated with or endorsed by Turning Point USA
2. **Data**: Chapter and university data is sample/placeholder data
3. **Authentication**: Uses basic local authentication; implement proper backend for production
4. **Privacy**: No real user data is transmitted; implement privacy policy for production

## Support

For the official Turning Point USA website and resources:
- Website: [www.tpusa.com](https://www.tpusa.com)
- Official Chapter Resources: [www.tpusa.com/chapters](https://www.tpusa.com/chapters)

## License

This project is for educational and community purposes. Always refer to and respect Turning Point USA's official policies and trademarks.
