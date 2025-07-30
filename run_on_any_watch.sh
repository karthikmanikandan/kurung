#!/bin/bash

echo "🍎 Running kurung on Any Available Apple Watch..."

# Function to get available watch simulators
get_available_simulators() {
    xcrun simctl list devices | grep "Watch" | grep -v "Shutdown" | head -5
}

# Function to start a simulator
start_simulator() {
    local simulator_id=$1
    local simulator_name=$2
    
    echo "🚀 Starting $simulator_name..."
    xcrun simctl boot "$simulator_id" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ $simulator_name is now running"
        return 0
    else
        echo "❌ Failed to start $simulator_name"
        return 1
    fi
}

# Function to build and run on simulator
build_and_run() {
    local simulator_id=$1
    local simulator_name=$2
    
    echo ""
    echo "🔨 Building for $simulator_name..."
    
    # Build the project
    cd kurungaanaoli
    xcodebuild -project kurungaanaoli.xcodeproj \
               -scheme "kurungaanaoli Watch App" \
               -destination "platform=watchOS Simulator,id=$simulator_id" \
               build 2>&1 | grep -E "(warning|error|WARNING|ERROR|BUILD SUCCEEDED|BUILD FAILED)" | head -3
    cd ..
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful for $simulator_name"
        
        # Install and launch the app
        echo "📱 Installing app on $simulator_name..."
        
        # Get the app path
        APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "kurungaanaoli Watch App.app" -type d | head -1)
        
        if [ -n "$APP_PATH" ]; then
            echo "📦 Installing from: $APP_PATH"
            xcrun simctl install "$simulator_id" "$APP_PATH"
            
            # Launch the app
            echo "🚀 Launching kurung app..."
            xcrun simctl launch "$simulator_id" "karkon.kurungaanaoli.watchkitapp"
            
            echo "🎉 App launched successfully on $simulator_name!"
            return 0
        else
            echo "❌ Could not find built app"
            return 1
        fi
    else
        echo "❌ Build failed for $simulator_name"
        return 1
    fi
}

# Main execution
echo "📱 Available Apple Watch Simulators:"
AVAILABLE_SIMULATORS=$(get_available_simulators)
echo "$AVAILABLE_SIMULATORS"

if [ -z "$AVAILABLE_SIMULATORS" ]; then
    echo "❌ No watchOS simulators found."
    echo "Please create a watchOS simulator in Xcode first."
    exit 1
fi

# Try to find a running simulator first
RUNNING_SIMULATOR=$(xcrun simctl list devices | grep "Watch" | grep "Booted" | head -1)

if [ -n "$RUNNING_SIMULATOR" ]; then
    echo "✅ Found running simulator:"
    echo "$RUNNING_SIMULATOR"
    
    # Extract simulator ID and name
    SIMULATOR_ID=$(echo "$RUNNING_SIMULATOR" | awk -F'[()]' '{print $2}' | tr -d ' ')
    SIMULATOR_NAME=$(echo "$RUNNING_SIMULATOR" | sed 's/.*Apple Watch \([^)]*\).*/\1/')
    
    build_and_run "$SIMULATOR_ID" "$SIMULATOR_NAME"
else
    echo "📱 No running simulators found. Starting one..."
    
    # Get the first available simulator
    FIRST_SIMULATOR=$(echo "$AVAILABLE_SIMULATORS" | head -1)
    SIMULATOR_ID=$(echo "$FIRST_SIMULATOR" | awk -F'[()]' '{print $2}' | tr -d ' ')
    SIMULATOR_NAME=$(echo "$FIRST_SIMULATOR" | sed 's/.*Apple Watch \([^)]*\).*/\1/')
    
    if start_simulator "$SIMULATOR_ID" "$SIMULATOR_NAME"; then
        build_and_run "$SIMULATOR_ID" "$SIMULATOR_NAME"
    else
        echo "❌ Failed to start any simulator"
        exit 1
    fi
fi

echo ""
echo "🎉 Script completed!"
echo "📱 Your kurung app should now be running on an Apple Watch simulator!" 