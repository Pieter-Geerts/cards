#!/usr/bin/env bash

# Google Play Store Upload Script
# Uploads AAB file to Google Play Console using Google Play Developer API
# 
# Prerequisites:
# 1. Google Play Developer API enabled
# 2. Service account created with proper permissions
# 3. Service account key downloaded as JSON file
# 4. Environment variables set (see below)

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

# Configuration - Set these environment variables or edit here
PACKAGE_NAME="${GOOGLE_PLAY_PACKAGE_NAME:-com.example.cards}"
SERVICE_ACCOUNT_KEY="${GOOGLE_PLAY_SERVICE_ACCOUNT_KEY:-}"
AAB_FILE="$1"

if [ -z "$AAB_FILE" ]; then
    log_error "Usage: $0 <path_to_aab_file>"
    exit 1
fi

if [ ! -f "$AAB_FILE" ]; then
    log_error "AAB file not found: $AAB_FILE"
    exit 1
fi

if [ -z "$SERVICE_ACCOUNT_KEY" ]; then
    log_warning "Google Play Developer API not configured yet."
    echo
    echo "To set up automatic uploads:"
    echo
    echo "1. Go to Google Cloud Console:"
    echo "   https://console.cloud.google.com/"
    echo
    echo "2. Enable Google Play Developer API"
    echo
    echo "3. Create a service account:"
    echo "   - Go to IAM & Admin > Service Accounts"
    echo "   - Create new service account"
    echo "   - Download JSON key file"
    echo
    echo "4. Grant API access in Google Play Console:"
    echo "   - Go to Play Console > Setup > API access"
    echo "   - Link your Google Cloud project"
    echo "   - Grant permissions to your service account"
    echo
    echo "5. Set environment variables:"
    echo "   export GOOGLE_PLAY_PACKAGE_NAME='your.package.name'"
    echo "   export GOOGLE_PLAY_SERVICE_ACCOUNT_KEY='/path/to/service-account-key.json'"
    echo
    echo "6. Install upload tool (choose one):"
    echo "   - Fastlane: gem install fastlane"
    echo "   - Or use direct API calls with curl"
    echo
    log_info "For now, please upload manually to Google Play Console."
    exit 1
fi

log_info "🚀 Starting upload to Google Play Console..."

# Check if we have the required tools
if command -v fastlane >/dev/null 2>&1; then
    log_info "Using Fastlane for upload..."
    
    # Create temporary Fastfile if it doesn't exist
    if [ ! -f "android/fastlane/Fastfile" ]; then
        log_info "Creating temporary Fastlane configuration..."
        mkdir -p android/fastlane
        cat > android/fastlane/Fastfile << EOF
default_platform(:android)

platform :android do
  desc "Upload AAB to Google Play Console"
  lane :upload do |options|
    upload_to_play_store(
      package_name: ENV['GOOGLE_PLAY_PACKAGE_NAME'],
      json_key: ENV['GOOGLE_PLAY_SERVICE_ACCOUNT_KEY'],
      aab: options[:aab],
      track: 'internal',  # Change to 'production' when ready
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end
end
EOF
    fi
    
    cd android
    fastlane upload aab:"../$AAB_FILE"
    cd ..
    
elif command -v curl >/dev/null 2>&1; then
    log_info "Using direct API calls for upload..."
    log_warning "Direct API upload not implemented yet. Please use Fastlane or manual upload."
    exit 1
    
else
    log_error "No upload tool available. Please install fastlane: gem install fastlane"
    exit 1
fi

log_success "🎉 Upload completed successfully!"
log_info "Check Google Play Console to review and publish the release."
