#!/bin/bash

# Deploy to Render script
# This script helps deploy the backend to Render with proper configuration

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

print_status "🚀 Preparing to deploy to Render..."
echo

# Check if we're in the right directory
if [ ! -f "insta-reels-backend/package.json" ]; then
    print_error "Please run this script from the kurung project root directory"
    exit 1
fi

# Check git status
print_status "Checking git status..."
if [ -d ".git" ]; then
    if git status --porcelain | grep -q .; then
        print_warning "⚠️  You have uncommitted changes"
        git status --short
        echo
        read -p "Do you want to commit changes before deployment? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Committing changes..."
            git add .
            git commit -m "Update backend configuration for Render deployment"
            print_success "✅ Changes committed"
        fi
    else
        print_success "✅ Working directory is clean"
    fi
else
    print_error "❌ Not a git repository. Please initialize git first."
    exit 1
fi

echo

# Check if remote repository is configured
print_status "Checking remote repository..."
if git remote -v | grep -q origin; then
    print_success "✅ Remote repository configured"
    git remote -v
else
    print_error "❌ No remote repository configured"
    echo "Please add your GitHub repository as origin:"
    echo "git remote add origin https://github.com/yourusername/your-repo.git"
    exit 1
fi

echo

# Push to GitHub
print_status "Pushing to GitHub..."
if git push origin main; then
    print_success "✅ Code pushed to GitHub"
else
    print_error "❌ Failed to push to GitHub"
    echo "Please check your GitHub credentials and repository access"
    exit 1
fi

echo

print_status "=== Render Deployment Instructions ==="
echo
print_status "1. Go to https://render.com and sign in"
print_status "2. Navigate to your 'kurung-backend' service"
print_status "3. Go to 'Environment' tab"
print_status "4. Set USE_MOCK_DATA to 'true'"
print_status "5. Click 'Save Changes'"
print_status "6. Go to 'Manual Deploy' tab"
print_status "7. Click 'Deploy latest commit'"
echo
print_warning "Note: Render will automatically redeploy when you push to GitHub"
print_warning "The deployment may take 2-5 minutes to complete"
echo
print_status "After deployment, test the backend:"
echo "curl https://kurung.onrender.com/health"
echo "curl https://kurung.onrender.com/reels?limit=3"
echo
print_success "🎉 Deployment process initiated!" 