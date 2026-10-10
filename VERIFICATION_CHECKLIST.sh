#!/bin/bash

echo "=========================================="
echo "PROJECT STRUCTURE FIX VERIFICATION"
echo "=========================================="
echo ""

ERRORS=0

echo "1. Checking main entry point..."
if grep -q "@main" /Users/benh/Documents/SwiftChapterUSA_finder/SwiftChapterUSA_finder/SwiftChapterUSA_finderApp.swift; then
    echo "   ✓ Main project has @main"
else
    echo "   ✗ FAIL: Main project missing @main"
    ERRORS=$((ERRORS + 1))
fi

if grep -q "App.ContentView()" /Users/benh/Documents/SwiftChapterUSA_finder/SwiftChapterUSA_finder/SwiftChapterUSA_finderApp.swift; then
    echo "   ✓ Main project uses App.ContentView()"
else
    echo "   ✗ FAIL: Main project doesn't use App.ContentView()"
    ERRORS=$((ERRORS + 1))
fi

if grep -q "App.AppDelegate" /Users/benh/Documents/SwiftChapterUSA_finder/SwiftChapterUSA_finder/SwiftChapterUSA_finderApp.swift; then
    echo "   ✓ Main project uses App.AppDelegate"
else
    echo "   ✗ FAIL: Main project doesn't use App.AppDelegate"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "2. Checking App package doesn't have @main..."
if ! grep -r "@main" /Users/benh/Documents/SwiftChapterUSA_finder/Packages/App/Sources/App/ > /dev/null 2>&1; then
    echo "   ✓ App package has NO @main (correct)"
else
    echo "   ✗ FAIL: App package still has @main"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "3. Checking public exports from App package..."

for FILE in "ContentView.swift" "AppDelegate.swift"; do
    if grep -q "^public" /Users/benh/Documents/SwiftChapterUSA_finder/Packages/App/Sources/App/$FILE 2>/dev/null; then
        echo "   ✓ $FILE is public"
    else
        echo "   ✗ FAIL: $FILE is not public"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "4. Checking public views..."

for VIEW in "MainTabView" "DisclaimerView" "LoginView"; do
    if grep -q "public struct $VIEW" /Users/benh/Documents/SwiftChapterUSA_finder/Packages/App/Sources/App/Views/${VIEW}.swift 2>/dev/null; then
        echo "   ✓ $VIEW is public"
    else
        echo "   ✗ FAIL: $VIEW is not public"
        ERRORS=$((ERRORS + 1))
    fi
done

if grep -q "^public struct ContentView" /Users/benh/Documents/SwiftChapterUSA_finder/Packages/App/Sources/App/ContentView.swift; then
    echo "   ✓ ContentView is public"
else
    echo "   ✗ FAIL: ContentView is not public"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "5. Checking public initializers..."

for INIT in "ContentView" "MainTabView" "DisclaimerView" "LoginView"; do
    FILE=""
    if [ "$INIT" = "ContentView" ]; then
        FILE="/Users/benh/Documents/SwiftChapterUSA_finder/Packages/App/Sources/App/ContentView.swift"
    else
        FILE="/Users/benh/Documents/SwiftChapterUSA_finder/Packages/App/Sources/App/Views/${INIT}.swift"
    fi
    
    if grep -q "public init" "$FILE" 2>/dev/null; then
        echo "   ✓ $INIT has public init"
    else
        echo "   ✗ FAIL: $INIT missing public init"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "=========================================="
if [ $ERRORS -eq 0 ]; then
    echo "✅ ALL CHECKS PASSED - Ready for archiving!"
    echo "=========================================="
    exit 0
else
    echo "❌ $ERRORS CHECKS FAILED - Fix required"
    echo "=========================================="
    exit 1
fi
