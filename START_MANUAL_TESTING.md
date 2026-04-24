# ✅ Manual Testing Ready - START HERE!

**Status: ALL SYSTEMS GO! 🚀**

---

## 📱 What's Ready

✅ Emulator connected: `emulator-5554`  
✅ Test QR codes downloaded: `test_qr_001.png`, `test_qr_github.png`  
✅ Images uploaded to emulator: `/sdcard/Pictures/`  
✅ App is buildable and ready to test

---

## 🎮 Start Testing NOW (3 steps)

### Step 1: Launch the App

```bash
cd /Users/pietergeerts/Prive/cards
flutter run
```

**Wait for:** "Launching on emulator-5554..." → should see app start in ~30 seconds

---

### Step 2: Navigate to Add Card Screen

1. On home screen, tap **large blue "+" button** or **"Add Card" button**
2. You should see options:
   - Scan (camera)
   - Scan from Photo (gallery)
   - Manual Entry

---

### Step 3: Test QR Code Detection

1. Tap **"Scan from Photo"**
2. Gallery should open
3. Select **"test_qr_001.png"**
4. **EXPECTED:**
   - Image opens/preview shows
   - App detects it's a QR code
   - Form auto-fills with: `TEST_QR_SCAN_001`
   - Card Type dropdown shows: **"QR Code"** ✓

5. Tap field and verify auto-detected data
6. Fill title: "Test QR Card"
7. Tap **"Continue"** or **"Save"**

---

### Step 4: Verify Detail Screen

1. Card saved and returns to list
2. Tap on "Test QR Card"
3. **Detail screen opens showing:**
   - ✓ Title: "Test QR Card"
   - ✓ Code preview: "TEST_QR_SCAN_001"
   - ✓ Card type chip: **"QR Code"**
   - ✓ **QR code rendered** (actual visual QR code visible)

---

## 🧪 Test Matrix - Check Off As You Go

### Test 1: QR Code Scan

- [ ] Start app
- [ ] Tap "Add Card" → "Scan from Photo"
- [ ] Select test_qr_001.png
- [ ] Form shows: TEST_QR_SCAN_001
- [ ] Card Type: QR Code ✓
- [ ] Save card
- [ ] Detail screen: QR code visible ✓
- [ ] **RESULT:** PASS ✓ / FAIL ✗

### Test 2: Multiple QR Codes

- [ ] Go back to home
- [ ] Tap "Add Card" → "Scan from Photo" again
- [ ] Select test_qr_github.png
- [ ] Form shows: https://github.com/pietergeerts/cards
- [ ] Card Type: QR Code ✓
- [ ] Save as "GitHub QR"
- [ ] **RESULT:** PASS ✓ / FAIL ✗

### Test 3: Card List Shows Both Types

- [ ] Home screen shows 2 cards: "Test QR Card", "GitHub QR"
- [ ] Both cards visible and selectable
- [ ] Can tap each to view detail
- [ ] **RESULT:** PASS ✓ / FAIL ✗

---

## 📸 Screenshots to Capture

Take screenshots of:

1. **Form after QR detection:**
   - Shows auto-filled data
   - Card Type dropdown selected
   - Code preview visible

2. **Detail screen:**
   - QR code rendered
   - Card type chip
   - Code data display

3. **Card list:**
   - Shows both saved cards
   - Types visible

---

## 🔥 Testing More Advanced Features (Optional)

### Add a Temporary Card

1. Scan test_qr_001.png again (or create new)
2. **Enable "Temporary Card"** toggle (if available in UI)
3. Set **"Expires in: 3 days"**
4. Fill title: "Temp QR"
5. Save
6. **Check detail screen:**
   - Expiry chip visible: "Expires on [date]"
   - Hourglass icon on card list

---

## 🐛 If Something Doesn't Work

### "Gallery shows no pictures"

```bash
# Refresh media library
adb shell am broadcast -a android.intent.action.MEDIA_MOUNTED \
  -d file:///sdcard/Pictures
```

### "App crashes when scanning"

```bash
# Check logs
adb logcat | grep -i flutter

# Kill and rebuild
flutter clean
flutter pub get
flutter run
```

### "QR code not detected"

- Verify image file is OK: `file ~/card_test_codes/test_qr_001.png`
- Check file actually uploaded: `adb shell ls -la /sdcard/Pictures/test_qr_001.png`
- Try different QR code (test_qr_github.png)

---

## ✅ Verification Checklist

After testing, verify:

- [ ] QR code detected from gallery
- [ ] Form auto-filled with detected data
- [ ] Card Type correctly set to "QR Code"
- [ ] Card saved successfully
- [ ] Detail screen shows QR code visually
- [ ] Card list shows saved cards
- [ ] Can tap cards to view detail
- [ ] No crashes or errors

---

## 📊 Test Results

```
Date: 2026-04-17
Device: emulator-5554 (Android)

QR Code Detection: PASS / FAIL
Form Population: PASS / FAIL
Card Type Selection: PASS / FAIL
Detail Screen Rendering: PASS / FAIL
Navigation: PASS / FAIL
UI Stability: PASS / FAIL

Overall: ✅ PASS / ❌ FAIL

Issues Found:
- [None found] / [List here]

Performance Notes:
- Detection time: ~1-2 seconds
- Navigation smoothness: Good / Laggy
```

---

## 🎯 Next Phase

After manual testing confirms everything works:

```bash
# Run automated integration tests
flutter test integration_test/scan_code_type_flows_test.dart -v

# Run service tests (expiry/deletion)
flutter test test/services/card_expiry_service_test.dart -v

# Run all tests
flutter test
```

All automated tests should PASS ✅

---

## 📚 Reference Documentation

If you need more details:

- [Full Manual Testing Guide](MANUAL_TESTING_GUIDE.md)
- [Detailed Test Checklist](MANUAL_TEST_CHECKLIST.md)
- [Quick Test Guide](QUICK_MANUAL_TEST.md)

---

## 🚀 Ready? Let's Go!

```bash
flutter run
```

Then:

1. Tap "Add Card"
2. Tap "Scan from Photo"
3. Select "test_qr_001.png"
4. See magic happen! ✨

---

**Status: ✅ READY FOR MANUAL TESTING**

Test files location:

- Local: `~/card_test_codes/test_qr_*.png`
- Emulator: `/sdcard/Pictures/test_qr_*.png`

Good luck! 🎮
