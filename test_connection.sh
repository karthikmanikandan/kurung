#!/bin/bash

echo "🔍 Testing Connection Issues..."

# Check if backend is running locally
echo "📡 Testing local backend..."
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ Local backend is running"
else
    echo "❌ Local backend is not running"
fi

# Check AppConfig.swift
echo "📱 Checking AppConfig.swift..."
if grep -q "localhost:3000" "kurungaanaoli/kurungaanaoli Watch App/Config/AppConfig.swift"; then
    echo "⚠️  AppConfig still points to localhost"
    echo "   Update it with your Render URL"
else
    echo "✅ AppConfig updated"
fi

# Check Info.plist for onrender.com
echo "🔒 Checking ATS exceptions..."
if grep -q "onrender.com" "kurungaanaoli/Info.plist"; then
    echo "✅ onrender.com added to ATS exceptions"
else
    echo "❌ onrender.com missing from ATS exceptions"
fi

echo ""
echo "🎯 Next steps:"
echo "1. Get your Render URL from render.com dashboard"
echo "2. Update AppConfig.swift with your Render URL"
echo "3. Run: ./test_render_deployment.sh YOUR_RENDER_URL"
echo "4. Build and test in Xcode" 