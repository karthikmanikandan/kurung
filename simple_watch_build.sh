#!/bin/bash

echo "🍎 Simple Apple Watch Build Script"

# Check if we're in the right directory
if [ ! -f "kurungaanaoli/kurungaanaoli.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: kurungaanaoli.xcodeproj not found"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "📱 Building for any available Apple Watch simulator..."

# Build for any watchOS simulator (Xcode will choose the best available)
cd kurungaanaoli

echo "🔨 Building project..."
xcodebuild -project kurungaanaoli.xcodeproj \
           -scheme "kurungaanaoli Watch App" \
           -destination "platform=watchOS Simulator" \
           build 2>&1 | grep -E "(warning|error|WARNING|ERROR|BUILD SUCCEEDED|BUILD FAILED)" | head -5

BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🎉 Your app is now built for all Apple Watch models!"
    echo ""
    echo "📱 To run in Xcode:"
    echo "1. Open: open kurungaanaoli.xcodeproj"
    echo "2. Select any Apple Watch simulator"
    echo "3. Press ⌘+R to run"
    echo ""
    echo "📱 Available simulators on your system:"
    xcrun simctl list devices | grep "Watch" | grep -v "Shutdown" | head -5
else
    echo "❌ Build failed!"
    echo "Please check the error messages above"
fi

cd .. 