# 🚀 Manual Testing - Ready-to-Use Test Codes

**You can start testing RIGHT NOW without generating any codes!**

---

## 📱 Public QR Codes You Can Test With

### 1. GitHub QR Code

**Content:** GitHub repository link  
**Data:** `https://github.com/pietergeerts/cards`  
**How to get it:**

```bash
# Use this URL in browser, it generates a QR code automatically
open "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://github.com/pietergeerts/cards"
```

To download and use:

```bash
curl -o ~/card_test_codes/test_qr_github.png \
  "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://github.com/pietergeerts/cards"
```

### 2. Simple Text QR Code

**Content:** "TEST_QR_SCAN_001"  
**How to get it:**

```bash
curl -o ~/card_test_codes/test_qr_001.png \
  "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=TEST_QR_SCAN_001"
```

### 3. Email QR Code

**Content:** "test@example.com"  
**How to get it:**

```bash
curl -o ~/card_test_codes/test_qr_email.png \
  "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=test@example.com"
```

---

## 🏷️ Public Barcodes You Can Test With

### Real Product Barcodes (EAN-13/UPC-A)

These are REAL barcodes from actual products:

```
ISBN Barcodes (from any book):
  9780134685991 - Clean Code book
  9781491949986 - Real book ISBN

Common Product Codes:
  5901234123457 - (Test EAN-13)
  012000000019  - (Real UPC-A)
  073513379581  - (Real barcode)
```

### Generate Custom Barcodes Online

```bash
# EAN-13 barcode generator
open "https://barcode.tec-it.com/en/barcodeimage?data=5901234123457&style=199&mode=bidi&font=OCR-A"

# Code128 barcode generator
open "https://barcode.tec-it.com/en/barcodeimage?data=TEST123CODE&style=199&mode=bidi"
```

---

## ⚡ Super Quick Setup (2 minutes)

### Run this in your terminal:

```bash
#!/bin/bash

# 1. Create test directory
mkdir -p ~/card_test_codes

# 2. Download QR codes using curl
echo "⬇️  Downloading QR codes..."
curl -o ~/card_test_codes/test_qr_001.png \
  "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=TEST_QR_SCAN_001"

curl -o ~/card_test_codes/test_qr_github.png \
  "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https://github.com/pietergeerts/cards"

curl -o ~/card_test_codes/test_qr_email.png \
  "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=test@example.com"

echo "✅ QR codes downloaded"

# 3. Push to emulator
echo "📤 Uploading to emulator..."
adb push ~/card_test_codes/test_qr_001.png /sdcard/Pictures/
adb push ~/card_test_codes/test_qr_github.png /sdcard/Pictures/
adb push ~/card_test_codes/test_qr_email.png /sdcard/Pictures/

echo "✅ Files uploaded to emulator!"

# 4. Verify
echo "📋 Verification:"
adb shell ls -la /sdcard/Pictures/
```

**Copy-paste the commands above into your terminal!**

---

## 🎬 Now Test It!

### Step 1: Start the app

```bash
flutter run
```

### Step 2: Test QR Code Scanning

1. Tap **"Add Card"**
2. Tap **"Scan from Photo"** (or gallery icon)
3. Your screen should show Pictures folder with:
   - `test_qr_001.png`
   - `test_qr_github.png`
   - `test_qr_email.png`
4. Select `test_qr_001.png`
5. **Expected:** Form auto-fills with "TEST_QR_SCAN_001"
6. **Verify:** Card Type dropdown shows **"QR Code"**
7. Fill title: "Test QR" and save

### Step 3: Verify Detail Screen

- QR code is rendered and visible
- Code preview shows "TEST_QR_SCAN_001"
- Card type chip shows "QR Code"

### Step 4: Repeat with GitHub QR

- Scan `test_qr_github.png`
- Should detect: "https://github.com/pietergeerts/cards"
- Verify same results

---

## 📊 Testing Matrix (Manual CheckOff)

| Test           | Command              | Expected                      | Result |
| -------------- | -------------------- | ----------------------------- | ------ |
| QR Detection   | Scan test_qr_001.png | Form shows "TEST_QR_SCAN_001" | ✓/✗    |
| Type Detection | Form loads           | Card Type = "QR Code"         | ✓/✗    |
| Detail Render  | Tap card in list     | QR widget visible             | ✓/✗    |
| Multiple Scans | Scan 3 different QR  | All detect correctly          | ✓/✗    |
| No Data Bleed  | Switch scans         | Previous data cleared         | ✓/✗    |

---

## 🐛 Troubleshooting

### "File not found in Pictures"

```bash
# Check what's in Pictures
adb shell ls -la /sdcard/Pictures/

# If empty, re-push
adb push ~/card_test_codes/*.png /sdcard/Pictures/
```

### "Gallery doesn't show pictures"

```bash
# Refresh gallery on emulator
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
  -d file:///sdcard/Pictures/
```

### "QR code not detected by app"

- Check image quality: Should be PNG/JPEG, not corrupted
- Check dimensions: Should be at least 200x200px
- Try a different QR code generator

---

## 🎯 Real World Test Barcodes

If you have physical products, you can also test with:

- **ISBN barcodes** from books
- **Product barcodes** from packages
- **Your own generated codes** using QR code generators

---

## ✅ Verification Commands

```bash
# List all test files
ls -la ~/card_test_codes/

# Check file sizes (should be > 1KB)
du -h ~/card_test_codes/*.png

# Verify on emulator
adb shell ls -lh /sdcard/Pictures/

# Open emulator file browser
adb shell am start -n com.android.fileexplorer/.FileExplorer
```

---

## 📝 Test Log Template

```
Date: 2026-04-17
Tester: [Your Name]

QR Codes Tested:
  ✓ test_qr_001.png - "TEST_QR_SCAN_001"
  ✓ test_qr_github.png - GitHub URL
  ✓ test_qr_email.png - Email address

Results:
  - QR detection: PASS / FAIL
  - Type auto-selection: PASS / FAIL
  - Detail screen rendering: PASS / FAIL
  - UI responsiveness: PASS / FAIL

Issues Found:
  - [None] / [List any bugs]

Performance:
  - Scan detection time: ~1 second
  - Form population time: <500ms
  - Navigation smoothness: Smooth / Laggy

Overall Assessment: ✅ PASS / ❌ FAIL
```

---

## 🚀 Next: Automated Testing

After manual testing confirms everything works, run automated tests:

```bash
# Scan-type detection tests
flutter test integration_test/scan_code_type_flows_test.dart

# Expiry and deletion tests
flutter test test/services/card_expiry_service_test.dart

# All tests
flutter test
```

---

## 📚 Documentation Files

- [Detailed Manual Testing Guide](MANUAL_TESTING_GUIDE.md)
- [Manual Test Checklist](MANUAL_TEST_CHECKLIST.md)
- [Setup Script](setup_manual_testing.sh)
- Integration test code: [scan_code_type_flows_test.dart](integration_test/scan_code_type_flows_test.dart)

---

**Ready? Let's test! 🎮**

```bash
# All-in-one command to:
# 1. Download test codes
# 2. Push to emulator
# 3. Show verification

mkdir -p ~/card_test_codes && \
curl -s -o ~/card_test_codes/test_qr_001.png \
  "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=TEST_QR_SCAN_001" && \
curl -s -o ~/card_test_codes/test_qr_github.png \
  "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https://github.com/pietergeerts/cards" && \
adb push ~/card_test_codes/*.png /sdcard/Pictures/ && \
echo "✅ All set! Run: flutter run" && \
adb shell ls -la /sdcard/Pictures/
```

Copy-paste that single command and you're ready to start testing! 🎯
