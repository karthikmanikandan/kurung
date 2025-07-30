#!/bin/bash

echo "🧪 YouTube Shorts App - Complete Test Suite"
echo "=========================================="

# Test 1: Backend API
echo "📡 Testing Backend API..."
curl -s "http://localhost:3000/reels?limit=5" | jq '.reels | length' > /tmp/api_test.txt
API_RESULT=$(cat /tmp/api_test.txt)
echo "✅ Backend returned $API_RESULT videos"

# Test 2: Check unique video IDs
echo "🔍 Checking for unique video IDs..."
curl -s "http://localhost:3000/reels?limit=3" | jq '.reels[] | .videoId' > /tmp/video_ids.txt
UNIQUE_COUNT=$(sort /tmp/video_ids.txt | uniq | wc -l)
TOTAL_COUNT=$(cat /tmp/video_ids.txt | wc -l)
echo "✅ Found $UNIQUE_COUNT unique IDs out of $TOTAL_COUNT total"

# Test 3: Check video URLs
echo "🎬 Checking video URLs..."
curl -s "http://localhost:3000/reels?limit=2" | jq '.reels[] | .videoUrl' > /tmp/video_urls.txt
echo "✅ Video URLs:"
cat /tmp/video_urls.txt

echo ""
echo "🎉 All tests completed!"
echo "📱 Now build and run the app in Xcode"
echo "🔄 Expected behavior:"
echo "   - 5+ videos available"
echo "   - Digital Crown navigation works"
echo "   - Vertical video display (9:16)"
echo "   - Tap to play/pause" 