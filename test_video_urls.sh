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

echo ""
echo "�� Testing Video URLs for Watch Simulator"
echo "=========================================="

# Test URLs
VIDEO_URLS=(
    "https://www.w3schools.com/html/mov_bbb.mp4"
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4"
    "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"
    "https://file-examples.com/storage/fe68c0e8c0c7a3b0193bf57/2017/10/file_example_MP4_480_1_5MG.mp4"
)

for url in "${VIDEO_URLS[@]}"; do
    echo "Testing: $url"
    if curl -I -s "$url" | head -1 | grep -q "200\|206"; then
        echo "✅ Working"
    else
        echo "❌ Failed"
    fi
    echo "---"
done 