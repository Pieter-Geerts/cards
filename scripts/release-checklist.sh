#!/bin/bash

# Interactive Release Checklist
# Helps ensure you don't forget important steps

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📋 Flutter App Release Checklist${NC}"
echo "================================="
echo

checklist_item() {
    local item="$1"
    echo -n "✓ $item "
    read -p "(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⚠️  Please complete this step before continuing${NC}"
        return 1
    fi
    return 0
}

echo -e "${BLUE}Pre-Release Preparation:${NC}"
checklist_item "Code is complete and tested locally" || exit 1
checklist_item "All unit tests pass (flutter test)" || exit 1
checklist_item "App has been tested on physical device" || exit 1
checklist_item "No debug code or TODO comments in critical paths" || exit 1
checklist_item "Release notes are prepared" || exit 1
echo

echo -e "${BLUE}Technical Setup:${NC}"
checklist_item "Android signing is configured (key.properties exists)" || exit 1
checklist_item "secrets.dart file is properly configured" || exit 1
checklist_item "App permissions are correctly set" || exit 1
checklist_item "App icons are updated (if changed)" || exit 1
echo

echo -e "${BLUE}Version Management:${NC}"
echo "Current version: $(grep '^version:' pubspec.yaml | sed 's/version: //')"
checklist_item "Version number is appropriate for changes" || exit 1
checklist_item "Version follows semantic versioning (major.minor.patch)" || exit 1
echo

echo -e "${BLUE}Google Play Store:${NC}"
checklist_item "Google Play Console access is available" || exit 1
checklist_item "App listing information is up to date" || exit 1
checklist_item "Screenshots are current (if app UI changed)" || exit 1
checklist_item "Privacy policy is updated (if needed)" || exit 1
echo

echo -e "${BLUE}Final Checks:${NC}"
checklist_item "Working directory is clean (git status)" || exit 1
checklist_item "Ready to proceed with release" || exit 1

echo
echo -e "${GREEN}🎉 All checks passed! Ready to release!${NC}"
echo
echo "Next steps:"
echo "1. Run: ./scripts/quick-release.sh"
echo "2. Or run: ./scripts/release.sh [patch|minor|major]"
echo "3. Upload AAB to Google Play Console"
echo "4. Add release notes in Play Console"
echo "5. Publish when ready"
echo
