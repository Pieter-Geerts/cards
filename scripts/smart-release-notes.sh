#!/usr/bin/env bash

# Smart Release Notes Generator with AI-like suggestions
# Converts technical commit messages to user-friendly release notes
# Usage: ./smart-release-notes.sh [from_tag] [to_tag]

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

log_suggestion() {
    echo -e "${CYAN}💡 $1${NC}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Function to convert technical commits to user-friendly descriptions
make_user_friendly() {
    local commit="$1"
    local commit_lower=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    
    # Skip very generic/meaningless commits
    if [[ "$commit_lower" =~ ^(fix|fixes|pipeline|workflow|update|empty)$ ]]; then
        return
    fi
    
    # Skip version/build commits
    if [[ "$commit_lower" =~ (version|versioning|release|pipeline|workflow|dart\.yml) ]]; then
        return
    fi
    
    # Card-specific improvements
    if [[ "$commit_lower" =~ (card|cards) ]]; then
        if [[ "$commit_lower" =~ (share|sharing) ]]; then
            echo "Added card sharing functionality"
        elif [[ "$commit_lower" =~ (edit|editing) ]]; then
            echo "Improved card editing experience"
        elif [[ "$commit_lower" =~ (delete|deletion) ]]; then
            echo "Enhanced card management options"
        elif [[ "$commit_lower" =~ (import|photo|image) ]]; then
            echo "Added ability to import cards from photos"
        else
            echo "Enhanced card management features"
        fi
        return
    fi
    
    # Specific feature improvements
    if [[ "$commit_lower" =~ (share|sharing) ]]; then
        echo "Added sharing capabilities"
        return
    fi
    
    if [[ "$commit_lower" =~ (import.*photo|import.*image|photo|image) ]]; then
        echo "Added photo import functionality"
        return
    fi
    
    if [[ "$commit_lower" =~ (logo|logos) ]]; then
        echo "Enhanced app branding and logos"
        return
    fi
    
    if [[ "$commit_lower" =~ (redesign|ui|interface) ]]; then
        echo "Improved user interface design"
        return
    fi
    
    if [[ "$commit_lower" =~ (language|localizations|l10n) ]]; then
        echo "Enhanced language and localization support"
        return
    fi
    
    if [[ "$commit_lower" =~ (symbol|symbols) ]]; then
        echo "Added support for special symbols and characters"
        return
    fi
    
    if [[ "$commit_lower" =~ (shadow|dark) ]]; then
        echo "Improved visual design and dark mode support"
        return
    fi
    
    # Bug fixes
    if [[ "$commit_lower" =~ (fix|bug|crash|error|issue) ]]; then
        if [[ "$commit_lower" =~ (test|testing) ]]; then
            return  # Skip test fixes
        elif [[ "$commit_lower" =~ (deprecation|warning) ]]; then
            echo "Fixed compatibility issues"
        elif [[ "$commit_lower" =~ (format|formatting) ]]; then
            echo "Improved code quality and stability"
        else
            echo "Fixed various app stability issues"
        fi
        return
    fi
    
    # Generic improvements for meaningful commits
    if [[ "$commit_lower" =~ (improve|enhancement|better|ready) ]]; then
        echo "General app improvements"
        return
    fi
    
    # Skip if we can't make it user-friendly
    return
}

# Get current version
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')

# Determine version range (same logic as before)
if [ $# -eq 0 ]; then
    LAST_TAG=$(git tag -l --sort=-version:refname | head -1)
    if [ -z "$LAST_TAG" ]; then
        FROM_REF=$(git rev-list --max-parents=0 HEAD)
    else
        FROM_REF="$LAST_TAG"
    fi
    TO_REF="HEAD"
elif [ $# -eq 1 ]; then
    FROM_REF="$1"
    TO_REF="HEAD"
elif [ $# -eq 2 ]; then
    FROM_REF="$1"
    TO_REF="$2"
else
    echo "Usage: $0 [from_tag] [to_tag]"
    exit 1
fi

log_info "Generating smart release notes from $FROM_REF to $TO_REF..."

# Get commits
COMMITS=$(git log --pretty=format:"%s" --no-merges "$FROM_REF..$TO_REF" 2>/dev/null || echo "")

if [ -z "$COMMITS" ]; then
    log_info "No commits found in range"
    exit 0
fi

# Process commits and generate user-friendly descriptions
declare -a user_features=()
declare -a user_fixes=()
declare -a user_improvements=()

while IFS= read -r commit; do
    [ -z "$commit" ] && continue
    
    commit_lower=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    user_friendly=$(make_user_friendly "$commit")
    
    # Skip empty results
    [ -z "$user_friendly" ] && continue
    
    # Categorize
    if [[ "$commit_lower" =~ ^(feat|feature|add) ]] || \
       [[ "$commit_lower" =~ (new feature|implement|create) ]]; then
        user_features+=("$user_friendly")
    elif [[ "$commit_lower" =~ ^(fix|bug) ]] || \
         [[ "$commit_lower" =~ (resolve|patch|correct) ]]; then
        user_fixes+=("$user_friendly")
    else
        user_improvements+=("$user_friendly")
    fi
done <<< "$COMMITS"

# Remove duplicates and limit items
user_features=($(printf "%s\n" "${user_features[@]}" | sort -u | head -5))
user_fixes=($(printf "%s\n" "${user_fixes[@]}" | sort -u | head -5))
user_improvements=($(printf "%s\n" "${user_improvements[@]}" | sort -u | head -5))

# Generate output
log_header "🤖 Smart Release Notes (User-Friendly)"
echo "============================================="
echo

# Google Play Store optimized version
echo "## 📱 Google Play Store Release Notes"
echo

if [ ${#user_features[@]} -gt 0 ]; then
    echo "🆕 **What's New:**"
    for feature in "${user_features[@]}"; do
        echo "• $feature"
    done
    echo
fi

if [ ${#user_fixes[@]} -gt 0 ]; then
    echo "🛠️ **Improvements:**"
    for fix in "${user_fixes[@]}"; do
        echo "• $fix"
    done
    echo
fi

if [ ${#user_improvements[@]} -gt 0 ]; then
    echo "✨ **Enhancements:**"
    for improvement in "${user_improvements[@]}"; do
        echo "• $improvement"
    done
    echo
fi

# Add a call-to-action
echo "Thank you for using our app! Please rate us if you enjoy these updates."

echo
echo "-----------------------------------"

# Technical version for reference
echo "## 🔧 Technical Reference (Original Commits)"
echo "$COMMITS" | sed 's/^/• /'

# Save to file
OUTPUT_FILE="smart-release-notes-v$CURRENT_VERSION.md"
{
    echo "# Smart Release Notes - Version $CURRENT_VERSION"
    echo "Generated on $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Range: $FROM_REF..$TO_REF"
    echo
    echo "## Google Play Store Version (User-Friendly)"
    echo
    if [ ${#user_features[@]} -gt 0 ]; then
        echo "🆕 **What's New:**"
        for feature in "${user_features[@]}"; do
            echo "• $feature"
        done
        echo
    fi
    if [ ${#user_fixes[@]} -gt 0 ]; then
        echo "🛠️ **Improvements:**"
        for fix in "${user_fixes[@]}"; do
            echo "• $fix"
        done
        echo
    fi
    if [ ${#user_improvements[@]} -gt 0 ]; then
        echo "✨ **Enhancements:**"
        for improvement in "${user_improvements[@]}"; do
            echo "• $improvement"
        done
        echo
    fi
    echo "Thank you for using our app! Please rate us if you enjoy these updates."
    echo
    echo "## Technical Reference"
    echo "$COMMITS" | sed 's/^/• /'
} > "$OUTPUT_FILE"

echo
log_success "Smart release notes saved to: $OUTPUT_FILE"

# Character count
TOTAL_TEXT=""
if [ ${#user_features[@]} -gt 0 ]; then
    for feature in "${user_features[@]}"; do
        TOTAL_TEXT="$TOTAL_TEXT• $feature\n"
    done
fi
if [ ${#user_fixes[@]} -gt 0 ]; then
    for fix in "${user_fixes[@]}"; do
        TOTAL_TEXT="$TOTAL_TEXT• $fix\n"
    done
fi
if [ ${#user_improvements[@]} -gt 0 ]; then
    for improvement in "${user_improvements[@]}"; do
        TOTAL_TEXT="$TOTAL_TEXT• $improvement\n"
    done
fi

CHAR_COUNT=$(echo -e "$TOTAL_TEXT" | wc -c | tr -d ' ')
if [ "$CHAR_COUNT" -gt 500 ]; then
    log_info "⚠️  Release notes are $CHAR_COUNT characters (Play Store limit: 500)"
    log_suggestion "Consider removing some items or shortening descriptions"
else
    log_success "Release notes are $CHAR_COUNT characters (within Play Store limit)"
fi

echo
log_suggestion "💡 Tips for even better release notes:"
echo "  • Personalize the descriptions to match your app's voice"
echo "  • Add specific benefits users will notice"
echo "  • Consider your target audience (technical vs general users)"
echo "  • Test the language with actual users if possible"
