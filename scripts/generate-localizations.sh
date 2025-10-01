#!/usr/bin/env bash

# Generate localization files from ARB sources
# This ensures consistent localization files across all environments

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

log_info "Generating localization files from ARB sources..."

# Generate localization files
flutter gen-l10n

log_success "Localization files generated successfully"

# List generated files for verification
echo ""
echo "Generated files:"
ls -la lib/l10n/app_localizations*.dart 2>/dev/null || echo "No localization files found"
