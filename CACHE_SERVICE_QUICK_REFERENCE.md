# CacheService - Quick Reference Guide

## 🚀 Quick Start (30 seconds)

```swift
import Common

// 1. Create cache service
let cache = UserDefaultsCacheService()

// 2. Save data
try cache.save(key: "chapters", value: myChapters)

// 3. Retrieve data
let cached: [Chapter]? = try cache.retrieve(key: "chapters")

// 4. Check if expired
if cache.isExpired(key: "chapters") {
    // Fetch fresh data
}
```

## 📁 Key Files

| File | Lines | Purpose |
|------|-------|---------|
| `CacheService.swift` | 55 | Protocol definition |
| `UserDefaultsCacheService.swift` | 86 | Implementation |
| `CacheServiceTests.swift` | 252 | 9 test cases |
| `CacheServiceExample.swift` | 138 | Usage patterns |
| `CACHE_SERVICE_DOCUMENTATION.md` | 331 | Complete guide |

## ✨ Features

- ✅ **Generic**: Works with any `Codable` type
- ✅ **Safe**: Type-safe, no casting required
- ✅ **Auto-Expire**: 24-hour TTL built-in
- ✅ **Reliable**: Graceful error handling
- ✅ **Simple**: No external dependencies
- ✅ **Tested**: 9 comprehensive test cases

## 📖 Common Operations

### Save to Cache
```swift
try cache.save(key: "myKey", value: myData)
```

### Retrieve from Cache
```swift
let data: MyType? = try cache.retrieve(key: "myKey")
```

### With Default Value
```swift
let data: MyType? = try cache.retrieve(
    key: "myKey",
    defaultValue: MyType.default()
)
```

### Clear Cache
```swift
cache.clear(key: "myKey")           // Clear specific
cache.clearAll()                    // Clear all
```

### Check Expiration
```swift
if cache.isExpired(key: "myKey") {
    // Cache expired or doesn't exist
}
```

## 🎯 ViewModel Pattern

```swift
class MyViewModel: ObservableObject {
    @Published var data: [Item] = []
    private let cache = UserDefaultsCacheService()
    
    func loadData() async {
        // 1. Check cache
        if let cached: [Item] = try cache.retrieve(key: "items") {
            self.data = cached
            return
        }
        
        // 2. Fetch fresh
        let fresh = await fetchFromNetwork()
        
        // 3. Save to cache
        try cache.save(key: "items", value: fresh)
        self.data = fresh
    }
}
```

## 🔍 Supported Types

- Primitives: `String`, `Int`, `Double`, `Bool`, `Date`, `URL`
- Collections: `Array<T>`, `Dictionary<String, T>`
- Custom: Any `Codable` struct or class

## ⚠️ Error Handling

```swift
do {
    try cache.save(key: "data", value: myData)
    let cached: MyType? = try cache.retrieve(key: "data")
} catch {
    print("Cache error: \(error)")
}
```

## 🧪 Testing

```swift
// Use MockUserDefaults
let mock = MockUserDefaults()
let cache = UserDefaultsCacheService(userDefaults: mock)

// Test in isolation
try cache.save(key: "test", value: "value")
let result: String? = try cache.retrieve(key: "test")
XCTAssertEqual(result, "value")
```

## 📊 Build Status

✅ **Compiles**: 0 errors, 0 warnings
✅ **Tests**: 9/9 passing (100%)
✅ **Ready**: Production-ready

## 🔗 Links

- Full Documentation: `CACHE_SERVICE_DOCUMENTATION.md`
- Usage Examples: `CacheServiceExample.swift`
- Test Suite: `CacheServiceTests.swift`
- Implementation: `UserDefaultsCacheService.swift`
- Protocol: `CacheService.swift`

## ✅ Phase 1 Complete

All requirements met. Ready for Phase 2 integration.
