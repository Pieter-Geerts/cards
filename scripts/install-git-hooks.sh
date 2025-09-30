#!/usr/bin/env bash

# Install Git hooks for Flutter Cards app
# This sets up automated quality checks in your Git workflow

set -e

# Ensure PATH includes standard locations
export PATH="/usr/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"

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

# Navigate to project root
cd "$(dirname "$0")/.."

log_info "Installing Git hooks for Flutter Cards app..."

# Check if we're in a git repository
if [ ! -d .git ]; then
    log_error "Not in a git repository. Please run this from the project root."
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Install pre-commit hook
PRE_COMMIT_HOOK=".git/hooks/pre-commit"
log_info "Installing pre-commit hook..."

cat > "$PRE_COMMIT_HOOK" << 'EOF'
#!/bin/bash

# Pre-commit hook - calls our custom script
export PATH="/usr/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"
SCRIPT_DIR="$(git rev-parse --show-toplevel)/scripts"
exec "$SCRIPT_DIR/pre-commit-hook.sh" "$@"
EOF

chmod +x "$PRE_COMMIT_HOOK"
log_success "Pre-commit hook installed"

# Install prepare-commit-msg hook for commit message templates
PREPARE_COMMIT_MSG_HOOK=".git/hooks/prepare-commit-msg"
log_info "Installing prepare-commit-msg hook..."

cat > "$PREPARE_COMMIT_MSG_HOOK" << 'EOF'
#!/bin/bash

# Prepare commit message hook - helps with conventional commits
export PATH="/usr/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"
COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Only add template for regular commits (not merges, amends, etc.)
if [ "$COMMIT_SOURCE" = "" ]; then
    # Check if message is empty
    if [ ! -s "$COMMIT_MSG_FILE" ]; then
        cat >> "$COMMIT_MSG_FILE" << 'EOL'
# Conventional Commit Format:
# <type>(<scope>): <description>
#
# Types:
#   feat:     New feature
#   fix:      Bug fix
#   docs:     Documentation
#   style:    Formatting (no code change)
#   refactor: Code restructuring
#   test:     Add or modify tests
#   chore:    Maintenance
#   ci:       CI/CD changes
#   perf:     Performance improvement
#   build:    Build system changes
#   revert:   Revert previous commit
#
# Examples:
#   feat(auth): add login functionality
#   fix(ui): resolve button alignment issue
#   docs: update README with setup instructions
#   test(models): add unit tests for Card model
EOL
    fi
fi
EOF

chmod +x "$PREPARE_COMMIT_MSG_HOOK"
log_success "Prepare-commit-msg hook installed"

# Install post-merge hook for dependency updates
POST_MERGE_HOOK=".git/hooks/post-merge"
log_info "Installing post-merge hook..."

cat > "$POST_MERGE_HOOK" << 'EOF'
#!/bin/bash

# Post-merge hook - runs after git pull/merge
export PATH="/usr/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"
echo "🔄 Post-merge: Checking for dependency updates..."

SCRIPT_DIR="$(git rev-parse --show-toplevel)/scripts"

# Check if pubspec.yaml changed
if git diff HEAD@{1} --name-only | grep -q "pubspec.yaml"; then
    echo "📦 pubspec.yaml changed, updating dependencies..."
    flutter pub get
    echo "✅ Dependencies updated"
fi

# Check if ARB files changed
if git diff HEAD@{1} --name-only | grep -q "\.arb$"; then
    echo "🌍 Localization files changed, regenerating..."
    flutter gen-l10n
    echo "✅ Localization files regenerated"
fi

echo "✅ Post-merge checks completed"
EOF

chmod +x "$POST_MERGE_HOOK"
log_success "Post-merge hook installed"

# Install commit-msg hook for commit message validation
COMMIT_MSG_HOOK=".git/hooks/commit-msg"
log_info "Installing commit-msg hook..."

cat > "$COMMIT_MSG_HOOK" << 'EOF'
#!/bin/bash

# Commit message validation hook
export PATH="/usr/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"
COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Skip validation for merge commits
if echo "$COMMIT_MSG" | grep -q "^Merge "; then
    exit 0
fi

# Check for minimum length
if [ ${#COMMIT_MSG} -lt 10 ]; then
    echo -e "${RED}❌ Commit message too short (minimum 10 characters)${NC}"
    echo "Current: '$COMMIT_MSG'"
    exit 1
fi

# Check for maximum length of first line
FIRST_LINE=$(echo "$COMMIT_MSG" | head -n1)
if [ ${#FIRST_LINE} -gt 72 ]; then
    echo -e "${YELLOW}⚠️  First line is longer than 72 characters (${#FIRST_LINE})${NC}"
    echo "Consider shortening: '$FIRST_LINE'"
    echo "This is just a warning, commit will proceed..."
fi

# Suggest conventional commit format if not used
if ! echo "$FIRST_LINE" | grep -qE "^(feat|fix|docs|style|refactor|test|chore|ci|perf|build|revert)(\(.+\))?: .+"; then
    echo -e "${YELLOW}💡 Consider using conventional commit format:${NC}"
    echo "  feat: add new feature"
    echo "  fix: resolve issue"
    echo "  docs: update documentation"
    echo
    echo "Current: '$FIRST_LINE'"
    echo "This is just a suggestion, commit will proceed..."
fi

exit 0
EOF

chmod +x "$COMMIT_MSG_HOOK"
log_success "Commit-msg hook installed"

echo
log_success "Git hooks installation completed! 🎉"
echo
echo -e "${BLUE}Installed hooks:${NC}"
echo "  • pre-commit: Code quality checks"
echo "  • prepare-commit-msg: Commit message templates"
echo "  • post-merge: Automatic dependency updates"
echo "  • commit-msg: Message validation"
echo
echo -e "${BLUE}What happens now:${NC}"
echo "  • Every commit will be checked for quality"
echo "  • Commit messages will have helpful templates"
echo "  • Dependencies update automatically after pull/merge"
echo "  • Conventional commit format is encouraged"
echo
echo -e "${BLUE}To disable temporarily:${NC}"
echo "  git commit --no-verify"
echo
echo -e "${BLUE}To uninstall:${NC}"
echo "  rm .git/hooks/pre-commit"
echo "  rm .git/hooks/prepare-commit-msg"
echo "  rm .git/hooks/post-merge"
echo "  rm .git/hooks/commit-msg"
