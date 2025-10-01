#!/usr/bin/env bash

# Release Notes Reviewer and Editor
# Interactive tool to review and improve generated release notes
# Usage: ./review-release-notes.sh [release-notes-file]

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

log_tip() {
    echo -e "${CYAN}💡 $1${NC}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Find the most recent release notes file if none specified
if [ $# -eq 0 ]; then
    NOTES_FILE=$(ls -t smart-release-notes-*.md 2>/dev/null | head -1)
    if [ -z "$NOTES_FILE" ]; then
        log_info "No release notes file found. Generating one first..."
        ./scripts/smart-release-notes.sh
        NOTES_FILE=$(ls -t smart-release-notes-*.md 2>/dev/null | head -1)
    fi
else
    NOTES_FILE="$1"
fi

if [ ! -f "$NOTES_FILE" ]; then
    echo "Error: Release notes file not found: $NOTES_FILE"
    exit 1
fi

log_header "📝 Release Notes Reviewer"
echo "File: $NOTES_FILE"
echo

# Extract Play Store section
PLAY_STORE_SECTION=$(sed -n '/## Google Play Store Version/,/## /p' "$NOTES_FILE" | head -n -2)

log_header "Current Google Play Store Release Notes:"
echo "────────────────────────────────────────"
echo "$PLAY_STORE_SECTION"
echo "────────────────────────────────────────"
echo

# Character count
CHAR_COUNT=$(echo "$PLAY_STORE_SECTION" | wc -c | tr -d ' ')
if [ "$CHAR_COUNT" -gt 500 ]; then
    echo -e "${YELLOW}⚠️  Current length: $CHAR_COUNT characters (exceeds 500 limit)${NC}"
else
    log_success "Current length: $CHAR_COUNT characters (within 500 limit)"
fi
echo

# Quality checks
log_header "📊 Quality Analysis:"

# Check for technical jargon
TECHNICAL_WORDS=("database" "API" "commit" "repository" "refactor" "dependency" "pipeline" "workflow" "build" "compile")
FOUND_TECHNICAL=""
for word in "${TECHNICAL_WORDS[@]}"; do
    if echo "$PLAY_STORE_SECTION" | grep -qi "$word"; then
        FOUND_TECHNICAL="$FOUND_TECHNICAL $word"
    fi
done

if [ -n "$FOUND_TECHNICAL" ]; then
    echo -e "${YELLOW}⚠️  Technical jargon found:$FOUND_TECHNICAL${NC}"
    log_tip "Consider replacing with user-friendly terms"
else
    log_success "No obvious technical jargon detected"
fi

# Check for vague descriptions
VAGUE_PATTERNS=("various" "general" "improved" "enhanced" "better" "fixed issues")
FOUND_VAGUE=""
for pattern in "${VAGUE_PATTERNS[@]}"; do
    if echo "$PLAY_STORE_SECTION" | grep -qi "$pattern"; then
        FOUND_VAGUE="$FOUND_VAGUE '$pattern'"
    fi
done

if [ -n "$FOUND_VAGUE" ]; then
    echo -e "${YELLOW}⚠️  Vague descriptions found:$FOUND_VAGUE${NC}"
    log_tip "Consider being more specific about benefits"
else
    log_success "Descriptions appear specific"
fi

# Check for user benefits
BENEFIT_WORDS=("faster" "easier" "better" "new" "improved" "enhanced" "added")
BENEFIT_COUNT=0
for word in "${BENEFIT_WORDS[@]}"; do
    BENEFIT_COUNT=$((BENEFIT_COUNT + $(echo "$PLAY_STORE_SECTION" | grep -oi "$word" | wc -l)))
done

if [ "$BENEFIT_COUNT" -gt 3 ]; then
    log_success "Good use of benefit-focused language ($BENEFIT_COUNT instances)"
else
    echo -e "${YELLOW}⚠️  Limited benefit-focused language ($BENEFIT_COUNT instances)${NC}"
    log_tip "Consider emphasizing user benefits more"
fi

echo

# Suggestions
log_header "💡 Improvement Suggestions:"

echo "1. 🎯 Be specific about user benefits:"
echo "   Instead of: 'Enhanced card management'"
echo "   Try: 'Faster card organization with drag-and-drop'"
echo
echo "2. 🗣️ Use active voice:"
echo "   Instead of: 'Issues were fixed'"
echo "   Try: 'Fixed crashes when scanning QR codes'"
echo
echo "3. 📱 Focus on user experience:"
echo "   Instead of: 'Code improvements'"
echo "   Try: 'Faster app startup and smoother animations'"
echo
echo "4. 🎉 Add excitement:"
echo "   Instead of: 'Added feature'"
echo "   Try: 'Exciting new feature: [specific benefit]'"
echo

# Interactive editing
echo
read -p "Would you like to edit the release notes now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Create a temporary file for editing
    TEMP_FILE=$(mktemp)
    echo "$PLAY_STORE_SECTION" > "$TEMP_FILE"
    
    # Open in default editor
    ${EDITOR:-nano} "$TEMP_FILE"
    
    # Read the edited content
    EDITED_CONTENT=$(cat "$TEMP_FILE")
    rm "$TEMP_FILE"
    
    # Check new character count
    NEW_CHAR_COUNT=$(echo "$EDITED_CONTENT" | wc -c | tr -d ' ')
    
    echo
    log_info "Edited version ($NEW_CHAR_COUNT characters):"
    echo "────────────────────────────────────────"
    echo "$EDITED_CONTENT"
    echo "────────────────────────────────────────"
    
    if [ "$NEW_CHAR_COUNT" -gt 500 ]; then
        echo -e "${YELLOW}⚠️  Still over 500 characters. Consider shortening further.${NC}"
    else
        log_success "Within character limit!"
    fi
    
    echo
    read -p "Save these changes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Update the original file
        EDITED_FILE="${NOTES_FILE%.md}-edited.md"
        
        # Copy original file structure but replace Play Store section
        {
            sed -n '1,/## Google Play Store Version/p' "$NOTES_FILE"
            echo
            echo "$EDITED_CONTENT"
            echo
            sed -n '/## Technical Reference/,$p' "$NOTES_FILE"
        } > "$EDITED_FILE"
        
        log_success "Edited version saved as: $EDITED_FILE"
        
        # Offer to copy to clipboard (macOS)
        if command -v pbcopy >/dev/null 2>&1; then
            echo
            read -p "Copy to clipboard for Google Play Console? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "$EDITED_CONTENT" | pbcopy
                log_success "Copied to clipboard! Ready to paste in Google Play Console."
            fi
        fi
    fi
fi

echo
log_header "📋 Final Checklist:"
echo "Before publishing to Google Play Console:"
echo "• ✓ Release notes are under 500 characters"
echo "• ✓ Language is user-friendly (no technical jargon)"
echo "• ✓ Benefits are specific and clear"
echo "• ✓ Tone matches your app's personality"
echo "• ✓ Spell-check completed"
echo
log_success "Ready to publish! 🚀"
