#!/bin/bash

echo "🍎 Building for All Apple Watch Models..."

# Get all available watchOS simulators
WATCH_SIMULATORS=$(xcrun simctl list devices | grep "Watch" | grep -v "Shutdown" | awk -F'[()]' '{print $2}' | head -5)

if [ -z "$WATCH_SIMULATORS" ]; then
    echo "❌ No watchOS simulators found. Please start a simulator first."
    echo "Available simulators:"
    xcrun simctl list devices | grep "Watch"
    exit 1
fi

echo "📱 Found watchOS simulators:"
echo "$WATCH_SIMULATORS"

# Build for each simulator
for simulator_id in $WATCH_SIMULATORS; do
    echo ""
    echo "🔨 Building for simulator: $simulator_id"
    
    # Get simulator name
    simulator_name=$(xcrun simctl list devices | grep "$simulator_id" | sed 's/.*Apple Watch \([^)]*\).*/\1/')
    echo "📱 Building for: $simulator_name"
    
    # Build the project
    xcodebuild -project kurungaanaoli.xcodeproj \
               -scheme "kurungaanaoli Watch App" \
               -destination "platform=watchOS Simulator,id=$simulator_id" \
               build 2>&1 | grep -E "(warning|error|WARNING|ERROR|BUILD SUCCEEDED|BUILD FAILED)" | head -5
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful for $simulator_name"
    else
        echo "❌ Build failed for $simulator_name"
    fi
done

echo ""
echo "🎉 Build process completed for all watchOS simulators!"
echo ""
echo "📱 To run on a specific simulator:"
echo "1. Start a simulator: xcrun simctl boot <simulator_id>"
echo "2. Run the app: xcrun simctl install <simulator_id> <path_to_app>"
echo "3. Launch the app: xcrun simctl launch <simulator_id> <bundle_id>" 