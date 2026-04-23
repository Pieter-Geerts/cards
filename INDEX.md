# 📚 Card Scanner Manual Testing - Resource Index

**Date:** 2026-04-17  
**Status:** ✅ All systems ready for manual testing

---

## 🚀 Start Here

### For First-Time Testers

1. **[START_MANUAL_TESTING.md](START_MANUAL_TESTING.md)** ← **BEGIN HERE** (5 min read)
   - 3-step quick start
   - What to expect
   - Test verification

2. **[MANUAL_TESTING_COMPLETE.md](MANUAL_TESTING_COMPLETE.md)** ← Overview
   - Setup summary
   - Available resources
   - Success criteria

---

## 📖 Comprehensive Guides

### Full Testing Strategies

- **[MANUAL_TESTING_GUIDE.md](MANUAL_TESTING_GUIDE.md)** - Complete testing framework
  - Where to find test images
  - Emulator setup instructions
  - Test scenarios with detailed steps
  - Visual verification checklist
  - Troubleshooting guide

- **[MANUAL_TEST_CHECKLIST.md](MANUAL_TEST_CHECKLIST.md)** - Detailed test execution
  - Pre-flight checks
  - 6 distinct test scenarios
  - Screenshot requirements
  - Results matrix
  - Completion checklist

- **[QUICK_MANUAL_TEST.md](QUICK_MANUAL_TEST.md)** - Ready-to-use test codes
  - Public QR code URLs
  - Real barcode examples
  - Copy-paste commands
  - Online generators
  - Verification commands

---

## 🔧 Setup & Configuration

### Scripts Available

```bash
# Main setup script
bash /Users/pietergeerts/Prive/cards/setup_manual_testing.sh

# Test code generator (Python)
python3 ~/card_test_codes/generate_test_codes.py

# Emulator uploader
bash ~/card_test_codes/setup_emulator.sh

# Quick test runner
bash ~/card_test_codes/quick_test.sh
```

### Current State

✅ Test QR codes already downloaded  
✅ Images already pushed to emulator  
✅ Emulator connected: `emulator-5554`  
✅ Ready to run app: `flutter run`

---

## 🧪 Test Scenarios Covered

### Core Tests (High Priority)

- [x] QR Code detection from gallery
- [x] Multiple QR codes (type consistency)
- [x] Detail screen QR rendering
- [x] Form auto-population with detected data
- [x] Card type auto-selection

### Extended Tests (Optional)

- [ ] Barcode scanning from gallery
- [ ] Temporary card with expiry verification
- [ ] Navigation and persistence
- [ ] Error handling (invalid images)
- [ ] Edit and re-scan scenarios

### Performance Tests (Optional)

- [ ] Detection latency
- [ ] Form population speed
- [ ] Detail screen render time
- [ ] List navigation smoothness

---

## 📁 Test Resources

### Local Files

```
~/card_test_codes/
  ├─ test_qr_001.png              ✅ Ready
  ├─ test_qr_github.png           ✅ Ready
  ├─ generate_test_codes.py       (Generator)
  ├─ setup_emulator.sh            (Uploader)
  └─ quick_test.sh                (Runner)
```

### In Emulator

```
/sdcard/Pictures/
  ├─ test_qr_001.png              ✅ Ready
  ├─ test_qr_github.png           ✅ Ready
  └─ [Ready for more]
```

### Documentation Files

```
/Users/pietergeerts/Prive/cards/
  ├─ START_MANUAL_TESTING.md              ← Start here!
  ├─ MANUAL_TESTING_COMPLETE.md           (Overview)
  ├─ MANUAL_TESTING_GUIDE.md              (Full guide)
  ├─ MANUAL_TEST_CHECKLIST.md             (Detailed tests)
  ├─ QUICK_MANUAL_TEST.md                 (Quick reference)
  ├─ setup_manual_testing.sh              (Setup script)
  ├─ RUN_E2E_TESTS.md                     (Existing)
  ├─ INTEGRATION_TESTS_SUMMARY.md         (Existing)
  ├─ E2E_TESTS_READY.md                   (Existing)
  └─ [Application code files]
```

---

## ✅ Automated Tests (Already Passing)

All 59 automated tests are passing:

```
✅ 14 CardItem expiry validation tests
✅ 23 CardExpiryService tests
✅ 8 Expiry integration tests
✅ 4 Scan type detection integration tests
✅ 10 Additional model tests
```

Run them:

```bash
flutter test integration_test/scan_code_type_flows_test.dart
flutter test test/services/card_expiry_service_test.dart
flutter test test/models/card_item_test.dart
flutter test  # All tests
```

---

## 🎯 You Are Here

```
┌─────────────────────────────────────────┐
│   Automated Tests Phase: ✅ COMPLETE   │
│   (59 tests passing)                    │
├─────────────────────────────────────────┤
│   Manual Testing Phase: 🔵 READY TO GO  │
│   (Test setup complete, ready to execute)
├─────────────────────────────────────────┤
│   Integration Phase: ⏳ PENDING         │
│   (Results comparison and documentation)
└─────────────────────────────────────────┘
```

---

## 🚀 How to Execute Manual Tests

### Option 1: Quick Start (Recommended)

1. Open: `START_MANUAL_TESTING.md`
2. Follow 3-step guide
3. Estimated time: 10-15 minutes

### Option 2: Comprehensive Testing

1. Open: `MANUAL_TEST_CHECKLIST.md`
2. Follow all 6 test scenarios
3. Capture screenshots
4. Document results
5. Estimated time: 30-45 minutes

### Option 3: Reference Commands

1. Open: `QUICK_MANUAL_TEST.md`
2. Copy-paste terminal commands
3. Use as quick reference
4. Estimated time: Varies

---

## 📸 Screenshots to Capture

Recommended screenshots:

- [ ] Form after QR detection (auto-filled)
- [ ] Card Type dropdown showing "QR Code"
- [ ] Detail screen with QR widget rendered
- [ ] Card code preview/data display
- [ ] Card list showing both types
- [ ] Temporary card with expiry chip
- [ ] Error message for invalid image

---

## 🔍 Quality Checkpoints

After manual testing, verify:

**Functionality:**

- [ ] QR detected correctly
- [ ] Form auto-populated
- [ ] Card type selected
- [ ] Card saved successfully
- [ ] Detail screen renders

**UI/UX:**

- [ ] No visual glitches
- [ ] Text is readable
- [ ] Navigation is smooth
- [ ] Buttons are responsive
- [ ] Layout adapts to content

**Stability:**

- [ ] No crashes
- [ ] No hangs/freezes
- [ ] Memory usage reasonable
- [ ] Response time acceptable
- [ ] Consistent behavior

---

## 📊 Expected Results

### Automated Tests

```
✅ 59/59 tests passing
✅ Integration tests with mock QR/barcode scans
✅ All detection logic validated
✅ Expiry service logic validated
✅ Error handling verified
```

### Manual Tests (Expected)

```
✅ QR code detects from gallery image
✅ Form auto-fills with detected code
✅ Card type correctly identified
✅ Detail screen renders QR widget
✅ UI is responsive and stable
✅ No crashes observed
```

---

## 🎓 Learning Resources

### Understanding the Code

- [camera_scan_page.dart](lib/pages/camera_scan_page.dart) - Camera scanning logic
- [card_detail_page.dart](lib/pages/card_detail_page.dart) - Detail screen rendering
- [card_expiry_service.dart](lib/services/card_expiry_service.dart) - Expiry logic

### Test Code Reference

- [scan_code_type_flows_test.dart](integration_test/scan_code_type_flows_test.dart) - Integration tests
- [card_expiry_service_test.dart](test/services/card_expiry_service_test.dart) - Service tests
- [card_item_test.dart](test/models/card_item_test.dart) - Model tests

---

## 💡 Tips for Successful Testing

1. **Be systematic:** Follow checklists in order
2. **Document everything:** Note observations and issues
3. **Capture screenshots:** Visual proof of functionality
4. **Test on clean state:** Optional: `flutter clean` before testing
5. **Use multiple codes:** Test with different QR codes
6. **Note timing:** How long does detection take?
7. **Check errors:** Try invalid images too
8. **Compare results:** Manual vs automated tests should match

---

## 🔗 Related Documentation

### Existing Guides

- [INTEGRATION_TESTS_SUMMARY.md](INTEGRATION_TESTS_SUMMARY.md) - Integration test overview
- [E2E_TESTS_READY.md](E2E_TESTS_READY.md) - E2E test status
- [RUN_E2E_TESTS.md](RUN_E2E_TESTS.md) - How to run E2E tests

### Code Documentation

- [docs/README.md](docs/README.md) - Project documentation
- [README.md](README.md) - Project overview

---

## 🎖️ Success Criteria

Manual testing is **COMPLETE** when:

✅ All quick start scenarios execute successfully  
✅ Screenshots captured of key moments  
✅ Results match automated test expectations  
✅ No crashes or unexpected behavior  
✅ Documentation updated with findings  
✅ Automated tests all still pass

---

## 📞 Quick Reference

### Key Commands

```bash
# Start app
flutter run

# Run automated tests
flutter test

# Check emulator
adb devices

# View emulator files
adb shell ls -la /sdcard/Pictures/

# Capture emulator screenshot
adb shell screencap /sdcard/screenshot.png

# Download screenshot
adb pull /sdcard/screenshot.png ~/Downloads/
```

### Test File Locations

- Emulator: `/sdcard/Pictures/test_qr_*.png`
- Local: `~/card_test_codes/test_qr_*.png`
- Code: `/Users/pietergeerts/Prive/cards/`

---

## 🎯 Next Actions

### Immediately

1. ✅ Read: [START_MANUAL_TESTING.md](START_MANUAL_TESTING.md)
2. ✅ Run: `flutter run`
3. ✅ Test: Scan QR code from gallery

### Today

1. [ ] Execute all test scenarios
2. [ ] Capture screenshots
3. [ ] Document results
4. [ ] Run automated tests again

### For Future

1. [ ] Test barcode scanning
2. [ ] Test error scenarios
3. [ ] Performance benchmarking
4. [ ] Additional QR/barcode formats

---

## ✅ Setup Status Dashboard

| Component              | Status        | Ready?  |
| ---------------------- | ------------- | ------- |
| Emulator connection    | ✅ Online     | YES     |
| Test images (local)    | ✅ Downloaded | YES     |
| Test images (emulator) | ✅ Uploaded   | YES     |
| App code               | ✅ Buildable  | YES     |
| Documentation          | ✅ Complete   | YES     |
| Automated tests        | ✅ Passing    | YES     |
| Manual test plan       | ✅ Ready      | YES     |
| **Overall**            | **✅ READY**  | **YES** |

---

**🎉 Everything is ready for manual testing!**

**👉 Next Step:** Open [START_MANUAL_TESTING.md](START_MANUAL_TESTING.md) and begin testing!

---

_Last updated: 2026-04-17_  
_Test Setup: Complete_  
_Status: Ready for Execution_
