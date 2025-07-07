#!/bin/bash

# Master Release Script - The Ultimate Easy Release Tool
# This script guides you through the entire release process step by step

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_header() {
    echo
    echo -e "${PURPLE}$1${NC}"
    echo "$(echo "$1" | sed 's/./=/g')"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

log_header "🚀 Just Cards - Master Release Tool"

log_info "This tool will guide you through the complete release process."
echo

# Step 1: Show current status
log_header "📊 Step 1: Current Status"
./scripts/build-info.sh

# Step 2: Pre-release checklist
echo
read -p "Do you want to run the interactive checklist? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    log_header "📋 Step 2: Pre-Release Checklist"
    ./scripts/release-checklist.sh
fi

# Step 3: Choose release type
log_header "🎯 Step 3: Choose Release Type"
echo "What type of release do you want to create?"
echo "1) Quick Patch Release (recommended for bug fixes)"
echo "2) Minor Release (new features, backward compatible)"
echo "3) Major Release (breaking changes)"
echo "4) Custom Version"
echo "5) Just run pre-checks (no release)"
echo

read -p "Enter your choice (1-5): " -n 1 -r
echo
echo

case $REPLY in
    1)
        RELEASE_TYPE="patch"
        log_info "Creating patch release..."
        ;;
    2)
        RELEASE_TYPE="minor"
        log_info "Creating minor release..."
        ;;
    3)
        RELEASE_TYPE="major"
        log_info "Creating major release..."
        ;;
    4)
        read -p "Enter custom version (e.g., 1.2.3): " CUSTOM_VERSION
        RELEASE_TYPE="$CUSTOM_VERSION"
        log_info "Creating custom release: $CUSTOM_VERSION"
        ;;
    5)
        log_header "🔍 Step 4: Running Pre-Checks Only"
        ./scripts/pre-release-check.sh
        log_success "Pre-checks complete! Run this script again when ready to release."
        exit 0
        ;;
    *)
        log_warning "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Step 4: Generate release notes
log_header "📝 Step 4: Generating Release Notes"
log_info "Creating user-friendly release notes from git commits..."
./scripts/smart-release-notes.sh
echo

# Step 5: Run the release
log_header "🏗️ Step 5: Building Release"
./scripts/release.sh "$RELEASE_TYPE"

# Step 6: Post-release instructions
log_header "📤 Step 6: Upload to Google Play Store"
echo
log_success "🎉 Release completed successfully!"
echo
log_info "Next steps to publish:"
echo "1. 📱 Go to Google Play Console: https://play.google.com/console"
echo "2. 🎯 Select your app: Cards"
echo "3. 📦 Go to Release → Production"
echo "4. ➕ Create new release"
echo "5. 📤 Upload AAB file: $(pwd)/build/app/outputs/bundle/release/app-release.aab"
echo "6. 📝 Add release notes (use template: scripts/release-notes-template.md)"
echo "7. 👀 Review and publish"
echo

AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
    AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    log_info "AAB file ready: $AAB_SIZE"
fi

# Optional: Open Play Console
echo
read -p "Open Google Play Console in browser? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v open >/dev/null 2>&1; then
        open "https://play.google.com/console"
        log_success "Opening Google Play Console..."
    else
        log_info "Please manually open: https://play.google.com/console"
    fi
fi

echo
log_success "🎊 Happy releasing! Your app is ready for the world!"
