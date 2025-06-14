#!/bin/bash

# Version bump utility for pubspec.yaml
# Usage: ./scripts/bump-version.sh [patch|minor|major|X.Y.Z]

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 [patch|minor|major|X.Y.Z]"
    echo "Examples:"
    echo "  $0 patch     # 1.0.0 -> 1.0.1"
    echo "  $0 minor     # 1.0.0 -> 1.1.0"
    echo "  $0 major     # 1.0.0 -> 2.0.0"
    echo "  $0 1.2.3     # Set to specific version"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Get current version
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep '^version:' pubspec.yaml | sed 's/.*+//')

echo "Current version: $CURRENT_VERSION+$CURRENT_BUILD"

VERSION_TYPE=$1

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
            echo "Error: Invalid version type: $VERSION_TYPE"
            echo "Use: patch, minor, major, or custom version (e.g., 1.2.3)"
            exit 1
            ;;
    esac

    NEW_VERSION="$MAJOR.$MINOR.$PATCH"
fi

NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_VERSION_FULL="$NEW_VERSION+$NEW_BUILD"

echo "New version: $NEW_VERSION_FULL"

# Update pubspec.yaml
sed -i.bak "s/^version: .*/version: $NEW_VERSION_FULL/" pubspec.yaml
rm pubspec.yaml.bak

echo "✅ Version updated in pubspec.yaml"
