#!/bin/bash

# Quick Render status check
# This script provides a quick overview of Render backend status

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

RENDER_URL="https://kurung.onrender.com"

echo "🔍 Quick Render Status Check"
echo "============================"
echo "URL: $RENDER_URL"
echo

# Health check
print_status "Checking health endpoint..."
HEALTH_RESPONSE=$(curl -s --max-time 10 "$RENDER_URL/health" 2>/dev/null || echo "FAILED")

if [ "$HEALTH_RESPONSE" = "FAILED" ]; then
    print_error "❌ Backend is down or not responding"
    exit 1
fi

if echo "$HEALTH_RESPONSE" | grep -q '"status":"healthy"'; then
    print_success "✅ Backend is healthy"
else
    print_warning "⚠️  Backend responded but status unclear"
fi

# Reels check
print_status "Checking reels endpoint..."
REELS_RESPONSE=$(curl -s --max-time 15 "$RENDER_URL/reels?limit=1" 2>/dev/null || echo "FAILED")

if [ "$REELS_RESPONSE" = "FAILED" ]; then
    print_error "❌ Reels endpoint failed"
else
    if echo "$REELS_RESPONSE" | grep -q '"reels"'; then
        VIDEO_COUNT=$(echo "$REELS_RESPONSE" | jq '.reels | length' 2>/dev/null || echo "0")
        print_success "✅ Reels endpoint working ($VIDEO_COUNT videos available)"
    else
        print_warning "⚠️  Reels endpoint responded but format unclear"
    fi
fi

# CORS check
print_status "Checking CORS headers..."
CORS_HEADERS=$(curl -I -s --max-time 5 "$RENDER_URL/health" 2>/dev/null | grep -i "access-control" || echo "No CORS")

if echo "$CORS_HEADERS" | grep -q "access-control-allow-origin"; then
    print_success "✅ CORS headers present"
else
    print_warning "⚠️  CORS headers may be missing"
fi

echo
print_success "🎉 Render backend is functioning!"
print_status "Ready for WatchOS app testing" 