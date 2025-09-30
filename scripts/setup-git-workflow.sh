#!/usr/bin/env bash

# Configure Git settings and aliases for optimal Flutter development workflow
# This sets up Git configuration optimized for your Flutter Cards app

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

# Navigate to project root - simplified approach
cd "$(dirname "$0")/.."

log_info "Configuring Git for optimal Flutter development..."

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo -e "${RED}❌ Not in a git repository. Please run this from the project root.${NC}"
    exit 1
fi

# Git configuration for this repository
log_info "Setting up Git configuration..."

# Core settings
git config core.autocrlf false  # Prevent line ending issues
git config core.safecrlf warn   # Warn about mixed line endings
git config pull.rebase false    # Use merge instead of rebase for pulls

# Diff and merge settings
git config diff.dart.textconv "dart format --output=show"  # Better Dart diffs
git config merge.ours.driver true  # For generated files

log_success "Git configuration updated"

# Useful Git aliases for Flutter development
log_info "Setting up Git aliases..."

# Status and logging
git config alias.st "status --short"
git config alias.lg "log --oneline --graph --decorate --all -10"
git config alias.last "log -1 HEAD"

# Branch management
git config alias.br "branch -v"
git config alias.co "checkout"
git config alias.cob "checkout -b"

# Staging and committing
git config alias.aa "add --all"
git config alias.unstage "reset HEAD --"
git config alias.undo "reset --soft HEAD~1"

# Flutter-specific aliases
git config alias.flutter-check "!f() { flutter analyze && flutter test; }; f"
git config alias.quick-commit "!f() { git add . && git commit -m \"\$1\" && git push; }; f"
git config alias.feature-start "!f() { git checkout main && git pull && git checkout -b feature/\$1; }; f"
git config alias.feature-finish "!f() { git checkout main && git pull && git merge --no-ff \$1 && git branch -d \$1; }; f"

# Release workflow aliases
git config alias.release-check "./scripts/pre-release-check.sh"
git config alias.build-info "./scripts/build-info.sh"

log_success "Git aliases configured"

# Set up .gitattributes for better handling of Flutter files
log_info "Setting up .gitattributes..."

cat > .gitattributes << 'EOF'
# Flutter/Dart files
*.dart text diff=dart
*.yaml text
*.yml text
*.json text
*.md text
*.txt text

# Generated files (should be in .gitignore anyway)
*.g.dart linguist-generated=true
*.freezed.dart linguist-generated=true
*.pb*.dart linguist-generated=true
**/generated_plugin_registrant.dart linguist-generated=true
lib/l10n/app_localizations*.dart linguist-generated=true

# Build artifacts
*.aab binary
*.apk binary
*.app binary
*.dSYM binary
*.ipa binary
*.jar binary
*.keystore binary
*.jks binary

# Images
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.svg text

# Platform specific
*.pbxproj text merge=union
*.xcconfig text
*.entitlements text
gradlew text eol=lf
*.gradle text
*.gradle.kts text
*.properties text

# Archives
*.zip binary
*.tar.gz binary
*.tar binary
EOF

log_success ".gitattributes configured"

# Enhanced .gitignore additions
log_info "Enhancing .gitignore..."

# Check if .gitignore exists and add Flutter-specific ignores if not present
if ! grep -q "# Enhanced Flutter ignores" .gitignore 2>/dev/null; then
cat >> .gitignore << 'EOF'

# Enhanced Flutter ignores
*.log
.vscode/settings.json
.vscode/launch.json
*.tmp
*.temp
.flutter-plugins-dependencies

# macOS
.DS_Store
.AppleDouble
.LSOverride
Thumbs.db

# IDE - IntelliJ IDEA
*.iws
.idea/workspace.xml
.idea/tasks.xml
.idea/dictionaries
.idea/vcs.xml
.idea/jsLibraryMappings.xml
.idea/datasources.xml
.idea/dataSources.ids
.idea/sqlDataSources.xml
.idea/dynamic.xml
.idea/uiDesigner.xml

# IDE - VS Code
.vscode/settings.json
.vscode/launch.json

# Coverage
coverage/
*.lcov

# Test artifacts
.test_coverage/
test/coverage_helper_test.dart

# Flutter Web
/web/dist/

# Temporary files
*.backup
*.bak
*.tmp
*.swp
*~

# Local configuration
.env.local
.env.development.local
.env.test.local
.env.production.local
EOF

log_success ".gitignore enhanced"
fi

echo
log_success "Git workflow configuration completed! 🎉"
echo
echo -e "${BLUE}New Git aliases available:${NC}"
echo "  git st              # Short status"
echo "  git lg              # Pretty log with graph"
echo "  git br              # Verbose branch list"
echo "  git aa              # Add all files"
echo "  git cob <name>      # Create and checkout branch"
echo "  git flutter-check   # Run analyze + test"
echo "  git feature-start <name>   # Start new feature branch"
echo "  git feature-finish <name>  # Merge feature branch"
echo "  git release-check   # Run pre-release checks"
echo "  git build-info      # Show build status"
echo
echo -e "${BLUE}Enhanced workflow features:${NC}"
echo "  • Better diff handling for Dart files"
echo "  • Proper file type detection"
echo "  • Merge conflict resolution helpers"
echo "  • Enhanced .gitignore patterns"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Install Git hooks: ./scripts/install-git-hooks.sh"
echo "  2. Try a new alias: git st"
echo "  3. Start a feature: git feature-start my-feature"
