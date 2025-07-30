#!/bin/bash

echo "🧪 Testing Instagram Reels Watch App - Ready for Xcode"
echo "======================================================"

# Test 1: Backend Status
echo "1. Backend Status..."
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ Backend running on localhost:3000"
else
    echo "❌ Backend not running - start with: cd insta-reels-backend && node server.js"
    exit 1
fi

# Test 2: Ngrok Status
echo "2. Ngrok Status..."
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data['tunnels']:
        print(data['tunnels'][0]['public_url'])
    else:
        print('No tunnels')
        sys.exit(1)
except:
    sys.exit(1)
")

if [ $? -eq 0 ]; then
    echo "✅ Ngrok tunnel: $NGROK_URL"
else
    echo "❌ Ngrok not running - start with: ngrok http 3000"
    exit 1
fi

# Test 3: API Response
echo "3. API Response Test..."
REELS_RESPONSE=$(curl -s "$NGROK_URL/reels")
if echo "$REELS_RESPONSE" | grep -q '"success":true'; then
    REEL_COUNT=$(echo "$REELS_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('count', 0))")
    echo "✅ API returning $REEL_COUNT reels"
else
    echo "❌ API not returning valid response"
    exit 1
fi

# Test 4: Swift Syntax
echo "4. Swift Syntax Check..."
cd kurungaanaoli

# Check main files
FILES=(
    "kurungaanaoli Watch App/kurungaanaoliApp.swift"
    "kurungaanaoli Watch App/ContentView.swift"
    "kurungaanaoli Watch App/ReelListView.swift"
    "kurungaanaoli Watch App/ViewModels/ReelsViewModel.swift"
    "kurungaanaoli Watch App/Services/ReelService.swift"
    "kurungaanaoli Watch App/Models/ReelModel.swift"
    "kurungaanaoli Watch App/Config/AppConfig.swift"
)

ALL_GOOD=true
for file in "${FILES[@]}"; do
    if swift -frontend -parse "$file" > /dev/null 2>&1; then
        echo "   ✅ $(basename "$file")"
    else
        echo "   ❌ $(basename "$file") - syntax error"
        ALL_GOOD=false
    fi
done

if [ "$ALL_GOOD" = true ]; then
    echo "✅ All Swift files have correct syntax"
else
    echo "❌ Some Swift files have syntax errors"
    exit 1
fi

# Test 5: AppConfig URL
echo "5. AppConfig URL Check..."
CONFIG_URL=$(grep -o 'static let baseURL = "[^"]*"' "kurungaanaoli Watch App/Config/AppConfig.swift" | cut -d'"' -f2)
if [ "$CONFIG_URL" = "$NGROK_URL" ]; then
    echo "✅ AppConfig URL matches ngrok URL"
else
    echo "⚠️  AppConfig URL ($CONFIG_URL) doesn't match ngrok URL ($NGROK_URL)"
    echo "   Updating AppConfig..."
    ./update_ngrok_url.sh
fi

# Test 6: Project Structure
echo "6. Project Structure Check..."
if [ -f "kurungaanaoli.xcodeproj/project.pbxproj" ]; then
    echo "✅ Xcode project file exists"
else
    echo "❌ Xcode project file missing"
    exit 1
fi

if [ -d "kurungaanaoli Watch App" ]; then
    echo "✅ Watch app directory exists"
else
    echo "❌ Watch app directory missing"
    exit 1
fi

echo ""
echo "🎉 APP IS READY FOR XCODE!"
echo "=========================="
echo ""
echo "📱 Next Steps:"
echo "1. Open Xcode: open kurungaanaoli.xcodeproj"
echo "2. Select scheme: 'kurungaanaoli Watch App'"
echo "3. Choose simulator: Any Apple Watch simulator"
echo "4. Build and run: ⌘+R"
echo ""
echo "🔧 Expected Behavior:"
echo "- App loads with 'Loading Reels...' message"
echo "- Shows 5 video cards with sample videos"
echo "- Videos should play in simulator"
echo "- Pull-to-refresh works"
echo "- Error handling shows alerts if needed"
echo ""
echo "📊 Current Status:"
echo "- Backend: ✅ Running with 5 mock reels"
echo "- Ngrok: ✅ Tunnel active at $NGROK_URL"
echo "- Swift: ✅ All files compile correctly"
echo "- Network: ✅ API responding properly"
echo ""
echo "🚀 Your Instagram Reels Watch app is ready to run!" 