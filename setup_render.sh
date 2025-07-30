#!/bin/bash

# Setup script for Render deployment
# This script prepares your repository for deployment to Render

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

print_status "🚀 Setting up kurung backend for Render deployment..."
echo

# Check if we're in the right directory
if [ ! -f "insta-reels-backend/package.json" ]; then
    print_error "Please run this script from the kurung project root directory"
    exit 1
fi

# Check if required files exist
print_status "Checking required files..."

REQUIRED_FILES=(
    "insta-reels-backend/server.js"
    "insta-reels-backend/package.json"
    "insta-reels-backend/fetchReels.js"
    "render.yaml"
    "env.example"
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

# Check package.json scripts
print_status "Checking package.json configuration..."
if grep -q '"start": "node server.js"' insta-reels-backend/package.json; then
    print_success "✅ Start script configured correctly"
else
    print_error "❌ Start script missing or incorrect in package.json"
    exit 1
fi

# Check if node_modules exists and suggest cleanup
if [ -d "insta-reels-backend/node_modules" ]; then
    print_warning "⚠️  node_modules directory found"
    read -p "Do you want to remove node_modules? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Removing node_modules..."
        rm -rf insta-reels-backend/node_modules
        print_success "✅ node_modules removed"
    fi
fi

echo

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
            git commit -m "Prepare for Render deployment"
            print_success "✅ Changes committed"
        fi
    else
        print_success "✅ Working directory is clean"
    fi
else
    print_warning "⚠️  Not a git repository"
    read -p "Do you want to initialize git repository? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Initializing git repository..."
        git init
        git add .
        git commit -m "Initial commit for Render deployment"
        print_success "✅ Git repository initialized"
    fi
fi

echo

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    print_status "Creating .gitignore..."
    cat > .gitignore << EOF
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# nyc test coverage
.nyc_output

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Xcode
*.xcworkspace
xcuserdata/
*.xcuserstate
*.xcuserdatad/
*.xcscmblueprint
*.xccheckout
build/
DerivedData/
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# WatchOS specific
*.app
*.ipa
*.dSYM.zip
*.dSYM 