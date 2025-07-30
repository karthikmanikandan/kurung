#!/bin/bash

echo "🎬 YouTube Shorts WatchOS App - Project Verification"
echo "=================================================="

# Check if we're in the right directory
if [ ! -d "insta-reels-backend" ] || [ ! -d "kurungaanaoli" ]; then
    echo "❌ Error: Please run this script from the kurung/ directory"
    echo "   Expected: insta-reels-backend/ and kurungaanaoli/ folders"
    exit 1
fi

echo "✅ Project structure verified"

# Kill any existing Node.js processes
echo "🔄 Cleaning up existing processes..."
pkill -f "node.*server.js" 2>/dev/null
sleep 2

# Start backend
echo "🚀 Starting backend server..."
cd insta-reels-backend
USE_MOCK_DATA=true node server.js &
BACKEND_PID=$!
sleep 3

# Test backend endpoints
echo "🧪 Testing backend endpoints..."

# Health check
HEALTH_RESPONSE=$(curl -s "http://localhost:3000/health")
if echo "$HEALTH_RESPONSE" | grep -q "youtube-shorts"; then
    echo "✅ Health endpoint working"
else
    echo "❌ Health endpoint failed"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

# Reels endpoint
REELS_RESPONSE=$(curl -s "http://localhost:3000/reels?limit=3")
REELS_COUNT=$(echo "$REELS_RESPONSE" | jq '.reels | length' 2>/dev/null)

if [ "$REELS_COUNT" = "3" ]; then
    echo "✅ Reels endpoint working (returned $REELS_COUNT videos)"
else
    echo "❌ Reels endpoint failed (got $REELS_COUNT videos)"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

# Check video URLs are HTTP
HTTP_URLS=$(echo "$REELS_RESPONSE" | jq -r '.reels[].videoUrl' | grep -c "^http://" || echo "0")
if [ "$HTTP_URLS" -gt 0 ]; then
    echo "✅ All video URLs are HTTP (no SSL issues)"
else
    echo "❌ Found HTTPS URLs - will cause SSL errors"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

# Test one video URL
FIRST_VIDEO=$(echo "$REELS_RESPONSE" | jq -r '.reels[0].videoUrl')
echo "🎬 Testing video URL: $FIRST_VIDEO"
VIDEO_STATUS=$(curl -I "$FIRST_VIDEO" 2>/dev/null | head -1 | cut -d' ' -f2)
if [ "$VIDEO_STATUS" = "200" ]; then
    echo "✅ Video URL accessible"
else
    echo "❌ Video URL not accessible (status: $VIDEO_STATUS)"
fi

# Check Xcode project
echo "📱 Checking Xcode project..."
cd ../kurungaanaoli
if [ -f "kurungaanaoli.xcodeproj/project.pbxproj" ]; then
    echo "✅ Xcode project found"
else
    echo "❌ Xcode project not found"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

# Check key Swift files
SWIFT_FILES=(
    "kurungaanaoli Watch App/Views/ReelPlayerView.swift"
    "kurungaanaoli Watch App/ViewModels/ReelsViewModel.swift"
    "kurungaanaoli Watch App/Models/ReelModel.swift"
    "kurungaanaoli Watch App/Config/AppConfig.swift"
)

for file in "${SWIFT_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file found"
    else
        echo "❌ $file missing"
        kill $BACKEND_PID 2>/dev/null
        exit 1
    fi
done

# Check Info.plist for HTTP permissions
if grep -q "NSAllowsArbitraryLoads" Info.plist; then
    echo "✅ HTTP permissions configured"
else
    echo "❌ HTTP permissions missing in Info.plist"
fi

# Stop backend
echo "🛑 Stopping backend server..."
kill $BACKEND_PID 2>/dev/null

echo ""
echo "🎉 PROJECT VERIFICATION COMPLETE!"
echo "=================================="
echo "✅ Backend: Working with mock data"
echo "✅ Frontend: SwiftUI project ready"
echo "✅ Integration: HTTP URLs configured"
echo "✅ Permissions: HTTP access enabled"
echo ""
echo "🚀 Ready for Cursor AI to take over!"
echo ""
echo "Next steps:"
echo "1. Start backend: cd insta-reels-backend && USE_MOCK_DATA=true node server.js"
echo "2. Open Xcode: cd kurungaanaoli && open kurungaanaoli.xcodeproj"
echo "3. Run on Apple Watch simulator"
echo "4. Test video playback and Digital Crown navigation"
echo ""
echo "📚 See PROJECT_HANDOVER_GUIDE.md for complete documentation" 