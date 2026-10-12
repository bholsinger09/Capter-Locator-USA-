# Build Warnings Remediation Plan

**Date:** October 12, 2026  
**Goal:** Fix all build warnings to achieve clean build with zero warnings  
**Estimated Effort:** ~30 minutes  
**Risk Level:** LOW - All changes are API modernization with backward compatibility

---

## Summary of Issues

| # | Category | Severity | Files Affected | Count |
|---|----------|----------|-----------------|-------|
| 1 | Deprecated API | ⚠️ HIGH | FavoritesView.swift | 2 instances |
| 2 | Concurrency | 🔴 CRITICAL | ChaptersViewModel.swift, ChaptersView.swift | 2+ instances |
| 3 | Project Settings | ℹ️ INFO | Build Settings | 1 recommendation |

---

## Issue #1: Deprecated NavigationLink API

### Problem
```swift
NavigationLink(destination: ChapterDetailView(...), isActive: $isNavigating) {
    EmptyView()
}
```
- Deprecated in iOS 16.0
- Use `NavigationLink(value:label:)` instead

### Locations
- `Packages/App/Sources/App/Views/FavoritesView.swift` - Lines 200-310
  - `FavoriteCaptureRow` (lines ~205-215)
  - `FavoriteUniversityRow` (lines ~260-270)

### Solution
Replace with modern `NavigationStack` + `navigationDestination` pattern:

```swift
@State private var selectedChapter: Chapter?

var body: some View {
    NavigationStack {
        Button(action: { selectedChapter = chapter }) {
            ChapterRowContent(chapter: chapter, viewModel: viewModel)
        }
        .navigationDestination(item: $selectedChapter) { chapter in
            ChapterDetailView(chapter: chapter, viewModel: viewModel)
        }
    }
}
```

### Implementation Steps
1. Add `@State` for selected item in each row struct
2. Change Button action to set selected item
3. Replace NavigationLink with navigationDestination modifier
4. Remove EmptyView and isActive state

**Files to modify:**
- [ ] `Packages/App/Sources/App/Views/FavoritesView.swift` (2 locations)

**Verification:** Build with zero deprecation warnings

---

## Issue #2: Concurrent Variable Reference Errors

### Problem
Reference to captured var 'chapters' in concurrently-executing code; this is an error

```swift
let chapters = self.chapters  // Captured in closure
Task {
    // Using chapters in async context causes warning
}
```

### Root Cause
SwiftUI `@Published` properties may be modified on main thread while closure captures them, creating data race condition warning.

### Locations
- `Packages/Chapters/Sources/Chapters/ViewModels/ChaptersViewModel.swift`
- `Packages/Chapters/Sources/Chapters/Views/ChaptersView.swift`

### Solution
Ensure all main-thread updates use `MainActor.run`:

```swift
// BAD - captures chapters in concurrent closure
let chapters = self.chapters
Task {
    service.findNearbyChapters(chapters: chapters)
}

// GOOD - executes on main thread, captures are safe
await MainActor.run {
    service.findNearbyChapters(chapters: self.chapters)
}
```

### Implementation Steps
1. **ChaptersViewModel.swift**
   - Review all `async` methods
   - Wrap all `self.chapters` access with `MainActor.run`
   - Remove unnecessary local captures

2. **ChaptersView.swift**
   - In `onAppear`, ensure proper `await MainActor.run` wrapping
   - Verify all view-model property accesses

**Files to modify:**
- [ ] `Packages/Chapters/Sources/Chapters/ViewModels/ChaptersViewModel.swift`
- [ ] `Packages/Chapters/Sources/Chapters/Views/ChaptersView.swift`

**Verification:** Build with zero concurrency warnings

---

## Issue #3: Update to Recommended iOS Deployment Target

### Problem
Project deployment target should use recommended iOS version

### Solution
Update Build Settings:
- Set `IPHONEOS_DEPLOYMENT_TARGET` to recommended minimum (iOS 14.0+)
- Enable "Enable Testability" for Debug configuration
- Generate asset symbol extensions

### Implementation Steps
1. Open Build Settings in Xcode
2. Check "Use Recommended iOS Deployment Target"
3. Verify settings propagate to all targets
4. Perform clean build

**Files to modify:**
- [ ] Project.pbxproj (via Xcode UI)

**Verification:** Build settings show no recommendations

---

## Remediation Sequence

### Phase 1: Concurrency Fixes (PRIORITY)
**Why First:** Concurrency errors can cause runtime crashes; deprecation is just warnings
1. [ ] Audit ChaptersViewModel.swift for concurrent variable captures
2. [ ] Add MainActor.run wrapping where needed
3. [ ] Test build (no concurrency warnings)
4. [ ] Commit: "Fix concurrency warnings - ensure main thread safety"

### Phase 2: Deprecated API Fixes
1. [ ] Refactor FavoritesView NavigationLink → navigationDestination
2. [ ] Test navigation works correctly
3. [ ] Test build (no deprecation warnings)
4. [ ] Commit: "Modernize NavigationLink API - use iOS 16+ patterns"

### Phase 3: Project Settings
1. [ ] Update recommended deployment target
2. [ ] Enable recommended build settings
3. [ ] Clean build
4. [ ] Commit: "Update project build settings to recommended"

### Phase 4: Final Verification
1. [ ] Full clean build: `swift build clean && swift build`
2. [ ] Xcode build: Full build with Debug configuration
3. [ ] Verify: 0 warnings, 0 errors
4. [ ] Commit: "Final: all warnings resolved - clean build"

---

## Testing Checklist

After fixes:
- [ ] App builds without warnings in Swift CLI
- [ ] App builds without warnings in Xcode
- [ ] Chapter detail navigation works
- [ ] Favorites list displays correctly
- [ ] Search and filtering still work
- [ ] Pagination unchanged
- [ ] Location analytics functional
- [ ] Events tab functional
- [ ] Dark mode works

---

## Rollback Plan

If any fix breaks functionality:
1. `git revert` the problematic commit
2. Identify issue
3. Re-implement with fix
4. Test before re-committing

---

## Success Criteria

✅ **All criteria must be met:**
- [ ] Zero compilation errors
- [ ] Zero compilation warnings
- [ ] All unit tests pass
- [ ] Manual testing passes (navigation, favorites, search)
- [ ] Dark mode unaffected
- [ ] Performance unchanged
- [ ] Commits are clean and well-documented
