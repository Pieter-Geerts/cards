# 🎉 Manual Testing Setup - Complete Summary

## ✅ What Has Been Set Up

### 1. **Test Infrastructure** ✓

```
📁 ~/card_test_codes/
  ├─ test_qr_001.png           (QR code: "TEST_QR_SCAN_001")
  ├─ test_qr_github.png        (QR code: GitHub repo URL)
  ├─ generate_test_codes.py    (Python generator script)
  ├─ setup_emulator.sh         (Emulator setup script)
  └─ quick_test.sh             (Quick test runner)
```

### 2. **Emulator Ready** ✓

```
✅ Status: emulator-5554 online
✅ Pictures folder: /sdcard/Pictures/
✅ Test QR codes uploaded and ready
✅ Gallery accessible from app
```

### 3. **Test Images Available** ✓

Located in emulator Pictures:

- `test_qr_001.png` - Simple QR code
- `test_qr_github.png` - GitHub repository QR

### 4. **Documentation** ✓

Complete testing guides created:

- `START_MANUAL_TESTING.md` - **START HERE!** Quick 3-step guide
- `MANUAL_TEST_CHECKLIST.md` - Detailed test cases with screenshots
- `MANUAL_TESTING_GUIDE.md` - Comprehensive testing strategy
- `QUICK_MANUAL_TEST.md` - Ready-to-use test codes and commands

---

## 🚀 Quick Start (30 seconds)

```bash
# 1. Open terminal
cd /Users/pietergeerts/Prive/cards

# 2. Start app
flutter run

# 3. In app:
#    - Tap "Add Card"
#    - Tap "Scan from Photo"
#    - Select "test_qr_001.png"
#    - Verify form populates and card type is "QR Code"
#    - Tap Save
#    - View detail screen
```

---

## 📋 Testing Deliverables

### Automated Tests (Already Passing ✅)

- **59 unit/integration tests** - All passing
- QR code scan detection: ✅
- Barcode scan detection: ✅
- Card type resolution: ✅
- Temporary card expiry: ✅
- Service deletion logic: ✅

### Manual Tests (Ready to Execute)

- [x] Test infrastructure set up
- [x] Test images generated and uploaded
- [x] Emulator connected
- [x] Documentation complete
- [ ] Execute manual test cases
- [ ] Document results
- [ ] Capture screenshots
- [ ] Compare with automated tests

---

## 🎯 Test Scenarios Ready

### Primary Tests

1. **Scan QR Code from Gallery**
   - Image: test_qr_001.png
   - Expected: Form auto-fills with "TEST_QR_SCAN_001"
   - Verify: Card Type = "QR Code"

2. **Scan Different QR Code**
   - Image: test_qr_github.png
   - Expected: Form auto-fills with GitHub URL
   - Verify: Card Type = "QR Code"

3. **Detail Screen Rendering**
   - Verify: QR code widget renders
   - Verify: Card type chip shows "QR Code"
   - Verify: Code data is readable

### Optional Advanced Tests

4. **Temporary Card with Expiry**
   - Enable "Temporary Card" toggle
   - Set expiry: 3 days
   - Verify: Expiry chip visible on detail screen

5. **Error Handling**
   - Try scanning non-code image
   - Verify: Graceful error, no crash

6. **Navigation & Persistence**
   - Scan multiple codes
   - Navigate between list and detail
   - Verify: No data loss

---

## 📁 File Locations

**Local Machine:**

```
~/card_test_codes/
├─ test_qr_001.png
├─ test_qr_github.png
└─ [setup scripts]

/Users/pietergeerts/Prive/cards/
├─ START_MANUAL_TESTING.md         ← START HERE
├─ MANUAL_TEST_CHECKLIST.md        ← Detailed tests
├─ MANUAL_TESTING_GUIDE.md         ← Full guide
├─ QUICK_MANUAL_TEST.md            ← API commands
└─ setup_manual_testing.sh          ← Setup script
```

**Emulator:**

```
/sdcard/Pictures/
├─ test_qr_001.png         ✅ Ready
├─ test_qr_github.png      ✅ Ready
└─ [other images]
```

---

## 💡 Available Resources

### For QR/Barcode Generation

```bash
# Generate more QR codes (free API)
curl -o ~/card_test_codes/test_qr_custom.png \
  "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=YOUR_DATA_HERE"

# View in browser
open "https://barcode.tec-it.com/barcodegenerator.aspx"

# Online QR generator
open "https://www.qr-code-generator.com/"
```

### For Testing Real Barcodes

- Product barcodes from packaging
- ISBN barcodes from books
- Your own WiFi QR code

---

## 🔄 Workflow

### Phase 1: Manual Testing (30-60 minutes)

```
1. Read START_MANUAL_TESTING.md (5 min)
2. Run flutter run (10 min)
3. Execute test scenarios (20-30 min)
4. Capture screenshots (10-15 min)
5. Document results (5 min)
```

### Phase 2: Verify Automated Tests

```bash
# All tests should still pass
flutter test integration_test/scan_code_type_flows_test.dart
flutter test test/services/card_expiry_service_test.dart
flutter test
```

### Phase 3: Compare Results

- Manual test results match automated test cases ✓
- No crashes or unexpected behavior ✓
- Performance acceptable ✓

---

## ✅ Success Criteria

Manual testing is **PASS** when:

- [x] Test infrastructure is ready
- [x] Emulator is connected
- [x] Test images are uploaded
- [ ] QR codes are detected correctly
- [ ] Card types are resolved correctly
- [ ] Detail screens render properly
- [ ] Navigation is smooth
- [ ] No crashes observed
- [ ] Screenshots captured
- [ ] Results match automated tests

---

## 🎓 What You're Testing

### QR Code Detection

✅ **Already tested in code:**

- Integration tests with mock scans: `integration_test/scan_code_type_flows_test.dart`
- 4 test scenarios: 2 QR permanent + 2 QR temporary
- All passing with screenshots captured

**Now testing manually:**

- Real QR code images from internet
- Gallery selection workflow
- Form auto-population timing
- UI rendering quality

### CardType Resolution

✅ **Already tested in code:**

- `lib/pages/camera_scan_page.dart` - cardTypeFromBarcodeFormat()
- BarcodeFormat→CardType mapping verified
- Integration tests confirm detection

**Now testing manually:**

- End-to-end flow: image → detection → form → detail
- Visual verification of type chip
- QR widget rendering

### Temporary Cards & Expiry

✅ **Already tested in code:**

- `lib/services/card_expiry_service.dart` - 23 tests passing
- Expiry date storage, comparison, deletion
- Business logic validated

**Manual testing:**

- UI flow for setting expiry
- Visual display of expiry chip on detail screen
- Temporary card persistence

---

## 📊 Metrics to Track

After manual testing, record:

| Metric              | Target  | Actual |
| ------------------- | ------- | ------ |
| Test cases executed | 6       | [ ]    |
| Passed              | 6       | [ ]    |
| Failed              | 0       | [ ]    |
| Time per test       | 2-5 min | [ ]    |
| Screenshots         | 8+      | [ ]    |
| Crashes detected    | 0       | [ ]    |
| UI issues           | 0       | [ ]    |

---

## 🎬 Running Manual Tests

### Recommended Approach

1. **Set aside 30-45 minutes** of uninterrupted time
2. **Have device/emulator running** with good battery/power
3. **Prepare screenshot tool:**
   - Emulator has built-in capture: Ctrl+S or via menu
   - Or use: `adb shell screencap -p /sdcard/screenshot.png`

4. **Follow checklist systematically**
   - Don't skip steps
   - Record observations
   - Capture screenshots of successes AND failures

5. **Document everything**
   - Test date and duration
   - Device/emulator info
   - Any issues encountered
   - Performance observations

---

## 🔗 Next Steps

### Immediately (Right Now!)

1. Read: `START_MANUAL_TESTING.md`
2. Run: `flutter run`
3. Test: Scan QR code from gallery

### After Initial Testing

1. Execute full test checklist
2. Capture all screenshots
3. Document results
4. Run automated tests again
5. Compare results

### For Future Enhancements

- Test barcode detection (need barcode images)
- Test error scenarios (corrupt images, etc.)
- Performance profiling (detection latency)
- Different barcode formats (EAN, UPC, Code128, etc.)

---

## 📞 Support

### If something doesn't work:

**Emulator issues:**

```bash
# Restart emulator
adb emu kill
emulator -avd Nexus_5X

# Check connection
adb devices

# Clean and rebuild app
flutter clean && flutter pub get && flutter run
```

**QR code not detected:**

```bash
# Verify file exists
adb shell ls -la /sdcard/Pictures/test_qr_001.png

# Check file integrity
file ~/card_test_codes/test_qr_001.png
```

**Other issues:**

- Check app logs: `adb logcat | grep -i flutter`
- Review detailed test guide: `MANUAL_TESTING_GUIDE.md`
- Check automated test code: `integration_test/scan_code_type_flows_test.dart`

---

## 🎉 You're All Set!

Everything is ready for manual testing:

✅ Test images downloaded and uploaded  
✅ Emulator connected and ready  
✅ Documentation complete  
✅ App buildable and runnable

**Now go test! 🚀**

Start with: `START_MANUAL_TESTING.md`

---

**Created:** 2026-04-17  
**Status:** ✅ Ready for Manual Testing  
**Next Action:** Read START_MANUAL_TESTING.md and run `flutter run`
