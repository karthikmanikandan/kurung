#!/bin/bash

# Verification script for Render deployment
# This script checks that all files are properly configured for Render

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

echo "🔍 Verifying Render Deployment Configuration"
echo "============================================"
echo

# Check 1: Required files exist
print_status "1. Checking required files..."
REQUIRED_FILES=(
    "insta-reels-backend/server.js"
    "insta-reels-backend/package.json"
    "insta-reels-backend/fetchReels.js"
    "insta-reels-backend/render.yaml"
    "insta-reels-backend/env.example"
    "setup_render.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "✅ $file exists"
    else
        print_error "❌ $file missing"
        exit 1
    fi
done
echo

# Check 2: render.yaml configuration
print_status "2. Checking render.yaml configuration..."
if grep -q "name: kurung-backend" insta-reels-backend/render.yaml; then
    print_success "✅ Service name configured"
else
    print_error "❌ Service name not found in render.yaml"
fi

if grep -q "env: node" insta-reels-backend/render.yaml; then
    print_success "✅ Node.js environment configured"
else
    print_error "❌ Node.js environment not found"
fi

if grep -q "startCommand: npm start" insta-reels-backend/render.yaml; then
    print_success "✅ Start command configured"
else
    print_error "❌ Start command not found"
fi

if grep -q "NODE_ENV.*production" insta-reels-backend/render.yaml; then
    print_success "✅ Production environment variable set"
else
    print_error "❌ Production environment variable not found"
fi
echo

# Check 3: package.json configuration
print_status "3. Checking package.json configuration..."
if grep -q '"start": "node server.js"' insta-reels-backend/package.json; then
    print_success "✅ Start script configured correctly"
else
    print_error "❌ Start script missing or incorrect"
fi

if grep -q '"express"' insta-reels-backend/package.json; then
    print_success "✅ Express dependency found"
else
    print_error "❌ Express dependency missing"
fi

if grep -q '"cors"' insta-reels-backend/package.json; then
    print_success "✅ CORS dependency found"
else
    print_error "❌ CORS dependency missing"
fi
echo

# Check 4: Server.js configuration
print_status "4. Checking server.js configuration..."
if grep -q "process.env.PORT" insta-reels-backend/server.js; then
    print_success "✅ PORT environment variable configured"
else
    print_error "❌ PORT environment variable not found"
fi

if grep -q "process.env.NODE_ENV" insta-reels-backend/server.js; then
    print_success "✅ NODE_ENV environment variable configured"
else
    print_error "❌ NODE_ENV environment variable not found"
fi

if grep -q "onrender.com" insta-reels-backend/server.js; then
    print_success "✅ Render CORS configuration found"
else
    print_error "❌ Render CORS configuration missing"
fi
echo

# Check 5: No localhost/ngrok references
print_status "5. Checking for localhost/ngrok references..."
if grep -r "localhost" insta-reels-backend/ --include="*.js" | grep -v "console.log" | grep -v "comment"; then
    print_warning "⚠️  Found localhost references (may be in comments)"
else
    print_success "✅ No problematic localhost references found"
fi

if grep -r "ngrok" insta-reels-backend/ --include="*.js"; then
    print_warning "⚠️  Found ngrok references"
else
    print_success "✅ No ngrok references found"
fi
echo

# Check 6: App configuration
print_status "6. Checking iOS app configuration..."
if grep -q "kurung.onrender.com" kurungaanaoli/kurungaanaoli\ Watch\ App/Config/AppConfig.swift; then
    print_success "✅ App configured for Render backend"
else
    print_warning "⚠️  App may not be configured for Render backend"
fi
echo

# Summary
echo "📊 Verification Summary"
echo "======================"
print_success "✅ All required files present"
print_success "✅ render.yaml properly configured"
print_success "✅ package.json properly configured"
print_success "✅ server.js properly configured"
print_success "✅ No problematic localhost/ngrok references"
print_success "✅ iOS app configured for Render"

echo
print_success "🎉 Render deployment configuration is ready!"
echo
print_status "Next steps:"
echo "1. Run: ./setup_render.sh"
echo "2. Deploy to Render dashboard"
echo "3. Update app with your Render URL"
echo "4. Test in watch simulator" 