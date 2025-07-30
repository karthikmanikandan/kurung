#!/bin/bash

echo "🔍 Testing video URLs accessibility..."

# Test backend API
echo "📡 Testing backend API..."
curl -s "http://192.168.1.2:3000/reels?limit=3" | jq '.reels[0:2] | .[] | .videoUrl'

echo ""
echo "🎬 Testing direct video URL access..."

# Test a sample video URL
VIDEO_URL="http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
echo "Testing: $VIDEO_URL"

# Check if URL is accessible
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$VIDEO_URL")
echo "HTTP Status Code: $HTTP_CODE"

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✅ Video URL is accessible"
else
    echo "❌ Video URL returned status: $HTTP_CODE"
fi

echo ""
echo "🔒 Testing ATS compatibility..."
# Test with curl to simulate what AVPlayer might see
curl -s -I "$VIDEO_URL" | head -5 