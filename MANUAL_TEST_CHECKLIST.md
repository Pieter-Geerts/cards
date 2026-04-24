# 🎯 Manual Testing Checklist - Card Scanning with QR/Barcode

**Status:** ✅ Emulator Ready (emulator-5554)

---

## 📋 Pre-Flight Checklist

Before starting manual tests:

- [ ] Emulator running: `adb devices` shows your device
- [ ] Test images created/downloaded
- [ ] Images pushed to emulator: `/sdcard/Pictures/`
- [ ] No previous test data on device (optional clean slate)
- [ ] Latest app built and ready: `flutter run`

---

## 🔧 Quick Setup (5 minutes)

### 1. Download or Generate Test Images

**Option A: Quick Download from Online Generators** (Recommended - No coding needed)

Visit these websites and download test codes as PNG:

**QR Codes:** https://www.qr-code-generator.com/

- Generate with these texts:
  - `TEST_QR_001`
  - `TEST_QR_GITHUB`
  - `https://github.com/pietergeerts/cards`
- Save as: `test_qr_001.png`, `test_qr_002.png`, `test_qr_github.png`

**Barcodes:** https://barcode.tec-it.com/barcodegenerator.aspx

- Generate with these values (EAN-13, Code128):
  - `5901234123457` (EAN-13)
  - `TEST123CODE` (Code128)
- Save as: `test_barcode_ean13.png`, `test_barcode_code128.png`

### 2. Organize Files

```bash
mkdir -p ~/card_test_codes
mv ~/Downloads/test_*.png ~/card_test_codes/
```

### 3. Upload to Emulator

```bash
# Push all files at once
for f in ~/card_test_codes/*.png; do
  adb push "$f" /sdcard/Pictures/
done

# Verify
adb shell ls -la /sdcard/Pictures/
```

Expected output:

```
test_qr_001.png
test_qr_002.png
test_qr_github.png
test_barcode_ean13.png
test_barcode_code128.png
```

---

## 🧪 Test Scenarios

### Test 1: ✅ Scan QR Code from Gallery

**Setup:**

- [ ] QR image uploaded: `test_qr_001.png`
- [ ] App running: `flutter run`

**Steps:**

1. Tap **"Add Card"** button
2. Tap **"Scan from Photo"** option
3. Select **"test_qr_001.png"** from gallery
4. Tap to open/scan
5. Wait for detection (should be ~1 second)
6. Verify form populates

**Expected Results:**

- [ ] Detection message: "QR Code detected"
- [ ] Form shows code data: "TEST_QR_001"
- [ ] Card Type dropdown shows: **"QR Code"** (pre-selected)
- [ ] Preview widget shows: QR code visualization

**Actions:**

- [ ] Fill title: "Test QR Card"
- [ ] Fill description: "Manual test QR"
- [ ] Tap "Continue/Save"

**Detail Screen Validation:**

- [ ] Title displays: "Test QR Card"
- [ ] Code preview shows: "TEST_QR_001"
- [ ] Card type chip shows: **"QR Code"** ✓
- [ ] QR widget is visible and renders correctly

**Screenshots to Capture:**

- [ ] After photo selection (auto-detected form)
- [ ] Detail screen with QR code rendered
- [ ] Card list showing QR card

---

### Test 2: ✅ Scan Barcode from Gallery

**Setup:**

- [ ] Barcode image uploaded: `test_barcode_ean13.png`
- [ ] App running

**Steps:**

1. Tap **"Add Card"**
2. Tap **"Scan from Photo"**
3. Select **"test_barcode_ean13.png"**
4. Wait for detection

**Expected Results:**

- [ ] Detection message: "Barcode detected"
- [ ] Form shows code data: "5901234123457"
- [ ] Card Type dropdown shows: **"Barcode"** (pre-selected)
- [ ] Preview widget shows: 1D barcode rendering

**Actions:**

- [ ] Fill title: "Test Barcode Card"
- [ ] Fill description: "Manual barcode test"
- [ ] Tap "Continue/Save"

**Detail Screen Validation:**

- [ ] Title displays: "Test Barcode Card"
- [ ] Code displays: "5901234123457"
- [ ] Card type chip shows: **"Barcode"** ✓
- [ ] Barcode widget is visible

**Screenshots to Capture:**

- [ ] Form with auto-detected barcode type
- [ ] Detail screen with 1D barcode rendered

---

### Test 3: ✅ Type Detection Accuracy

**Setup:**

- [ ] Multiple test images uploaded
- [ ] App running

**Steps:**

1. Scan `test_qr_002.png` → Verify type = "QR Code"
2. Go back to home
3. Scan `test_barcode_code128.png` → Verify type = "Barcode"
4. Go back
5. Repeat 2-3 times

**Expected Results:**

- [ ] Each scan detects correct type
- [ ] No type confusion
- [ ] Form always pre-selects correct type
- [ ] Previous scan data doesn't bleed over

**Validation:**

- [ ] ✅ Type detection is 100% accurate
- [ ] ✅ No data persistence issues
- [ ] ✅ UI is responsive between scans

---

### Test 4: ✅ Temporary Card with Expiry

**Setup:**

- [ ] QR image uploaded
- [ ] App running

**Steps:**

1. Scan QR code
2. In form, locate "Temporary Card" toggle
3. Enable the toggle
4. Set expiry: **"3 days"** (or use date picker)
5. Fill title and description
6. Save

**Expected Results:**

- [ ] Card marked as temporary
- [ ] Expiry date calculated: Today + 3 days
- [ ] Hourglass icon appears on card list

**Detail Screen Validation:**

- [ ] Expiry chip visible: "Expires on [date]"
- [ ] Chip styling: Tertiarycontainer color
- [ ] Date is readable and accurate
- [ ] QR code displays correctly

**Screenshots to Capture:**

- [ ] Form with "Temporary Card" toggle enabled
- [ ] Detail screen showing expiry chip
- [ ] Card list with hourglass icon

---

### Test 5: ✅ Navigation & Editing

**Setup:**

- [ ] Scanned card saved to list
- [ ] App running

**Steps:**

1. View card list
2. Tap on saved QR card
3. On detail screen, tap "Edit" button
4. Change title to "Updated QR Card"
5. Tap "Save"
6. Verify card list updated

**Expected Results:**

- [ ] Navigation is smooth
- [ ] Edit screen shows current data
- [ ] Changes persist
- [ ] No crashes or UI glitches

**Validation:**

- [ ] ✅ Edit functionality works
- [ ] ✅ Title updated in list
- [ ] ✅ Detail screen reflects changes

---

### Test 6: ✅ Error Handling

**Setup:**

- [ ] Any non-code image in gallery
- [ ] App running

**Steps:**

1. Tap "Add Card" → "Scan from Photo"
2. Select random image (no code)
3. Wait for detection attempt
4. Note app behavior

**Expected Results:**

- [ ] App doesn't crash
- [ ] Error message shown: "No barcode detected"
- [ ] Can try again with different image

**Validation:**

- [ ] ✅ Graceful error handling
- [ ] ✅ No force closes
- [ ] ✅ User can retry

---

## 📊 Results Summary

After completing all tests, fill in:

| Test # | Scenario          | QR Works | Barcode Works | UI Issues | Notes |
| ------ | ----------------- | -------- | ------------- | --------- | ----- |
| 1      | Scan from Gallery | ✓/✗      | -             | -         |       |
| 2      | Scan Barcode      | -        | ✓/✗           | -         |       |
| 3      | Type Detection    | ✓/✗      | ✓/✗           | -         |       |
| 4      | Temporary Card    | ✓/✗      | -             | -         |       |
| 5      | Edit Card         | ✓/✗      | ✓/✗           | -         |       |
| 6      | Error Handling    | ✓/✗      | ✓/✗           | -         |       |

---

## 📸 Required Screenshots

Capture these for documentation:

- [ ] QR code form (auto-filled with detected data)
- [ ] QR code detail screen
- [ ] Barcode form (auto-filled)
- [ ] Barcode detail screen
- [ ] Temporary card with expiry chip
- [ ] Error message for invalid image
- [ ] Card list with both types

---

## 🚀 Commands Quick Reference

```bash
# Start emulator (if not running)
emulator -avd Nexus_5X &

# Verify connection
adb devices

# Check uploaded files
adb shell ls -la /sdcard/Pictures/

# Clear app data (for fresh test)
adb shell pm clear com.pietergeerts.cards

# Start app
flutter run

# View logs in real-time
adb logcat | grep -i flutter
```

---

## ✅ Completion Checklist

- [ ] All 6 test scenarios executed
- [ ] Screenshots captured
- [ ] No critical bugs found
- [ ] App is responsive
- [ ] Type detection is accurate
- [ ] Navigation is smooth
- [ ] Temporary cards show expiry correctly
- [ ] Error handling is graceful

---

## 📝 Notes & Observations

```
Test Date: 2026-04-17
Tester: Manual QA Engineer

Observations:
-
-
-

Bugs Found (if any):
-

Performance Notes:
-

UI/UX Feedback:
-
```

---

## 🎯 Next Steps

After manual testing:

1. **Compare with automated tests:**

   ```bash
   flutter test integration_test/scan_code_type_flows_test.dart
   ```

2. **Verify all unit tests pass:**

   ```bash
   flutter test test/services/card_expiry_service_test.dart
   flutter test test/models/card_item_test.dart
   ```

3. **Document results** in JIRA/issue tracker

4. **Mark this test pass** in QA checklist

---

## 📚 Supporting Documentation

- [Detailed Testing Guide](MANUAL_TESTING_GUIDE.md)
- [Setup Script](setup_manual_testing.sh)
- [Test Infrastructure Scripts](https://github.com/pietergeerts/cards/scripts)

---

**Status: Ready for Manual Testing ✅**  
**Emulator: Connected ✅**  
**Pictures Directory: Ready ✅**  
**Test Images: Waiting for upload ⏳**

Good luck with your manual testing! 🚀
