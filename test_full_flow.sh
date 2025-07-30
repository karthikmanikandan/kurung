#!/bin/bash

echo "🧪 Testing Full Instagram Reels App Flow"
echo "========================================"

# Test 1: Backend Health
echo "1. Testing Backend Health..."
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ Backend is running"
else
    echo "❌ Backend is not running"
    exit 1
fi

# Test 2: Backend Reels Endpoint
echo "2. Testing Backend Reels Endpoint..."
REELS_RESPONSE=$(curl -s http://localhost:3000/reels)
if echo "$REELS_RESPONSE" | grep -q '"success":true'; then
    REEL_COUNT=$(echo "$REELS_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('count', 0))")
    echo "✅ Backend reels endpoint working (count: $REEL_COUNT)"
else
    echo "❌ Backend reels endpoint failed"
    echo "Response: $REELS_RESPONSE"
    exit 1
fi

# Test 3: Ngrok Tunnel
echo "3. Testing Ngrok Tunnel..."
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
    echo "✅ Ngrok tunnel found: $NGROK_URL"
else
    echo "❌ Ngrok tunnel not found"
    exit 1
fi

# Test 4: Ngrok Health
echo "4. Testing Ngrok Health Endpoint..."
if curl -s "$NGROK_URL/health" > /dev/null; then
    echo "✅ Ngrok health endpoint working"
else
    echo "❌ Ngrok health endpoint failed"
    exit 1
fi

# Test 5: Ngrok Reels Endpoint
echo "5. Testing Ngrok Reels Endpoint..."
if curl -s "$NGROK_URL/reels" | grep -q '"success":true'; then
    echo "✅ Ngrok reels endpoint working"
else
    echo "❌ Ngrok reels endpoint failed"
    exit 1
fi

# Test 6: AppConfig URL
echo "6. Testing AppConfig URL..."
CONFIG_URL=$(grep -o 'static let baseURL = "[^"]*"' "kurungaanaoli/kurungaanaoli Watch App/Config/AppConfig.swift" | cut -d'"' -f2)
if [ "$CONFIG_URL" = "$NGROK_URL" ]; then
    echo "✅ AppConfig URL matches ngrok URL"
else
    echo "⚠️  AppConfig URL ($CONFIG_URL) doesn't match ngrok URL ($NGROK_URL)"
    echo "   Run: cd kurungaanaoli && ./update_ngrok_url.sh"
fi

# Test 7: Swift Syntax Check
echo "7. Testing Swift Syntax..."
cd kurungaanaoli
if xcodebuild -project kurungaanaoli.xcodeproj -scheme "kurungaanaoli Watch App" -destination "platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)" build > /dev/null 2>&1; then
    echo "✅ Swift code compiles successfully"
else
    echo "❌ Swift code has compilation errors"
    echo "   Run: xcodebuild -project kurungaanaoli.xcodeproj -scheme 'kurungaanaoli Watch App' build"
fi

echo ""
echo "🎉 All tests completed!"
echo ""
echo "📱 Next steps:"
echo "1. Open kurungaanaoli.xcodeproj in Xcode"
echo "2. Select 'kurungaanaoli Watch App' scheme"
echo "3. Choose Apple Watch Simulator"
echo "4. Build and run (⌘+R)"
echo ""
echo "🔧 If you need to update the ngrok URL:"
echo "   cd kurungaanaoli && ./update_ngrok_url.sh" 