#!/usr/bin/env bash

# Documentation maintenance script
# Helps keep documentation organized and up-to-date

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

# Navigate to project root
cd "$(dirname "$0")/.."

log_info "Performing documentation maintenance..."

# Clean up temporary files
log_info "Cleaning up temporary files..."
find . -name "*_TEMP.md" -delete 2>/dev/null || true
find . -name "README_MERGED.md" -delete 2>/dev/null || true
find . -name "*.patch" -delete 2>/dev/null || true
find . -name "*.log" -not -path "./build/*" -not -path "./.dart_tool/*" -delete 2>/dev/null || true

# Move misplaced generated files
log_info "Organizing generated files..."
mkdir -p docs/generated
find . -maxdepth 1 -name "smart-release-notes-*.md" -exec mv {} docs/generated/ \; 2>/dev/null || true

# Update documentation index timestamp
if [ -f "docs/README.md" ]; then
    log_info "Updating documentation index timestamp..."
    sed -i.bak "s/Last updated: .*/Last updated: $(date '+%Y-%m-%d')/" docs/README.md
    rm -f docs/README.md.bak
fi

# Check for broken links (basic check)
log_info "Checking for potential broken links..."
broken_links=0

check_file_exists() {
    local file_path="$1"
    local referenced_in="$2"
    
    if [ ! -f "$file_path" ]; then
        log_warning "Broken link in $referenced_in: $file_path does not exist"
        ((broken_links++))
    fi
}

# Check main README links
if [ -f "README.md" ]; then
    grep -o '\[.*\]([^)]*\.md)' README.md | sed 's/.*(\([^)]*\)).*/\1/' | while read -r link; do
        if [[ "$link" != http* ]]; then
            check_file_exists "$link" "README.md"
        fi
    done
fi

# Check docs index links
if [ -f "docs/README.md" ]; then
    grep -o '\[.*\]([^)]*\.md)' docs/README.md | sed 's/.*(\([^)]*\)).*/\1/' | while read -r link; do
        if [[ "$link" != http* ]]; then
            # Adjust relative paths from docs/
            if [[ "$link" == ../* ]]; then
                check_file_exists "${link#../}" "docs/README.md"
            else
                check_file_exists "docs/$link" "docs/README.md"
            fi
        fi
    done
fi

# Generate documentation tree
log_info "Generating documentation structure..."
cat > docs/STRUCTURE.md << 'EOF'
# Documentation Structure

This file shows the current organization of all documentation.

```
docs/
├── README.md                    # 📚 Main documentation index
├── STRUCTURE.md                 # 📋 This file - documentation organization
├── workflows/                   # 🔧 Development workflows
│   ├── GIT_WORKFLOW.md         # Git workflow automation
│   ├── GIT_WORKFLOW_SUMMARY.md # Quick Git reference
│   ├── DEPENDENCY_MANAGEMENT.md # Flutter dependencies
│   └── LOCALIZATION_WORKFLOW.md # App translations
├── guides/                      # 📖 Development guides
│   ├── RELEASE.md              # Release process guide
│   ├── TEST_COVERAGE.md        # Testing strategy
│   └── REFACTORING_COMPLETE.md # Refactoring history
└── generated/                   # 🤖 Auto-generated files
    ├── smart-release-notes-*.md # Generated release notes
    └── ...                     # Other generated docs

../scripts/                      # 🛠️ Related script documentation
├── README.md                   # Scripts overview
└── RELEASE_NOTES_GUIDE.md      # Release notes automation

../                             # 📱 Root level documentation
├── README.md                   # Main project README
└── PRIVACY_POLICY.md          # Privacy policy
```

## Documentation Guidelines

### File Naming
- Use kebab-case for multi-word files: `git-workflow.md`
- Use UPPER_CASE for important guides: `README.md`, `RELEASE.md`
- Prefix generated files with type: `smart-release-notes-v1.0.2.md`

### Organization
- **workflows/**: How to do development tasks
- **guides/**: What to know about the project
- **generated/**: Auto-created files (don't edit manually)

### Maintenance
- Run `./scripts/docs-maintenance.sh` periodically
- Update timestamps in documentation index
- Check for broken links regularly
- Move generated files to proper directories

EOF

log_success "Documentation maintenance completed!"

if [ $broken_links -gt 0 ]; then
    log_warning "Found $broken_links potential broken link(s). Please review manually."
else
    log_success "No broken links detected!"
fi

echo
log_info "Documentation structure:"
echo "  📚 docs/README.md - Main index"
echo "  🔧 docs/workflows/ - Development processes"
echo "  📖 docs/guides/ - Project guides"
echo "  🤖 docs/generated/ - Auto-generated files"
echo
log_info "Next steps:"
echo "  • Review the docs/README.md index"
echo "  • Check for any broken links reported above"
echo "  • Consider updating outdated documentation"
