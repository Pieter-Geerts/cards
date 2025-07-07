#!/bin/bash

# Flutter App Release Script
# Makes releasing to Google Play as easy as possible
# Usage: ./scripts/release.sh [version_type]
# version_type can be: patch, minor, major, or custom (e.g., 1.2.3)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
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

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

log_info "Starting Flutter app release process..."

# Check if we're in a git repository
if [ ! -d .git ]; then
    log_error "Not in a git repository. Please run this from the project root."
    exit 1
fi

# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    log_error "Working directory is not clean. Please commit or stash your changes."
    git status --short
    exit 1
fi

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep '^version:' pubspec.yaml | sed 's/.*+//')

log_info "Current version: $CURRENT_VERSION+$CURRENT_BUILD"

# Determine new version
VERSION_TYPE=${1:-patch}

if [[ "$VERSION_TYPE" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Custom version provided
    NEW_VERSION="$VERSION_TYPE"
else
    # Calculate new version based on type
    IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
    MAJOR=${VERSION_PARTS[0]}
    MINOR=${VERSION_PARTS[1]}
    PATCH=${VERSION_PARTS[2]}

    case $VERSION_TYPE in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        patch)
            PATCH=$((PATCH + 1))
            ;;
        *)
            log_error "Invalid version type: $VERSION_TYPE. Use: patch, minor, major, or custom version (e.g., 1.2.3)"
            exit 1
            ;;
    esac

    NEW_VERSION="$MAJOR.$MINOR.$PATCH"
fi

NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_VERSION_FULL="$NEW_VERSION+$NEW_BUILD"

log_info "New version will be: $NEW_VERSION_FULL"

# Confirm with user
echo
read -p "Do you want to proceed with release $NEW_VERSION_FULL? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warning "Release cancelled."
    exit 0
fi

log_info "Updating version in pubspec.yaml..."
sed -i.bak "s/^version: .*/version: $NEW_VERSION_FULL/" pubspec.yaml
rm pubspec.yaml.bak

log_success "Version updated to $NEW_VERSION_FULL"

log_info "Running tests..."
flutter test
log_success "All tests passed"

log_info "Running code analysis..."
flutter analyze
log_success "Code analysis passed"

log_info "Generating release notes..."
# Generate release notes before tagging
if command -v ./scripts/smart-release-notes.sh >/dev/null 2>&1; then
    ./scripts/smart-release-notes.sh > /dev/null 2>&1
    log_success "Smart release notes generated"
else
    log_warning "Smart release notes generator not found"
fi

log_info "Building Android App Bundle (AAB)..."
flutter build appbundle --release
log_success "Android App Bundle built successfully"

# Get the AAB file path
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

if [ ! -f "$AAB_PATH" ]; then
    log_error "AAB file not found at $AAB_PATH"
    exit 1
fi

log_info "Committing version update..."
git add pubspec.yaml
git commit -m "chore: bump version to $NEW_VERSION_FULL"

log_info "Creating git tag..."
if git tag -l | grep -q "^v$NEW_VERSION$"; then
    log_warning "Tag v$NEW_VERSION already exists. Skipping tag creation."
else
    git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"
    log_success "Created tag v$NEW_VERSION"
fi

log_success "Release preparation complete!"
echo
log_info "Next steps:"
echo "  1. Push changes and tag: git push && git push --tags"
echo "  2. Upload AAB to Google Play Console: $AAB_PATH"
echo "  3. Create release notes in Google Play Console"
echo
# Show release notes if generated
if [ -f "smart-release-notes-v$NEW_VERSION.md" ]; then
    echo
    log_info "📝 Generated release notes (copy to Google Play Console):"
    echo "────────────────────────────────────────────────────"
    # Show just the Google Play Store section
    sed -n '/## Google Play Store Version/,/## Technical Reference/p' "smart-release-notes-v$NEW_VERSION.md" | head -n -2
    echo "────────────────────────────────────────────────────"
    echo
    read -p "Would you like to review and improve these release notes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./scripts/review-release-notes.sh "smart-release-notes-v$NEW_VERSION.md"
    fi
fi

log_info "AAB file location: $AAB_PATH"
log_info "AAB file size: $(du -h "$AAB_PATH" | cut -f1)"

# Optionally push automatically
echo
read -p "Do you want to push changes and tags to remote now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Pushing to remote..."
    git push
    git push --tags
    log_success "Changes and tags pushed to remote"
fi

# Show final instructions
echo
log_success "🎉 Release $NEW_VERSION_FULL is ready!"
echo
log_info "To upload to Google Play Console:"
echo "  1. Go to: https://play.google.com/console"
echo "  2. Select your app"
echo "  3. Go to Release → Production"
echo "  4. Create new release"
echo "  5. Upload the AAB file: $AAB_PATH"
echo "  6. Add release notes"
echo "  7. Review and publish"
echo
log_warning "Don't forget to update the release notes in Google Play Console!"
