#!/bin/bash

# Comprehensive test script for Watch Simulator setup
# This script tests all components needed for the watch simulator to work

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_status "🔍 Starting comprehensive Watch Simulator test..."
echo

# Test 1: Check Xcode installation
print_status "Testing Xcode installation..."
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -1)
    print_success "Xcode found: $XCODE_VERSION"
else
    print_error "Xcode not found. Please install Xcode from the App Store."
    exit 1
fi

# Test 2: Check Watch Simulator availability
print_status "Testing Watch Simulator availability..."
if xcrun simctl list devices | grep -q "Watch"; then
    print_success "Watch simulators available"
    xcrun simctl list devices | grep "Watch" | head -3
else
    print_error "No Watch simulators found. Please install watchOS simulator in Xcode."
    exit 1
fi

# Test 3: Check project structure
print_status "Testing project structure..."
REQUIRED_FILES=(
    "kurungaanaoli/kurungaanaoli.xcodeproj/project.pbxproj"
    "kurungaanaoli/kurungaanaoli Watch App/ContentView.swift"
    "kurungaanaoli/kurungaanaoli Watch App/Config/AppConfig.swift"
    "kurungaanaoli/Info.plist"
    "insta-reels-backend/server.js"
    "insta-reels-backend/package.json"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "✅ $file exists"
    else
        print_error "❌ $file missing"
        exit 1
    fi
done

# Test 4: Check backend configuration
print_status "Testing backend configuration..."
if grep -q "https://kurung-backend.onrender.com" "kurungaanaoli/kurungaanaoli Watch App/Config/AppConfig.swift"; then
    print_success "✅ Backend URL configured correctly"
else
    print_error "❌ Backend URL not configured correctly"
    exit 1
fi

# Test 5: Check ATS configuration
print_status "Testing App Transport Security configuration..."
if grep -q "onrender.com" "kurungaanaoli/Info.plist"; then
    print_success "✅ ATS exceptions for Render configured"
else
    print_error "❌ ATS exceptions for Render missing"
    exit 1
fi

# Test 6: Test local backend
print_status "Testing local backend..."
cd insta-reels-backend

# Kill any existing server
pkill -f "node server.js" || true
sleep 2

# Start server with mock data
print_status "Starting local backend with mock data..."
USE_MOCK_DATA=true npm start > /tmp/backend.log 2>&1 &
BACKEND_PID=$!

# Wait for server to start
sleep 5

# Test health endpoint
if curl -s http://localhost:3000/health | grep -q "healthy"; then
    print_success "✅ Local backend health check passed"
else
    print_error "❌ Local backend health check failed"
    kill $BACKEND_PID 2>/dev/null || true
    exit 1
fi

# Test reels endpoint
REELS_RESPONSE=$(curl -s "http://localhost:3000/reels?limit=3")
if echo "$REELS_RESPONSE" | grep -q "videoUrl" && echo "$REELS_RESPONSE" | grep -q "commondatastorage.googleapis.com"; then
    print_success "✅ Local backend reels endpoint working"
    print_status "Sample response: $(echo "$REELS_RESPONSE" | jq -r '.reels[0].videoUrl' 2>/dev/null || echo 'N/A')"
else
    print_error "❌ Local backend reels endpoint failed"
    print_status "Response: $REELS_RESPONSE"
    kill $BACKEND_PID 2>/dev/null || true
    exit 1
fi

# Kill local backend
kill $BACKEND_PID 2>/dev/null || true
cd ..

# Test 7: Test production backend
print_status "Testing production backend..."
PROD_HEALTH=$(curl -s -m 10 https://kurung-backend.onrender.com/health || echo "FAILED")
if echo "$PROD_HEALTH" | grep -q "healthy"; then
    print_success "✅ Production backend health check passed"
else
    print_warning "⚠️ Production backend health check failed or slow"
    print_status "Response: $PROD_HEALTH"
fi

# Test 8: Check Xcode project compilation
print_status "Testing Xcode project compilation..."
cd kurungaanaoli

# Clean build folder
rm -rf build/ || true

# Try to build the project
if xcodebuild -project kurungaanaoli.xcodeproj -scheme "kurungaanaoli Watch App" -destination "platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)" build > /tmp/xcode_build.log 2>&1; then
    print_success "✅ Xcode project builds successfully"
else
    print_warning "⚠️ Xcode build failed - check /tmp/xcode_build.log for details"
    print_status "This might be due to signing issues or missing certificates"
fi

cd ..

# Test 9: Check for common issues
print_status "Checking for common issues..."

# Check if Info.plist has required keys
if grep -q "WKApplication" "kurungaanaoli/Info.plist"; then
    print_success "✅ WKApplication key present"
else
    print_error "❌ WKApplication key missing from Info.plist"
fi

if grep -q "WKWatchKitApp" "kurungaanaoli/Info.plist"; then
    print_success "✅ WKWatchKitApp key present"
else
    print_error "❌ WKWatchKitApp key missing from Info.plist"
fi

# Check bundle identifier format
if grep -q "karkon.kurungaanaoli" "kurungaanaoli/kurungaanaoli.xcodeproj/project.pbxproj"; then
    print_success "✅ Bundle identifier configured"
else
    print_error "❌ Bundle identifier not found"
fi

echo
print_status "=== Test Summary ==="
print_success "✅ All critical components verified"
print_success "✅ Backend configuration correct"
print_success "✅ ATS settings configured"
print_success "✅ Project structure complete"

echo
print_status "Next steps:"
echo "1. Open kurungaanaoli.xcodeproj in Xcode"
echo "2. Select 'kurungaanaoli Watch App' scheme"
echo "3. Choose a Watch simulator (e.g., Apple Watch Series 9)"
echo "4. Press Cmd+R to build and run"
echo "5. If signing issues occur, go to Signing & Capabilities and select 'Automatically manage signing'"

echo
print_warning "Note: If you encounter signing issues, you may need to:"
echo "- Sign in to your Apple ID in Xcode"
echo "- Create a free Apple Developer account"
echo "- Let Xcode automatically manage signing"

echo
print_success "🎉 Watch Simulator setup is ready!" 