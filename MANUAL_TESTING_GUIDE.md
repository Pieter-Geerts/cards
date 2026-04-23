# Manual Testing Guide - Barcode/QR Code Scanning

## Finding Test Images

### QR Code Resources

1. **QR Code Generator** (Free): https://www.qr-code-generator.com/
   - Generate QR codes with text like "TEST_QR_001", "TEST_QR_002", etc.
   - Download as PNG images
   - Recommended text patterns:
     - Simple: TEST_QR_001, TEST_QR_002
     - URLs: https://example.com/test
     - Product codes: 8606001234567

2. **ZXing Barcode Generator**: https://zxing.appspot.com/
   - Generates various barcode formats
   - Supports: UPC-A, EAN-13, Code128, etc.
   - Download test codes for different formats

3. **Public QR Code Gallery**: https://www.qr-code-generator.com/qr-code-gallery/
   - Real-world QR code examples

### Barcode Resources

1. **EAN-13 Barcodes**: Common product codes
   - Example: 5901234123457 (ISBN-13 format)
   - Generate using: https://www.barcode-generator.org/

2. **Code128 Barcodes**: Universal format
   - Easy to generate
   - More flexible encoding

3. **From Products You Have**
   - Photography books (ISBN barcodes)
   - Product packaging
   - Business cards with QR codes

## Setup Steps

### Step 1: Generate Test Images

```bash
# Create test directory
mkdir -p ~/test_codes
cd ~/test_codes

# Option 1: Manual Download
# - Visit https://www.qr-code-generator.com/
# - Generate QR code with text: "TEST_QR_SCAN_001"
# - Save as test_qr_001.png
# - Repeat for 3-5 different codes
```

### Step 2: Push Images to Emulator

```bash
adb push ~/test_codes/test_qr_001.png /sdcard/Pictures/test_qr_001.png
adb push ~/test_codes/test_qr_002.png /sdcard/Pictures/test_qr_002.png
adb push ~/test_codes/test_barcode_001.png /sdcard/Pictures/test_barcode_001.png
```

### Step 3: Launch App on Emulator

```bash
flutter run
```

## Manual Test Cases

### Test 1: Scan QR Code from Photo

**Prerequisite:** Have QR code image (test_qr_001.png) in emulator gallery

**Steps:**

1. Launch app
2. Tap "Add Card" → "Scan from Photo" (or Camera button)
3. Select test_qr_001.png from gallery
4. **Expected:**
   - Barcode detected
   - Form pre-fills with QR code data
   - Card Type shows "QR Code"
   - Preview shows detected data

**Validation Points:**

- [ ] QR code is correctly decoded
- [ ] CardType is set to `qrCode`
- [ ] Detected text appears in preview
- [ ] "Continue" button is enabled

---

### Test 2: Scan Barcode from Photo

**Prerequisite:** Have barcode image (test_barcode_001.png) in gallery

**Steps:**

1. Launch app
2. Tap "Add Card" → "Scan from Photo"
3. Select test_barcode_001.png
4. **Expected:**
   - Barcode detected
   - Form pre-fills with barcode data
   - Card Type shows "Barcode"

**Validation Points:**

- [ ] Barcode is correctly decoded (numeric data extracted)
- [ ] CardType is set to `barcode`
- [ ] Detected value appears in preview
- [ ] Format automatically detected (1D vs 2D)

---

### Test 3: Multiple Scans - QR vs Barcode

**Prerequisite:** Have both QR and barcode images

**Steps:**

1. Scan QR code → Verify type is "QR Code"
2. Tap Back
3. Scan barcode → Verify type is "Barcode"
4. Tap Back
5. Repeat with different scans

**Validation Points:**

- [ ] App correctly switches between QR and barcode modes
- [ ] No cached data from previous scan
- [ ] Type selector updates correctly each time
- [ ] Navigation works smoothly

---

### Test 4: Invalid/Corrupted Images

**Prerequisite:** Have corrupted/non-readable image

**Steps:**

1. Save random image (no code) to gallery
2. Tap "Add Card" → "Scan from Photo"
3. Select random image
4. **Expected:**
   - Error message or "no code detected"
   - Can retry with different image

**Validation Points:**

- [ ] App handles no-detection gracefully
- [ ] No crash
- [ ] User can try again

---

### Test 5: Create Temporary Card with Scan

**Steps:**

1. Scan QR code
2. In form, enable "Temporary Card" toggle
3. Set "Expires in: 3 days"
4. Fill title, description
5. Submit
6. Navigate to detail screen

**Validation Points:**

- [ ] Card saved with expiry date
- [ ] Detail screen shows expiry chip
- [ ] Format: "Expires on [date]"
- [ ] Hourglass icon visible on card list

---

### Test 6: Edit Scanned Card

**Steps:**

1. Scan and save a card
2. On detail screen, tap "Edit"
3. Change title
4. Re-scan different QR code
5. Verify data updates

**Validation Points:**

- [ ] Edit preserves card ID
- [ ] Re-scan updates code data
- [ ] Card type updates if code format changes
- [ ] Changes saved correctly

---

### Test 7: Camera Live Scan (Optional)

**If live camera scanning works:**

**Steps:**

1. Tap "Add Card" → "Scan" (live camera)
2. Point camera at QR code in book/product
3. Hold steady
4. **Expected:** Auto-detection after 1-2 seconds

**Validation Points:**

- [ ] Live camera is responsive
- [ ] QR code detected in real-time
- [ ] Form populates automatically
- [ ] No lag or freezing

---

## Detailed Test Matrix

| Test             | QR Code | Barcode | Expected Result       | Status |
| ---------------- | ------- | ------- | --------------------- | ------ |
| Photo Scan       | ✓       | -       | Type = "QR Code"      | [ ]    |
| Photo Scan       | -       | ✓       | Type = "Barcode"      | [ ]    |
| Multiple Scans   | ✓→✓     | -       | Both detected         | [ ]    |
| Multiple Scans   | ✓       | ✓→✓     | Type switches         | [ ]    |
| Invalid Image    | ✗       | -       | No crash, error shown | [ ]    |
| Temporary + Scan | ✓       | -       | Expiry chip visible   | [ ]    |
| Edit + Re-scan   | ✓       | -       | Code updated          | [ ]    |

## Visual Verification Checklist

### QR Code Specific

- [ ] QrImageView widget renders in detail screen
- [ ] QR code displays correctly
- [ ] Can be scanned with external reader
- [ ] Size is appropriate (not too small)

### Barcode Specific

- [ ] BarcodeWidget renders in detail screen
- [ ] Barcode is scannable
- [ ] Digits displayed clearly
- [ ] 1D format layout is compact

### Common UI Elements

- [ ] Card type chip shows correct label
- [ ] Temporary card expiry chip appears/disappears
- [ ] Code preview in form is readable
- [ ] Share button works
- [ ] Delete button works
- [ ] Screen transitions are smooth

## Recommended Test Barcodes

### QR Codes (Use QR Code Generator)

1. **Simple Text**: TEST_QR_SCAN_001
2. **URL**: https://github.com/pietergeerts/cards
3. **Email**: test@example.com
4. **Phone**: +31612345678
5. **WiFi**: WIFI:T:WPA;S:TestNetwork;P:Password;;

### Barcodes (Use Barcode Generator)

1. **EAN-13**: 5901234123457
2. **UPC-A**: 123456789012
3. **Code128**: TEST123CODE
4. **ISBNv13**: 9780134685991 (real ISBN)

## Troubleshooting

### QR Code Not Detected

- Ensure good lighting
- Check image quality (not compressed/pixelated)
- Try different QR code generator
- Verify image file format is PNG/JPEG

### Barcode Not Detected

- Ensure barcode is clear and not skewed
- Try EAN-13 format (most standard)
- Check contrast (dark bars on white background)
- Regenerate using barcode-generator.org

### App Crashes During Scan

- Check logcat: `adb logcat | grep -i flutter`
- Verify image file isn't corrupted
- Restart emulator: `adb emu kill && emulator -avd Nexus_5X -no-snapshot`

## Automated Test Commands (Post-Manual)

After manual validation, run automated tests:

```bash
# Run integration tests
flutter test integration_test/scan_code_type_flows_test.dart -v

# Run service tests
flutter test test/services/card_expiry_service_test.dart -v

# Run all tests
flutter test
```

## Documentation for Results

After testing, document:

1. Screenshots of each test scenario
2. QR/barcode images used
3. Observations (timing, responsiveness, UI clarity)
4. Any edge cases discovered
5. Performance notes

Example log entry:

```
Test: Scan QR from Gallery
Date: 2026-04-17
Result: ✅ PASS
- QR detected correctly
- Form populated with "TEST_QR_SCAN_001"
- CardType set to "qrCode"
- No crashes or delays
- Detail screen rendered properly
```
