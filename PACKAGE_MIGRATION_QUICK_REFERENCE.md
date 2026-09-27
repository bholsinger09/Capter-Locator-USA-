# Package Migration - Quick Reference Guide

## Visual Package Structure

```
SwiftChapterUSA/
├── Packages/
│   ├── Common/                    (foundation)
│   │   ├── Models: User, University
│   │   ├── Protocols: Base protocols
│   │   └── Utilities: Constants, Validators
│   │
│   ├── Authentication/            (auth flow)
│   │   ├── AuthenticationViewModel
│   │   ├── AuthenticationManager
│   │   └── AuthenticationView
│   │   └── Depends: Common
│   │
│   ├── Chapters/                  (chapters feature)
│   │   ├── ChaptersViewModel, CreateChapterViewModel
│   │   ├── ChapterManager, SubmissionManager
│   │   ├── Models: Chapter, ChapterUpdateSubmission
│   │   └── Views: ChaptersView, ChapterDetailView, etc.
│   │   └── Depends: Common, Authentication
│   │
│   ├── Events/                    (events feature)
│   │   ├── EventsViewModel
│   │   ├── EventManager
│   │   ├── Models: Event, EventRSVP
│   │   └── Views: EventsView, CreateEventView, etc.
│   │   └── Depends: Common, Chapters
│   │
│   ├── Geospatial/                (location services)
│   │   ├── GeospatialService
│   │   ├── LocationViewModel
│   │   ├── Views: LocationAnalyticsView, NearbyChaptersView
│   │   └── Depends: Common, Chapters
│   │
│   ├── Advocacy/                  (elected officials)
│   │   ├── AdvocacyViewModel
│   │   ├── Models: ElectedOfficial
│   │   └── Views: AdvocacyView
│   │   └── Depends: Common, Chapters
│   │
│   ├── Resources/                 (resource library)
│   │   ├── ResourceLibraryViewModel
│   │   ├── Models: Resource
│   │   └── Views: ResourceLibraryView, ResourceDetailView
│   │   └── Depends: Common
│   │
│   ├── Notifications/             (push notifications)
│   │   ├── NotificationManager
│   │   ├── NotificationSettingsViewModel
│   │   └── Views: NotificationSettingsView
│   │   └── Depends: Common, Authentication
│   │
│   └── AppUI/                     (shared components)
│       ├── LoadingView, ErrorView
│       ├── Colors, Typography
│       └── Depends: Common
│
└── App/                           (main app)
    ├── SwiftChapterUSA_finderApp.swift
    ├── ContentView.swift
    └── Depends: All feature packages
```

## Migration Order (Dependency-Safe)

```
1. Common                          (no dependencies)
   ↓
2. AppUI                          (depends: Common)
   ↓
3. Authentication                 (depends: Common)
   ↓
4. Notifications                  (depends: Common, Auth)
   ↓
5. Resources                      (depends: Common)
   ↓
6. Advocacy                       (depends: Common)
   ↓
7. Chapters                       (depends: Common, Auth)
   ↓
8. Events                         (depends: Common, Chapters)
   ↓
9. Geospatial                     (depends: Common, Chapters)
   ↓
10. App                           (depends: All features)
```

## Phase Timeline

| Phase | Duration | Tasks |
|-------|----------|-------|
| 1: Plan | 1 session | Create infrastructure plan ✅ |
| 2: Infrastructure | 1-2 sessions | Create Package.swift files, workspace setup |
| 3: Common | 1 session | Migrate Common package (foundation) |
| 4: Features | 4-6 sessions | Migrate each feature package sequentially |
| 5: App | 1 session | Migrate main app target |
| 6: Testing | 1-2 sessions | Comprehensive testing & validation |
| 7: Cleanup | 1 session | Documentation, merge to main |
| **TOTAL** | **~11-14 sessions** | (Can be parallelized with team) |

## Key Files to Create

### Package.swift Template Structure

For **each package**:
```
Packages/[PackageName]/
├── Package.swift                 ← NEW
├── Sources/
│   └── [PackageName]/
│       ├── Models/
│       ├── Services/
│       ├── ViewModels/
│       ├── Views/
│       └── Protocols/
└── Tests/
    └── [PackageName]Tests/
```

## Git Workflow

```bash
# 1. Create feature branch
git checkout -b feature/package-migration

# 2. For each package migration
git add Packages/[Package]/
git commit -m "feat: migrate [Package] to SPM"

# 3. After all phases complete
git push origin feature/package-migration
# Create PR for review
# Merge to main

# 4. Cleanup
git branch -d feature/package-migration
```

## Import Changes Summary

### Before Migration
```swift
// No imports, all in same target
let chapter = Chapter(...)
let authVM = AuthenticationViewModel(...)
```

### After Migration
```swift
// Packages declare dependencies explicitly
import Common              // ← Now required
import Authentication      // ← Now required

let user = User(...)              // From Common
let authVM = AuthenticationViewModel(...)  // From Authentication
```

## Compilation Verification Checklist

For each package after migration:

```
✓ Package compiles independently
  xcodebuild build -scheme [PackageName]

✓ Tests pass
  xcodebuild test -scheme [PackageName]

✓ No circular dependencies
  (Check Package.swift files manually)

✓ All public APIs accessible
  (Try importing from other packages)

✓ No floating import errors
  (Build warnings clean)
```

## Key Metrics to Track

| Metric | Before | After | Goal |
|--------|--------|-------|------|
| Full Build Time | ~45s | ~60s | Parallelize later |
| Incremental Build | ~10s | ~3-5s | ✓ Much faster |
| Circular Dependencies | 0 | 0 | Maintain zero |
| Test Coverage | Current % | Current % | Maintain or improve |

## Emergency Rollback

If major issues arise:
```bash
# Return to stable state
git reset --hard origin/main
git branch -D feature/package-migration

# Analyze, replan, retry
```

## Success Indicators

✅ Migration is successful when:
- [ ] All packages build independently
- [ ] Full build succeeds
- [ ] All tests pass
- [ ] App launches in simulator
- [ ] All features work in manual testing
- [ ] No circular dependencies
- [ ] Incremental builds are faster

---

## Common Gotchas

⚠️ **Circular Imports**
- Solution: Review dependency graph before starting
- Check: No package should import from package that imports it

⚠️ **Missing Imports After Migration**
- Solution: Add `import [PackageName]` to every file that uses types from that package
- Test: Use build to catch these early

⚠️ **Singleton Services (NotificationManager.shared)**
- Solution: Keep as-is initially, refactor to dependency injection in future phase
- Note: Already using good patterns (protocol-first), so this is minor

⚠️ **SwiftUI Preview Providers**
- Solution: Ensure mock services are available in preview context
- Note: Mock services should be in test target, not main target

---

**Status**: Ready for Phase 2 implementation  
**Created**: September 27, 2024
