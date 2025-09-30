#!/usr/bin/env bash

# Build Information Script
# Shows current app information and build status

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo -e "${BLUE}📱 Cards App Build Information${NC}"
echo "================================="
echo

# App Information
echo -e "${BLUE}App Details:${NC}"
APP_NAME=$(grep '^name:' pubspec.yaml | sed 's/name: //')
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep '^version:' pubspec.yaml | sed 's/.*+//')
DESCRIPTION=$(grep '^description:' pubspec.yaml | sed 's/description: //' | sed 's/"//g')

echo "  Name: $APP_NAME"
echo "  Description: $DESCRIPTION"
echo "  Version: $CURRENT_VERSION"
echo "  Build Number: $CURRENT_BUILD"
echo "  Full Version: $CURRENT_VERSION+$CURRENT_BUILD"
echo

# Flutter Information
echo -e "${BLUE}Development Environment:${NC}"
FLUTTER_VERSION=$(flutter --version 2>/dev/null | head -1 | grep -o 'Flutter [0-9][^ ]*' | cut -d' ' -f2 || echo "Unknown")
DART_VERSION=$(flutter --version 2>/dev/null | grep -o 'Dart [0-9][^ ]*' | cut -d' ' -f2 || echo "Unknown")
echo "  Flutter: $FLUTTER_VERSION"
echo "  Dart: $DART_VERSION"
echo

# Git Information
echo -e "${BLUE}Git Status:${NC}"
if [ -d .git ]; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "Unknown")
    LAST_COMMIT=$(git log -1 --format="%h - %s" 2>/dev/null || echo "No commits")
    GIT_STATUS=$(git status --porcelain 2>/dev/null)
    
    echo "  Branch: $CURRENT_BRANCH"
    echo "  Last Commit: $LAST_COMMIT"
    
    if [ -z "$GIT_STATUS" ]; then
        echo -e "  Working Directory: ${GREEN}Clean${NC}"
    else
        echo -e "  Working Directory: ${YELLOW}Has uncommitted changes${NC}"
    fi
    
    # Show recent tags
    RECENT_TAGS=$(git tag -l --sort=-version:refname 2>/dev/null | head -3)
    if [ -n "$RECENT_TAGS" ]; then
        echo "  Recent Tags:"
        echo "$RECENT_TAGS" | sed 's/^/    /'
    fi
else
    echo "  Not a git repository"
fi
echo

# Build Status
echo -e "${BLUE}Build Status:${NC}"

# Check if AAB exists
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
    AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    AAB_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$AAB_PATH" 2>/dev/null || stat -c "%y" "$AAB_PATH" 2>/dev/null | cut -d' ' -f1,2 | cut -d':' -f1-2)
    echo -e "  AAB File: ${GREEN}Available${NC} ($AAB_SIZE, built $AAB_DATE)"
else
    echo -e "  AAB File: ${YELLOW}Not built${NC}"
fi

# Check if APK exists
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    APK_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$APK_PATH" 2>/dev/null || stat -c "%y" "$APK_PATH" 2>/dev/null | cut -d' ' -f1,2 | cut -d':' -f1-2)
    echo -e "  APK File: ${GREEN}Available${NC} ($APK_SIZE, built $APK_DATE)"
else
    echo -e "  APK File: ${YELLOW}Not built${NC}"
fi

# Check signing
if [ -f "android/key.properties" ]; then
    echo -e "  Android Signing: ${GREEN}Configured${NC}"
else
    echo -e "  Android Signing: ${YELLOW}Not configured${NC}"
fi

# Check secrets
if [ -f "lib/secrets.dart" ]; then
    echo -e "  Secrets File: ${GREEN}Available${NC}"
else
    echo -e "  Secrets File: ${YELLOW}Missing${NC}"
fi
echo

# Dependencies Status
echo -e "${BLUE}Dependencies:${NC}"
echo "  Checking for outdated packages..."
OUTDATED_OUTPUT=$(flutter pub outdated --json 2>/dev/null || echo '{"packages": []}')
OUTDATED_COUNT=$(echo "$OUTDATED_OUTPUT" | grep -o '"upgradable"' | wc -l | tr -d ' ')

if [ "$OUTDATED_COUNT" -gt 0 ]; then
    echo -e "  Status: ${YELLOW}$OUTDATED_COUNT packages can be updated${NC}"
    echo "  Run: ./scripts/update-dependencies.sh"
else
    echo -e "  Status: ${GREEN}All packages up to date${NC}"
fi

# Last dependency update
PUBSPEC_LOCK_DATE=""
if [ -f "pubspec.lock" ]; then
    PUBSPEC_LOCK_DATE=$(stat -f "%Sm" -t "%Y-%m-%d" "pubspec.lock" 2>/dev/null || stat -c "%y" "pubspec.lock" 2>/dev/null | cut -d' ' -f1)
    if [ -n "$PUBSPEC_LOCK_DATE" ]; then
        echo "  Last Updated: $PUBSPEC_LOCK_DATE"
    fi
fi
echo

# Quick Actions
echo -e "${BLUE}Quick Actions:${NC}"
echo "  • Update dependencies: ./scripts/update-dependencies.sh"
echo "  • Run pre-checks: ./scripts/pre-release-check.sh"
echo "  • Release checklist: ./scripts/release-checklist.sh"
echo "  • Quick patch release: ./scripts/quick-release.sh"
echo "  • Custom release: ./scripts/release.sh [patch|minor|major|X.Y.Z]"
echo "  • Build AAB only: flutter build appbundle --release"
echo "  • Run tests: flutter test"
echo
