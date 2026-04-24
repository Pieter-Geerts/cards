#!/bin/bash

# Manual Testing Setup Script for Card Scanning
# This script helps prepare test barcodes and QR codes for manual testing

set -e

echo "🔍 Card Scanning - Manual Testing Setup"
echo "======================================="
echo ""

# Check dependencies
command -v adb >/dev/null 2>&1 || { echo "❌ adb not found. Install Android SDK tools first."; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "⚠️  python3 not found. Will skip auto-generation."; }

# Create test directory
TEST_DIR="$HOME/card_test_codes"
mkdir -p "$TEST_DIR"
echo "✅ Created test directory: $TEST_DIR"

# Check if emulator is running
if ! adb devices | grep -q "emulator"; then
    echo "❌ No Android emulator detected. Please start an emulator first:"
    echo "   emulator -avd Nexus_5X"
    exit 1
fi
echo "✅ Emulator detected"

echo ""
echo "📥 Test Code Generation"
echo "------------------------"

# Option 1: Provide Python script to generate simple test codes
cat > "$TEST_DIR/generate_test_codes.py" << 'EOF'
#!/usr/bin/env python3
"""
Generate test QR codes and barcodes for manual testing.
Requires: pip install qrcode[pil] python-barcode
"""

import os
import sys

try:
    import qrcode
    import barcode
    from barcode.writer import ImageWriter
except ImportError:
    print("❌ Missing required packages. Install with:")
    print("   pip install qrcode[pil] python-barcode")
    sys.exit(1)

# Get output directory
output_dir = os.path.expanduser("~/card_test_codes")
os.makedirs(output_dir, exist_ok=True)

print("🔧 Generating test codes in:", output_dir)
print()

# Generate QR Codes
qr_codes = [
    ("TEST_QR_SCAN_001", "test_qr_001.png"),
    ("TEST_QR_SCAN_002", "test_qr_002.png"),
    ("https://github.com/pietergeerts/cards", "test_qr_github.png"),
    ("test@example.com", "test_qr_email.png"),
]

print("📱 Generating QR Codes:")
for data, filename in qr_codes:
    try:
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(data)
        qr.make(fit=True)
        
        img = qr.make_image(fill_color="black", back_color="white")
        filepath = os.path.join(output_dir, filename)
        img.save(filepath)
        print(f"  ✅ {filename:<25} (data: {data})")
    except Exception as e:
        print(f"  ❌ {filename:<25} - Error: {e}")

print()
print("🏷️  Generating Barcodes:")

# Generate Barcodes
barcode_codes = [
    ("5901234123457", "test_barcode_ean13_001.png", "ean13"),
    ("123456789012", "test_barcode_ean12_001.png", "ean"),
    ("TEST123", "test_barcode_code128_001.png", "code128"),
]

for data, filename, barcode_format in barcode_codes:
    try:
        ean = barcode.get_barcode_class(barcode_format)
        code = ean(data, writer=ImageWriter())
        filepath = os.path.join(output_dir, filename.replace('.png', ''))
        code.save(filepath)
        print(f"  ✅ {filename:<30} (format: {barcode_format}, data: {data})")
    except Exception as e:
        print(f"  ❌ {filename:<30} - Error: {e}")

print()
print("✅ Test codes generated successfully!")
print(f"📁 Location: {output_dir}/")
print()
print("Next steps:")
print("  1. Run: bash ./setup_emulator.sh")
print("  2. Follow the manual testing guide in: MANUAL_TESTING_GUIDE.md")
EOF

chmod +x "$TEST_DIR/generate_test_codes.py"

echo "Generated Python script: $TEST_DIR/generate_test_codes.py"
echo ""

# Create emulator setup script
cat > "$TEST_DIR/setup_emulator.sh" << 'EOF'
#!/bin/bash

# Push test codes to emulator
TEST_DIR="$HOME/card_test_codes"
EMULATOR_PATH="/sdcard/Pictures/"

echo "📱 Pushing test codes to emulator..."
echo ""

# Check if files exist
if [ ! -d "$TEST_DIR" ]; then
    echo "❌ Test directory not found: $TEST_DIR"
    exit 1
fi

# Push all images to emulator
for file in "$TEST_DIR"/*.png; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Pushing: $filename"
        adb push "$file" "$EMULATOR_PATH$filename" > /dev/null 2>&1
        echo "  ✅ $filename"
    fi
done

echo ""
echo "✅ All test codes pushed to emulator"
echo "📸 Location in emulator: $EMULATOR_PATH"
echo ""
echo "Next steps:"
echo "  1. Open the app: flutter run"
echo "  2. Navigate to: Add Card → Scan from Photo"
echo "  3. Select test images from Pictures"
echo "  4. Follow test cases in MANUAL_TESTING_GUIDE.md"
EOF

chmod +x "$TEST_DIR/setup_emulator.sh"

echo "Generated emulator setup script: $TEST_DIR/setup_emulator.sh"
echo ""

# Create quick test runner
cat > "$TEST_DIR/quick_test.sh" << 'EOF'
#!/bin/bash

echo "🚀 Quick Manual Testing Checklist"
echo "=================================="
echo ""
echo "Pre-flight checks:"
echo "  ✓ Emulator running?"
echo "  ✓ Test images in ~/card_test_codes/?"
echo "  ✓ Images pushed to emulator?"
echo ""
echo "Test Cases to Run:"
echo "  1️⃣  Scan QR Code from Gallery"
echo "       - Launch app"
echo "       - Add Card → Scan from Photo"
echo "       - Select test_qr_001.png"
echo "       - Verify: Type = 'QR Code'"
echo ""
echo "  2️⃣  Scan Barcode from Gallery"
echo "       - Add Card → Scan from Photo"
echo "       - Select test_barcode_ean13_001.png"
echo "       - Verify: Type = 'Barcode'"
echo ""
echo "  3️⃣  Switch Between QR and Barcode"
echo "       - Scan QR"
echo "       - Go back"
echo "       - Scan Barcode"
echo "       - Verify both detect correctly"
echo ""
echo "  4️⃣  Temporary Card with Scan"
echo "       - Scan QR"
echo "       - Enable 'Temporary Card'"
echo "       - Set expiry: 3 days"
echo "       - Submit"
echo "       - Verify: Expiry chip visible on detail"
echo ""
echo "  5️⃣  Check Card Detail Screen"
echo "       - Verify correct code type rendered"
echo "       - QR: QrImageView visible"
echo "       - Barcode: 1D barcode visible"
echo "       - Code preview is readable"
echo ""
echo "📸 Take screenshots of:"
echo "    - QR code detail screen"
echo "    - Barcode detail screen"
echo "    - Temporary card with expiry"
echo "    - Form with auto-detected type"
echo ""
echo "📋 Validation Points:"
echo "    ✓ Card type correctly detected"
echo "    ✓ UI renders without crashes"
echo "    ✓ Form auto-fills with detected data"
echo "    ✓ Detail screen shows correct widget"
echo "    ✓ Navigation is smooth"
echo ""
echo "After testing:"
echo "    1. Run: flutter test"
echo "    2. Verify all automated tests pass"
echo "    3. Document results"
EOF

chmod +x "$TEST_DIR/quick_test.sh"

echo "Generated quick test guide: $TEST_DIR/quick_test.sh"
echo ""

echo "=================================="
echo "✅ Setup Complete!"
echo "=================================="
echo ""
echo "📁 All files in: $TEST_DIR/"
echo ""
echo "Quick Start:"
echo ""
echo "  1️⃣  Generate test codes:"
echo "       python3 $TEST_DIR/generate_test_codes.py"
echo ""
echo "  2️⃣  Push to emulator:"
echo "       bash $TEST_DIR/setup_emulator.sh"
echo ""
echo "  3️⃣  Run manual tests:"
echo "       bash $TEST_DIR/quick_test.sh"
echo ""
echo "  4️⃣  Start app:"
echo "       flutter run"
echo ""
echo "📚 For detailed test cases, see: MANUAL_TESTING_GUIDE.md"
echo ""
