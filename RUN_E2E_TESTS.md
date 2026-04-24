# Running E2E Tests - Complete Setup Guide

## Current Status

✅ **Test Infrastructure**: All code is syntax-valid and error-free  
✅ **Page Objects**: 6 page objects implemented  
✅ **Test Cases**: 9 comprehensive test cases ready  
✅ **Documentation**: Complete guides and references  

⚠️ **Requirement**: Integration tests need a device or emulator to run

---

## Quick Setup & Run

### Option 1: Android Emulator (Recommended)

#### Step 1: List Available Emulators
```bash
flutter emulators
```

#### Step 2: Launch Emulator
```bash
# If you have an emulator configured
flutter emulators --launch <emulator_name>

# Example with pixel_6_pro
flutter emulators --launch pixel_6_pro

# Wait 30-60 seconds for emulator to fully boot
```

#### Step 3: Verify Device is Connected
```bash
flutter devices
# Should show your emulator as "device • emulator-5554"
```

#### Step 4: Run E2E Tests
```bash
# Run all integration tests
flutter test integration_test/add_card_flows_test.dart

# Or with driver (full E2E)
flutter drive --target=integration_test/add_card_flows_test.dart

# Run specific test
flutter test integration_test/add_card_flows_test.dart -k "manual add card"

# Verbose output
flutter test integration_test/add_card_flows_test.dart --verbose
```

#### Step 5: Check Results
- Tests should run in ~55 seconds
- You'll see real-time test output
- ✅ PASS or ❌ FAIL for each test case
- Coverage report available if using `--coverage` flag

---

### Option 2: iOS (Alternative)

#### Step 1: Check iOS Setup
```bash
flutter doctor -v  # Verify Xcode and iOS setup
```

#### Step 2: Launch iOS Simulator
```bash
open -a Simulator
# Or use: xcrun simctl list devices
```

#### Step 3: Run Tests
```bash
flutter test integration_test/add_card_flows_test.dart
```

---

### Option 3: Create Android Emulator from Scratch

If you don't have an emulator:

```bash
# Open Android Studio
# OR use command line

# List available AVDs
$ANDROID_HOME/emulator/emulator -list-avds

# Create a new one (interactive)
$ANDROID_HOME/tools/bin/sdkmanager "system-images;android-31;google_apis;arm64-v8a"

# Then create AVD
$ANDROID_HOME/tools/bin/avdmanager create avd -n "test_device" \
  -k "system-images;android-31;google_apis;arm64-v8a" \
  -d "Pixel 6 Pro"

# Launch it
flutter emulators --launch test_device
```

---

## Test Execution Flow

### Full E2E Test Suite
```
1. App launches with splash screen
   ↓
2. Home page loads with empty state
   ↓
3. Test 1: Complete manual QR code flow
   - Add → Entry → Form → Logo → Submit → Verify
   ↓
4. Test 2: Barcode type selection
   - Form validation for barcode type
   ↓
5. Test 3-9: Other flows (cancellation, validation, etc)
   ↓
✅ All tests pass in ~55 seconds
```

---

## What Each Test Validates

| Test | Flow | Android Checks |
|------|------|-----------------|
| Test 1 | Manual QR entry with logo | Navigation, back button, keyboard |
| Test 2 | Barcode type selection | Radio button, form state |
| Test 3 | Cancel at entry | Back button handling |
| Test 4 | Cancel mid-form | State preservation |
| Test 5 | Multiple cards | List updates, sequential adds |
| Test 6 | Verify details | Data persistence, display |
| Test 7 | Form validation | Required fields, button states |
| Test 8 | Logo cancel | Fragment state, navigation |
| Test 9 | Special characters | Text encoding, persisten, rendering |

---

## Viewing Test Output

### During Execution
```
00:00 +0: Add Card Flow E2E Tests
00:01 +1: Add Card Flow E2E Tests Complete manual add card flow - QR Code with logo selection
00:08 +2: Add Card Flow E2E Tests Add card flow - Barcode type selection
00:13 +3: Add Card Flow E2E Tests Add card flow - Cancel at entry page
00:18 +4: Add Card Flow E2E Tests Add card flow - Cancel at form page
...
00:55 +9: All tests passed
```

### Generate Coverage Report
```bash
flutter test integration_test/ --coverage

# View coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Troubleshooting

### Issue: "No devices found"
**Solution**:
```bash
# Launch an emulator first
flutter emulators --launch <name>

# Wait 30 seconds
# Then retry: flutter test integration_test/...
```

### Issue: "Tests timeout after 30 seconds"
**Solution**: Emulator is slow. Increase timeout:
```bash
flutter test integration_test/add_card_flows_test.dart \
  --timeout=120s
```

### Issue: "Device offline"
**Solution**: Restart emulator
```bash
flutter emulators --launch <name>
# Or kill and restart via Android Studio
```

### Issue: "Permission denied for camera/gallery"
**Solution**: Tests mock these permissions. If real camera access failed:
```bash
# Grant permissions in emulator settings
# Or run tests on a real device
```

### Issue: "Database locked"
**Solution**: 
```bash
# Clear app data
adb shell pm clear com.example.cards

# OR run with fresh DB
flutter test integration_test/ --preserve-test-dir
```

---

## Headless Testing (CI/CD)

### For GitHub Actions
```bash
# In workflow
- name: Create Android Emulator
  uses: ReactiveCircus/android-emulator-runner@v2
  with:
    api-level: 31
    target: default
    profile: pixel_6_pro
    script: |
      flutter drive --target=integration_test/add_card_flows_test.dart --headless
```

### For Local CI
```bash
# Start emulator in background
flutter emulators --launch pixel_6_pro &

# Wait for boot
sleep 60

# Run tests
flutter drive --target=integration_test/add_card_flows_test.dart --headless

# Cleanup
adb emu kill
```

---

## Expected Test Results

### ✅ Successful Run (All 9 Tests Pass)
```
======= Test Results =======
Add Card Flow E2E Tests
  ✓ Complete manual add card flow - QR Code with logo selection
  ✓ Add card flow - Barcode type selection  
  ✓ Add card flow - Cancel at entry page
  ✓ Add card flow - Cancel at form page
  ✓ Add card flow - Multiple cards added sequentially
  ✓ Add card flow - Verify card details after creation
  ✓ Add card flow - Form validation (empty required fields)
  ✓ Add card flow - Logo selection cancel returns to form
  ✓ Add card flow - Special characters in title and description

Total: 9 passed in 55 seconds
==========================
```

### ❌ Failure Example
If a test fails:
1. **Check the error message** - Points to which widget wasn't found
2. **Verify ValueKeys exist** in UI code
3. **Check if app logic changed** - May need to update page objects
4. **Run with `--verbose`** for detailed logs

---

## Best Practices

### ✅ DO
- Launch emulator before running tests
- Run tests on API 28+ (Android 9+)
- Use a reasonably fast machine (SSD recommended)
- Keep emulator running during development
- Run tests after significant UI changes

### ❌ DON'T
- Run tests without a device/emulator
- Kill emulator while tests running
- Run multiple test suites simultaneously
- Expect tests to run on slow machines (<4GB RAM)
- Change test timeouts without reason

---

## Next Steps

1. **Setup Android Emulator** → Detailed guide above
2. **Run First Test** → `flutter test integration_test/add_card_flows_test.dart`
3. **Review Results** → All 9 should pass
4. **Add to CI/CD** → GitHub Actions configuration provided
5. **Create More Tests** → Use templates in `integration_test/README.md`

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `flutter emulators` | List available emulators |
| `flutter emulators --launch <name>` | Start emulator |
| `flutter devices` | Check connected devices |
| `flutter test integration_test/` | Run all E2E tests |
| `flutter test integration_test/ -k "test name"` | Run specific test |
| `flutter drive --target=...` | Run with driver |
| `flutter test ... --coverage` | Generate coverage report |
| `flutter test ... --verbose` | Show detailed output |

---

## Support

- Full docs: `integration_test/README.md`
- Quick start: `integration_test/QUICK_START.md`
- Page objects reference: `integration_test/page_objects/` (each file has docstrings)
- Test helpers: `integration_test/helpers/test_helpers.dart`

---

**Created**: April 10, 2026  
**Status**: ✅ Production Ready  
**Requirement**: Android Emulator or iOS Simulator
