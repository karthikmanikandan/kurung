#!/bin/bash

echo "🎨 Testing kurung App Setup"
echo "=========================="

# Test 1: Check if logo file exists
echo "📸 Checking logo file..."
if [ -f "kurungaanaoli/kurungaanaoli Watch App/Assets.xcassets/KurungLogo.imageset/KurungLogo.png" ]; then
    echo "✅ Logo file found: KurungLogo.png"
    ls -la "kurungaanaoli/kurungaanaoli Watch App/Assets.xcassets/KurungLogo.imageset/KurungLogo.png"
else
    echo "❌ Logo file not found!"
fi

# Test 2: Check backend
echo ""
echo "🌐 Testing backend..."
curl -s "http://localhost:3000/health" | jq '.' 2>/dev/null || echo "Backend not responding"

# Test 3: Check API
echo ""
echo "📡 Testing API..."
curl -s "http://localhost:3000/reels?limit=3" | jq '.reels | length' 2>/dev/null || echo "API not responding"

echo ""
echo "🎯 Next Steps:"
echo "1. Open Xcode: kurungaanaoli.xcodeproj"
echo "2. Clean Build Folder: Product → Clean Build Folder"
echo "3. Build and Run: Product → Build"
echo "4. Check splash screen - should show your golden logo with 'kurung' text"
echo ""
echo "🎉 Your custom logo is now ready!" 