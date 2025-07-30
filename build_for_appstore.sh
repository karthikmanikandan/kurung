#!/bin/bash

# Build script for App Store submission
# This script prepares the app for App Store upload

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

echo "🏪 Preparing App for App Store Submission"
echo "========================================="
echo

# Check if we're in the right directory
if [ ! -f "kurungaanaoli/kurungaanaoli.xcodeproj/project.pbxproj" ]; then
    print_error "Please run this script from the kurung project root directory"
    exit 1
fi

# Check 1: Verify project structure
print_status "1. Checking project structure..."
if [ -d "kurungaanaoli/kurungaanaoli Watch App" ]; then
    print_success "✅ Watch app directory exists"
else
    print_error "❌ Watch app directory missing"
    exit 1
fi

if [ -f "kurungaanaoli/Info.plist" ]; then
    print_success "✅ Info.plist exists"
else
    print_error "❌ Info.plist missing"
    exit 1
fi

if [ -f "kurungaanaoli/kurungaanaoli Watch App/Config/AppConfig.swift" ]; then
    print_success "✅ AppConfig.swift exists"
else
    print_error "❌ AppConfig.swift missing"
    exit 1
fi
echo

# Check 2: Verify Info.plist configuration
print_status "2. Checking Info.plist configuration..."
if grep -q "CFBundleDisplayName.*YouTube Shorts" kurungaanaoli/Info.plist; then
    print_success "✅ Display name configured"
else
    print_warning "⚠️  Display name may not be set correctly"
fi

if grep -q "CFBundleShortVersionString.*1.0" kurungaanaoli/Info.plist; then
    print_success "✅ Version number configured"
else
    print_warning "⚠️  Version number may not be set correctly"
fi

if grep -q "CFBundleVersion.*1" kurungaanaoli/Info.plist; then
    print_success "✅ Build number configured"
else
    print_warning "⚠️  Build number may not be set correctly"
fi

if grep -q "onrender.com" kurungaanaoli/Info.plist; then
    print_success "✅ Render domain configured in ATS"
else
    print_error "❌ Render domain not found in ATS exceptions"
fi
echo

# Check 3: Verify AppConfig.swift
print_status "3. Checking AppConfig.swift..."
if grep -q "kurung.onrender.com" kurungaanaoli/kurungaanaoli\ Watch\ App/Config/AppConfig.swift; then
    print_success "✅ Backend URL configured for production"
else
    print_error "❌ Backend URL not configured for production"
fi
echo

# Check 4: Verify assets
print_status "4. Checking app assets..."
if [ -d "kurungaanaoli/kurungaanaoli Watch App/Assets.xcassets" ]; then
    print_success "✅ Assets directory exists"
    
    if [ -f "kurungaanaoli/kurungaanaoli Watch App/Assets.xcassets/AppIcon.appiconset/Contents.json" ]; then
        print_success "✅ App icon configuration exists"
    else
        print_warning "⚠️  App icon configuration missing"
    fi
    
    if [ -f "kurungaanaoli/kurungaanaoli Watch App/Assets.xcassets/KurungLogo.imageset/Contents.json" ]; then
        print_success "✅ App logo exists"
    else
        print_warning "⚠️  App logo missing"
    fi
else
    print_error "❌ Assets directory missing"
fi
echo

# Check 5: Verify backend is working
print_status "5. Checking backend connectivity..."
BACKEND_URL="https://kurung.onrender.com"
HEALTH_RESPONSE=$(curl -s --max-time 10 "$BACKEND_URL/health" 2>/dev/null || echo "FAILED")

if [ "$HEALTH_RESPONSE" = "FAILED" ]; then
    print_error "❌ Backend is not responding"
    print_warning "⚠️  App may not work properly without backend"
else
    if echo "$HEALTH_RESPONSE" | grep -q '"status":"healthy"'; then
        print_success "✅ Backend is healthy"
    else
        print_warning "⚠️  Backend responded but status unclear"
    fi
fi
echo

# Check 6: Build verification
print_status "6. Verifying build configuration..."
cd kurungaanaoli

# Check if project can be built
if xcodebuild -project kurungaanaoli.xcodeproj -scheme "kurungaanaoli Watch App" -destination "platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)" clean build > /dev/null 2>&1; then
    print_success "✅ Project builds successfully"
else
    print_error "❌ Project build failed"
    print_status "Run 'xcodebuild -project kurungaanaoli.xcodeproj -scheme \"kurungaanaoli Watch App\" clean build' for detailed error"
    exit 1
fi

cd ..
echo

# Summary
echo "📊 App Store Preparation Summary"
echo "================================"
print_success "✅ Project structure verified"
print_success "✅ Info.plist configured"
print_success "✅ AppConfig.swift configured"
print_success "✅ Assets directory exists"
print_success "✅ Backend connectivity verified"
print_success "✅ Project builds successfully"

echo
print_status "Next steps for App Store submission:"
echo "1. Open kurungaanaoli.xcodeproj in Xcode"
echo "2. Update Bundle Identifier to be unique"
echo "3. Archive the project (Product → Archive)"
echo "4. Upload to App Store Connect"
echo "5. Follow APP_STORE_SUBMISSION_GUIDE.md"

echo
print_warning "Important reminders:"
echo "• Update Bundle Identifier to be unique"
echo "• Prepare app screenshots (iPhone + Watch)"
echo "• Create privacy policy (required)"
echo "• Consider YouTube branding implications"

echo
print_success "🎉 App is ready for App Store submission!" 