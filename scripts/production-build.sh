#!/usr/bin/env bash

# Production Build Script for Cards App
# Optimized for performance and production deployment

set -e  # Exit on any error

echo "🚀 Starting Cards App Production Build..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Build configuration
BUILD_DIR="build/release"
APP_NAME="Cards"
VERSION=$(grep "version:" pubspec.yaml | cut -d: -f2 | tr -d ' ')

echo -e "${BLUE}📋 Build Configuration:${NC}"
echo "  App Name: $APP_NAME"
echo "  Version: $VERSION"
echo "  Build Directory: $BUILD_DIR"
echo ""

# Step 1: Environment Validation
echo -e "${YELLOW}🔍 Validating Environment...${NC}"

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter.${NC}"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
echo -e "${GREEN}✅ Flutter Version: $FLUTTER_VERSION${NC}"

# Step 2: Code Quality Checks
echo -e "${YELLOW}🔍 Running Code Quality Checks...${NC}"

# Flutter analyze
echo "Running Flutter analyze..."
flutter analyze || {
    echo -e "${RED}❌ Flutter analyze failed. Please fix issues before building.${NC}"
    exit 1
}
echo -e "${GREEN}✅ Flutter analyze passed${NC}"

# Run tests
echo "Running tests..."
flutter test || {
    echo -e "${RED}❌ Tests failed. Please fix failing tests before building.${NC}"
    exit 1
}
echo -e "${GREEN}✅ All tests passed${NC}"

# Step 3: Clean and Prepare
echo -e "${YELLOW}🧹 Cleaning Previous Builds...${NC}"
flutter clean
flutter pub get

# Step 4: Build for Different Platforms
echo -e "${YELLOW}🏗️ Building Production Releases...${NC}"

# Create build directory
mkdir -p "$BUILD_DIR"

# Android APK (Release)
echo -e "${BLUE}📱 Building Android APK...${NC}"
flutter build apk \
    --release \
    --target-platform android-arm64 \
    --split-per-abi \
    --tree-shake-icons \
    --split-debug-info="$BUILD_DIR/android-debug-symbols" \
    --obfuscate

# Move APK to build directory
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$BUILD_DIR/${APP_NAME}-v${VERSION}-android.apk"
echo -e "${GREEN}✅ Android APK built successfully${NC}"

# Android App Bundle (for Google Play)
echo -e "${BLUE}📱 Building Android App Bundle...${NC}"
flutter build appbundle \
    --release \
    --tree-shake-icons \
    --split-debug-info="$BUILD_DIR/android-debug-symbols" \
    --obfuscate

# Move AAB to build directory
cp build/app/outputs/bundle/release/app-release.aab "$BUILD_DIR/${APP_NAME}-v${VERSION}-android.aab"
echo -e "${GREEN}✅ Android App Bundle built successfully${NC}"

# iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${BLUE}🍎 Building iOS...${NC}"
    flutter build ios \
        --release \
        --tree-shake-icons \
        --split-debug-info="$BUILD_DIR/ios-debug-symbols" \
        --obfuscate
    echo -e "${GREEN}✅ iOS build completed${NC}"
else
    echo -e "${YELLOW}⚠️ Skipping iOS build (not on macOS)${NC}"
fi

# Web (for web deployment)
echo -e "${BLUE}🌐 Building Web...${NC}"
flutter build web \
    --release \
    --web-renderer canvaskit \
    --tree-shake-icons \
    --dart-define=FLUTTER_WEB_USE_SKIA=true

# Create web archive
cd build/web
tar -czf "../../$BUILD_DIR/${APP_NAME}-v${VERSION}-web.tar.gz" .
cd ../..
echo -e "${GREEN}✅ Web build completed${NC}"

# Step 5: Build Verification
echo -e "${YELLOW}🔍 Verifying Builds...${NC}"

# Check file sizes
echo -e "${BLUE}📊 Build Statistics:${NC}"
if [ -f "$BUILD_DIR/${APP_NAME}-v${VERSION}-android.apk" ]; then
    APK_SIZE=$(du -h "$BUILD_DIR/${APP_NAME}-v${VERSION}-android.apk" | cut -f1)
    echo "  Android APK: $APK_SIZE"
fi

if [ -f "$BUILD_DIR/${APP_NAME}-v${VERSION}-android.aab" ]; then
    AAB_SIZE=$(du -h "$BUILD_DIR/${APP_NAME}-v${VERSION}-android.aab" | cut -f1)
    echo "  Android AAB: $AAB_SIZE"
fi

if [ -f "$BUILD_DIR/${APP_NAME}-v${VERSION}-web.tar.gz" ]; then
    WEB_SIZE=$(du -h "$BUILD_DIR/${APP_NAME}-v${VERSION}-web.tar.gz" | cut -f1)
    echo "  Web Archive: $WEB_SIZE"
fi

# Step 6: Generate Release Notes
echo -e "${YELLOW}📝 Generating Release Package...${NC}"

# Create release info file
cat > "$BUILD_DIR/RELEASE_INFO.txt" << EOF
Cards App - Production Release
==============================

Version: $VERSION
Build Date: $(date)
Flutter Version: $FLUTTER_VERSION

Included Files:
- ${APP_NAME}-v${VERSION}-android.apk (Android APK)
- ${APP_NAME}-v${VERSION}-android.aab (Android App Bundle)
- ${APP_NAME}-v${VERSION}-web.tar.gz (Web Build)

Performance Optimizations:
- Logo caching with LRU eviction
- Optimized grid rendering
- Database indexing
- Tree-shaken icons
- Code obfuscation
- Split debug info

Build Features:
- Multi-architecture Android support (arm64)
- CanvasKit web renderer for better performance
- Optimized asset bundling
- Code obfuscation for security

Deployment Instructions:
1. Android: Upload AAB to Google Play Console
2. Web: Extract web.tar.gz to web server
3. iOS: Archive and upload through Xcode

For detailed release notes, see PRODUCTION_RELEASE_NOTES.md
EOF

# Create checksums for verification
echo -e "${YELLOW}🔒 Generating Checksums...${NC}"
cd "$BUILD_DIR"
shasum -a 256 * > checksums.sha256
cd ..

# Step 7: Success Summary
echo ""
echo -e "${GREEN}🎉 Production Build Complete!${NC}"
echo -e "${GREEN}✅ All builds successful${NC}"
echo -e "${GREEN}✅ Code quality checks passed${NC}"
echo -e "${GREEN}✅ Performance optimizations applied${NC}"
echo ""
echo -e "${BLUE}📦 Release Package Location: $BUILD_DIR${NC}"
echo -e "${BLUE}📋 Release Info: $BUILD_DIR/RELEASE_INFO.txt${NC}"
echo -e "${BLUE}🔒 Checksums: $BUILD_DIR/checksums.sha256${NC}"
echo ""
echo -e "${YELLOW}🚀 Ready for Production Deployment!${NC}"

# Optional: Open build directory
if command -v open &> /dev/null; then
    read -p "Open build directory? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$BUILD_DIR"
    fi
fi

echo -e "${GREEN}Build process completed successfully! 🎊${NC}"
