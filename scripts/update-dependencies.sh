#!/usr/bin/env bash

# Update Flutter dependencies and check for issues
# This script updates dependencies and runs comprehensive checks

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

log_info "Starting dependency update process..."

# Check if in git repository
if [ ! -d .git ]; then
    log_error "Not in a git repository. Please run this from the project root."
    exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    log_warning "Working directory has uncommitted changes:"
    git status --short
    echo
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Store current pubspec.lock for comparison
cp pubspec.lock pubspec.lock.backup

log_info "Updating Flutter SDK..."
flutter upgrade

log_info "Getting current dependencies..."
flutter pub get

log_info "Checking for outdated dependencies..."
flutter pub outdated

echo
read -p "Do you want to update dependencies? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Skipping dependency updates"
    rm pubspec.lock.backup
    exit 0
fi

log_info "Updating dependencies..."
flutter pub upgrade

log_info "Generating localization files..."
flutter gen-l10n

log_info "Running tests to check for breaking changes..."
if flutter test; then
    log_success "All tests passed!"
else
    log_error "Tests failed! Dependency update may have introduced breaking changes."
    echo
    read -p "Revert dependencies? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Reverting dependencies..."
        mv pubspec.lock.backup pubspec.lock
        flutter pub get
        flutter gen-l10n
        log_info "Dependencies reverted to previous state"
        exit 1
    fi
fi

log_info "Running static analysis..."
if flutter analyze; then
    log_success "No analysis issues found!"
else
    log_warning "Analysis issues found. Please review and fix them."
fi

log_info "Building app to check for build issues..."
if flutter build apk --debug; then
    log_success "Debug build successful!"
else
    log_error "Debug build failed! Please fix build issues."
fi

# Show what changed
echo
log_info "Dependency changes:"
if command -v diff &> /dev/null; then
    diff pubspec.lock.backup pubspec.lock || true
else
    echo "diff command not available, showing git diff instead:"
    git diff pubspec.lock || true
fi

# Clean up
rm pubspec.lock.backup

echo
log_success "Dependency update completed!"
log_info "Next steps:"
echo "  1. Review any analysis warnings above"
echo "  2. Test the app manually"
echo "  3. Commit the changes if everything looks good:"
echo "     git add pubspec.lock"
echo "     git commit -m 'deps: Update Flutter dependencies'"
