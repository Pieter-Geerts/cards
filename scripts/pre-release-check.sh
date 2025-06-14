#!/bin/bash

# Pre-release checks to ensure app quality
# Run this before releasing to catch issues early

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

log_info "Running pre-release checks..."

# Check git status
log_info "Checking git status..."
if [ -n "$(git status --porcelain)" ]; then
    log_warning "Working directory has uncommitted changes:"
    git status --short
    echo
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    log_success "Working directory is clean"
fi

# Check Flutter version
log_info "Checking Flutter version..."
FLUTTER_VERSION=$(flutter --version --machine | grep -o '"flutterVersion":"[^"]*"' | cut -d'"' -f4)
log_success "Flutter version: $FLUTTER_VERSION"

# Get dependencies
log_info "Getting dependencies..."
flutter pub get
log_success "Dependencies updated"

# Run tests
log_info "Running tests..."
TEST_RESULT=$(flutter test 2>&1)
if [ $? -eq 0 ]; then
    TEST_COUNT=$(echo "$TEST_RESULT" | grep -o '[0-9]\+ tests passed' | grep -o '[0-9]\+' || echo "0")
    log_success "All $TEST_COUNT tests passed"
else
    log_error "Tests failed!"
    echo "$TEST_RESULT"
    exit 1
fi

# Run static analysis
log_info "Running static analysis..."
flutter analyze
log_success "Static analysis passed"

# Check for secrets file
if [ ! -f "lib/secrets.dart" ]; then
    log_warning "secrets.dart not found. Make sure to create it from secrets_template.dart"
fi

# Check Android signing
log_info "Checking Android signing configuration..."
if [ -f "android/key.properties" ]; then
    log_success "Android signing configured"
else
    log_warning "android/key.properties not found. Make sure signing is configured for release builds"
fi

# Check app bundle can be built
log_info "Testing app bundle build..."
flutter build appbundle --release --dry-run
log_success "App bundle build test passed"

# Check version format
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
if [[ "$CURRENT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
    log_success "Version format is correct: $CURRENT_VERSION"
else
    log_error "Version format is incorrect: $CURRENT_VERSION (should be X.Y.Z+BUILD)"
    exit 1
fi

# Check app size (build a debug APK to estimate)
log_info "Checking app size..."
flutter build apk --debug > /dev/null 2>&1
DEBUG_APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-debug.apk | cut -f1)
log_success "Debug APK size: $DEBUG_APK_SIZE"

# Check for common issues
log_info "Checking for common issues..."

# Check for hardcoded strings that should be localized
HARDCODED_STRINGS=$(grep -r "Text('" lib/ --include="*.dart" | grep -v "// ignore:" | wc -l | tr -d ' ')
if [ "$HARDCODED_STRINGS" -gt 0 ]; then
    log_warning "Found $HARDCODED_STRINGS potential hardcoded strings (check if they should be localized)"
fi

# Check for TODO/FIXME comments
TODO_COUNT=$(grep -r "TODO\|FIXME" lib/ --include="*.dart" | wc -l | tr -d ' ')
if [ "$TODO_COUNT" -gt 0 ]; then
    log_warning "Found $TODO_COUNT TODO/FIXME comments"
fi

log_success "🎉 Pre-release checks completed!"
echo
log_info "Summary:"
echo "  • Flutter version: $FLUTTER_VERSION"
echo "  • Tests: $TEST_COUNT passed"
echo "  • Current version: $CURRENT_VERSION"
echo "  • Debug APK size: $DEBUG_APK_SIZE"
if [ "$HARDCODED_STRINGS" -gt 0 ]; then
    echo "  • Hardcoded strings: $HARDCODED_STRINGS (review needed)"
fi
if [ "$TODO_COUNT" -gt 0 ]; then
    echo "  • TODO/FIXME: $TODO_COUNT (review needed)"
fi
echo
log_info "Ready for release! Run ./scripts/release.sh to proceed."
