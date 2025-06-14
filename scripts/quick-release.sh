#!/bin/bash

# Quick Release - One command to rule them all
# Usage: ./scripts/quick-release.sh
# This will do a patch release automatically

set -e

echo "🚀 Starting quick patch release..."

# Run the main release script with patch version
"$(dirname "$0")/release.sh" patch

echo "🎉 Quick release complete!"
echo "📱 AAB file is ready for Google Play Console upload!"
echo "🌐 Open Google Play Console: https://play.google.com/console"
