#!/bin/bash

# Pre-commit hook for Flutter Cards app
# This runs automatic quality checks before each commit

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

# Navigate to project root (one level up from scripts)
cd "$(dirname "$0")/.."

echo -e "${BLUE}🔍 Running pre-commit checks...${NC}"

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    log_error "Flutter not found. Please install Flutter or add it to PATH."
    exit 1
fi

# Get list of staged files
STAGED_DART_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' || true)
STAGED_YAML_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(yaml|yml)$' || true)
STAGED_ARB_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.arb$' || true)

# If no relevant files staged, skip checks
if [ -z "$STAGED_DART_FILES" ] && [ -z "$STAGED_YAML_FILES" ] && [ -z "$STAGED_ARB_FILES" ]; then
    log_info "No Dart, YAML, or ARB files staged. Skipping Flutter checks."
    exit 0
fi

# Check for secrets or sensitive data
log_info "Checking for sensitive data..."
SECRETS_ISSUES=$(git diff --cached | grep -E "^[+][^+].*\b(password|secret|key|token|api_key)\s*[=:]" | grep -v "secrets_template" | grep -v "keystore" | grep -v ".md:" || true)
if [ -n "$SECRETS_ISSUES" ]; then
    log_error "Potential secrets found in staged changes:"
    echo "$SECRETS_ISSUES"
    echo
    log_error "Please review and remove any sensitive data before committing."
    exit 1
fi
log_success "No sensitive data detected"

# Ensure dependencies are up to date
log_info "Checking dependencies..."
flutter pub get > /dev/null 2>&1
log_success "Dependencies up to date"

# Generate localization files if ARB files changed
if [ -n "$STAGED_ARB_FILES" ]; then
    log_info "ARB files changed, regenerating localizations..."
    flutter gen-l10n > /dev/null 2>&1
    log_success "Localization files regenerated"
fi

# Format Dart code
if [ -n "$STAGED_DART_FILES" ]; then
    log_info "Formatting Dart code..."
    echo "$STAGED_DART_FILES" | xargs dart format > /dev/null 2>&1
    
    # Check if formatting changed anything
    FORMATTING_CHANGES=$(git diff --name-only $STAGED_DART_FILES || true)
    if [ -n "$FORMATTING_CHANGES" ]; then
        log_warning "Code formatting applied. Please review and re-stage files:"
        echo "$FORMATTING_CHANGES" | sed 's/^/  /'
        echo
        log_info "Run: git add <files> && git commit"
        exit 1
    fi
    log_success "Code formatting OK"
fi

# Analyze code
if [ -n "$STAGED_DART_FILES" ]; then
    log_info "Running static analysis..."
    ANALYSIS_OUTPUT=$(flutter analyze --no-pub 2>&1 || true)
    
    # Check for analysis issues in staged files
    ANALYSIS_ISSUES=""
    for file in $STAGED_DART_FILES; do
        if echo "$ANALYSIS_OUTPUT" | grep -q "$file"; then
            ANALYSIS_ISSUES="$ANALYSIS_ISSUES\n$(echo "$ANALYSIS_OUTPUT" | grep "$file")"
        fi
    done
    
    if [ -n "$ANALYSIS_ISSUES" ]; then
        log_error "Static analysis issues found in staged files:"
        echo -e "$ANALYSIS_ISSUES"
        echo
        log_error "Please fix analysis issues before committing."
        exit 1
    fi
    log_success "Static analysis passed"
fi

# Run tests only if test files or core logic changed
NEEDS_TESTING=false
if echo "$STAGED_DART_FILES" | grep -E "(test|lib)" > /dev/null; then
    NEEDS_TESTING=true
fi

if [ "$NEEDS_TESTING" = true ]; then
    log_info "Running tests..."
    TEST_OUTPUT=$(flutter test 2>&1)
    if [ $? -ne 0 ]; then
        log_error "Tests failed:"
        echo "$TEST_OUTPUT"
        echo
        log_error "Please fix failing tests before committing."
        exit 1
    fi
    log_success "All tests passed"
fi

# Check commit message quality (if available)
COMMIT_MSG_FILE="$1"
if [ -n "$COMMIT_MSG_FILE" ] && [ -f "$COMMIT_MSG_FILE" ]; then
    COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")
    
    # Check for conventional commit format
    if ! echo "$COMMIT_MSG" | grep -qE "^(feat|fix|docs|style|refactor|test|chore|ci|perf|build|revert)(\(.+\))?: .{1,}"; then
        log_warning "Consider using conventional commit format:"
        echo "  feat: add new feature"
        echo "  fix: resolve bug"
        echo "  docs: update documentation"
        echo "  style: code formatting"
        echo "  refactor: code restructuring"
        echo "  test: add or modify tests"
        echo "  chore: maintenance tasks"
        echo "  ci: CI/CD changes"
        echo
        echo "Current message: $COMMIT_MSG"
    fi
fi

echo
log_success "Pre-commit checks completed successfully! 🎉"
echo -e "${GREEN}Ready to commit.${NC}"
