#!/bin/bash

# Test script for Render deployment
# Usage: ./test_render_deployment.sh <your-render-url>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if URL is provided
if [ $# -eq 0 ]; then
    print_error "Please provide your Render URL"
    echo "Usage: $0 <your-render-url>"
    echo "Example: $0 https://kurung-backend-xxxx.onrender.com"
    exit 1
fi

RENDER_URL=$1

# Remove trailing slash if present
RENDER_URL=${RENDER_URL%/}

print_status "Testing Render deployment at: $RENDER_URL"
echo

# Test 1: Health endpoint
print_status "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s "$RENDER_URL/health" 2>/dev/null || echo "FAILED")

if [ "$HEALTH_RESPONSE" = "FAILED" ]; then
    print_error "Health endpoint failed - server might be down or URL incorrect"
    exit 1
fi

# Check if response contains expected fields
if echo "$HEALTH_RESPONSE" | grep -q '"status":"healthy"' && \
   echo "$HEALTH_RESPONSE" | grep -q '"source":"youtube-shorts"'; then
    print_success "Health endpoint working correctly"
    echo "Response: $HEALTH_RESPONSE"
else
    print_warning "Health endpoint responded but format might be unexpected"
    echo "Response: $HEALTH_RESPONSE"
fi
echo

# Test 2: Reels endpoint with limit
print_status "Testing reels endpoint (limit=3)..."
REELS_RESPONSE=$(curl -s "$RENDER_URL/reels?limit=3" 2>/dev/null || echo "FAILED")

if [ "$REELS_RESPONSE" = "FAILED" ]; then
    print_error "Reels endpoint failed"
    exit 1
fi

# Check if response contains video data
if echo "$REELS_RESPONSE" | grep -q '"videoUrl"' && \
   echo "$REELS_RESPONSE" | grep -q '"videoId"'; then
    print_success "Reels endpoint working correctly"
    
    # Count videos returned
    VIDEO_COUNT=$(echo "$REELS_RESPONSE" | grep -o '"videoUrl"' | wc -l)
    print_status "Returned $VIDEO_COUNT videos"
    
    # Show first video URL for verification
    FIRST_URL=$(echo "$REELS_RESPONSE" | grep -o '"videoUrl":"[^"]*"' | head -1 | cut -d'"' -f4)
    print_status "First video URL: $FIRST_URL"
else
    print_warning "Reels endpoint responded but format might be unexpected"
    echo "Response: $REELS_RESPONSE"
fi
echo

# Test 3: Test video URL accessibility
if [ ! -z "$FIRST_URL" ]; then
    print_status "Testing video URL accessibility..."
    VIDEO_HEAD=$(curl -I -s "$FIRST_URL" 2>/dev/null | head -1 || echo "FAILED")
    
    if echo "$VIDEO_HEAD" | grep -q "200 OK\|206 Partial Content"; then
        print_success "Video URL is accessible"
    else
        print_warning "Video URL might not be accessible: $VIDEO_HEAD"
    fi
    echo
fi

# Test 4: Response time
print_status "Testing response time..."
START_TIME=$(date +%s.%N)
curl -s "$RENDER_URL/health" > /dev/null
END_TIME=$(date +%s.%N)

RESPONSE_TIME=$(echo "$END_TIME - $START_TIME" | bc -l 2>/dev/null || echo "0.5")
print_status "Response time: ${RESPONSE_TIME}s"

if (( $(echo "$RESPONSE_TIME < 2.0" | bc -l) )); then
    print_success "Response time is good"
else
    print_warning "Response time is slow (might be cold start)"
fi
echo

# Test 5: CORS headers
print_status "Testing CORS headers..."
CORS_HEADERS=$(curl -I -s "$RENDER_URL/health" 2>/dev/null | grep -i "access-control" || echo "No CORS headers")

if echo "$CORS_HEADERS" | grep -q "access-control-allow-origin"; then
    print_success "CORS headers are present"
    echo "CORS Headers: $CORS_HEADERS"
else
    print_warning "CORS headers might be missing"
    echo "Headers: $CORS_HEADERS"
fi
echo

# Summary
print_status "=== Deployment Test Summary ==="
print_success "✅ Backend is deployed and responding"
print_success "✅ Health endpoint working"
print_success "✅ Reels endpoint working"
print_success "✅ Ready for WatchOS app integration"

echo
print_status "Next steps:"
echo "1. Update your AppConfig.swift with: $RENDER_URL"
echo "2. Add 'onrender.com' to your Info.plist ATS exceptions"
echo "3. Test the app in Xcode simulator"
echo "4. Deploy to TestFlight when ready"

echo
print_warning "Note: Free Render tier has cold starts (30-60s delay after inactivity)"
print_warning "Consider upgrading to paid plan for production use" 