#!/usr/bin/env bash

# Auto Release Notes Generator
# Generates release notes from git commits between versions
# Usage: ./generate-release-notes.sh [from_tag] [to_tag]
# Example: ./generate-release-notes.sh v1.0.1 v1.0.2

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_header() {
    echo -e "${PURPLE}$1${NC}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Get current version
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')

# Determine version range
if [ $# -eq 0 ]; then
    # No arguments - find last tag and current
    LAST_TAG=$(git tag -l --sort=-version:refname | head -1)
    if [ -z "$LAST_TAG" ]; then
        log_info "No previous tags found. Using initial commit."
        FROM_REF=$(git rev-list --max-parents=0 HEAD)
    else
        FROM_REF="$LAST_TAG"
    fi
    TO_REF="HEAD"
    log_info "Generating release notes from $FROM_REF to current state"
elif [ $# -eq 1 ]; then
    # One argument - from tag to current
    FROM_REF="$1"
    TO_REF="HEAD"
    log_info "Generating release notes from $FROM_REF to current state"
elif [ $# -eq 2 ]; then
    # Two arguments - specific range
    FROM_REF="$1"
    TO_REF="$2"
    log_info "Generating release notes from $FROM_REF to $TO_REF"
else
    echo "Usage: $0 [from_tag] [to_tag]"
    echo "Examples:"
    echo "  $0                    # Since last tag"
    echo "  $0 v1.0.1            # From v1.0.1 to current"
    echo "  $0 v1.0.1 v1.0.2     # Between two tags"
    exit 1
fi

# Get commit messages
log_info "Analyzing commits..."
COMMITS=$(git log --pretty=format:"%s" --no-merges "$FROM_REF..$TO_REF" 2>/dev/null || echo "")

if [ -z "$COMMITS" ]; then
    log_info "No commits found in range $FROM_REF..$TO_REF"
    echo "## No changes found"
    echo "No commits were found between $FROM_REF and $TO_REF."
    exit 0
fi

# Initialize categories
NEW_FEATURES=""
BUG_FIXES=""
IMPROVEMENTS=""
TECHNICAL=""
OTHER=""

# Categorize commits
while IFS= read -r commit; do
    # Skip empty lines
    [ -z "$commit" ] && continue
    
    # Convert to lowercase for matching
    commit_lower=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    
    # Categorize based on commit message patterns
    if [[ "$commit_lower" =~ ^(feat|feature|add) ]] || \
       [[ "$commit_lower" =~ (new feature|implement|create) ]] || \
       [[ "$commit" =~ ^✨ ]]; then
        NEW_FEATURES="$NEW_FEATURES- $commit\n"
    elif [[ "$commit_lower" =~ ^(fix|bug) ]] || \
         [[ "$commit_lower" =~ (resolve|patch|correct) ]] || \
         [[ "$commit" =~ ^🐛 ]]; then
        BUG_FIXES="$BUG_FIXES- $commit\n"
    elif [[ "$commit_lower" =~ ^(improve|enhance|update|refactor) ]] || \
         [[ "$commit_lower" =~ (performance|optimize|better) ]] || \
         [[ "$commit" =~ ^⚡|^🎨 ]]; then
        IMPROVEMENTS="$IMPROVEMENTS- $commit\n"
    elif [[ "$commit_lower" =~ ^(chore|build|ci|test|docs) ]] || \
         [[ "$commit_lower" =~ (dependency|dependencies|version|release) ]] || \
         [[ "$commit" =~ ^🔧|^👷|^📝 ]]; then
        TECHNICAL="$TECHNICAL- $commit\n"
    else
        OTHER="$OTHER- $commit\n"
    fi
done <<< "$COMMITS"

# Generate release notes
log_header "📝 Generated Release Notes"
echo "=========================================="
echo

# For Google Play Store (short version)
echo "## Google Play Store Release Notes"
echo "-----------------------------------"
echo

if [ -n "$NEW_FEATURES" ]; then
    echo "🆕 New Features:"
    echo -e "$NEW_FEATURES" | head -3  # Limit to 3 items
fi

if [ -n "$BUG_FIXES" ]; then
    echo "🐛 Bug Fixes:"
    echo -e "$BUG_FIXES" | head -3  # Limit to 3 items
fi

if [ -n "$IMPROVEMENTS" ]; then
    echo "🎨 Improvements:"
    echo -e "$IMPROVEMENTS" | head -3  # Limit to 3 items
fi

echo
echo "-----------------------------------"
echo "## Complete Release Notes (Internal)"
echo

# Full version for internal use
if [ -n "$NEW_FEATURES" ]; then
    echo "### 🆕 New Features"
    echo -e "$NEW_FEATURES"
fi

if [ -n "$BUG_FIXES" ]; then
    echo "### 🐛 Bug Fixes"
    echo -e "$BUG_FIXES"
fi

if [ -n "$IMPROVEMENTS" ]; then
    echo "### 🎨 Improvements"
    echo -e "$IMPROVEMENTS"
fi

if [ -n "$TECHNICAL" ]; then
    echo "### 🔧 Technical Changes"
    echo -e "$TECHNICAL"
fi

if [ -n "$OTHER" ]; then
    echo "### 📋 Other Changes"
    echo -e "$OTHER"
fi

# Save to file
OUTPUT_FILE="release-notes-v$CURRENT_VERSION.md"
{
    echo "# Release Notes - Version $CURRENT_VERSION"
    echo "Generated on $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Range: $FROM_REF..$TO_REF"
    echo
    echo "## Google Play Store Version (Character Limited)"
    echo
    if [ -n "$NEW_FEATURES" ]; then
        echo "🆕 New Features:"
        echo -e "$NEW_FEATURES" | head -3
    fi
    if [ -n "$BUG_FIXES" ]; then
        echo "🐛 Bug Fixes:"
        echo -e "$BUG_FIXES" | head -3
    fi
    if [ -n "$IMPROVEMENTS" ]; then
        echo "🎨 Improvements:"
        echo -e "$IMPROVEMENTS" | head -3
    fi
    echo
    echo "## Complete Version (Internal Reference)"
    echo
    if [ -n "$NEW_FEATURES" ]; then
        echo "### 🆕 New Features"
        echo -e "$NEW_FEATURES"
    fi
    if [ -n "$BUG_FIXES" ]; then
        echo "### 🐛 Bug Fixes"
        echo -e "$BUG_FIXES"
    fi
    if [ -n "$IMPROVEMENTS" ]; then
        echo "### 🎨 Improvements"
        echo -e "$IMPROVEMENTS"
    fi
    if [ -n "$TECHNICAL" ]; then
        echo "### 🔧 Technical Changes"
        echo -e "$TECHNICAL"
    fi
    if [ -n "$OTHER" ]; then
        echo "### 📋 Other Changes"
        echo -e "$OTHER"
    fi
} > "$OUTPUT_FILE"

echo
log_success "Release notes saved to: $OUTPUT_FILE"

# Commit count
COMMIT_COUNT=$(echo "$COMMITS" | wc -l | tr -d ' ')
log_info "Analyzed $COMMIT_COUNT commits"

# Character count for Play Store
PLAY_STORE_TEXT=""
if [ -n "$NEW_FEATURES" ]; then
    PLAY_STORE_TEXT="$PLAY_STORE_TEXT🆕 New Features:\n$(echo -e "$NEW_FEATURES" | head -3)\n"
fi
if [ -n "$BUG_FIXES" ]; then
    PLAY_STORE_TEXT="$PLAY_STORE_TEXT🐛 Bug Fixes:\n$(echo -e "$BUG_FIXES" | head -3)\n"
fi
if [ -n "$IMPROVEMENTS" ]; then
    PLAY_STORE_TEXT="$PLAY_STORE_TEXT🎨 Improvements:\n$(echo -e "$IMPROVEMENTS" | head -3)\n"
fi

CHAR_COUNT=$(echo -e "$PLAY_STORE_TEXT" | wc -c | tr -d ' ')
if [ "$CHAR_COUNT" -gt 500 ]; then
    log_info "⚠️  Play Store text is $CHAR_COUNT characters (limit: 500). Consider shortening."
else
    log_success "Play Store text is $CHAR_COUNT characters (within 500 limit)"
fi

echo
log_info "💡 Tips:"
echo "  • Copy the 'Google Play Store Version' section to Play Console"
echo "  • Edit the generated notes to make them user-friendly"
echo "  • Remove technical jargon that users won't understand"
echo "  • Focus on user benefits rather than code changes"
