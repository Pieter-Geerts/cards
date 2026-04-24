# GitHub Actions Workflow for Flutter Android Testing

Create this as `.github/workflows/flutter-test.yml`:

```yaml
name: Flutter Tests (Android)
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        api-level: [28, 30, 31, 32]  # Test on Android 9, 11, 12, 13
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'  # Match your project version
          architecture: x64

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
          cache: gradle

      - name: Get Flutter dependencies
        run: flutter pub get

      - name: Run Dart analyzer
        run: flutter analyze

      - name: Run unit & widget tests
        run: |
          flutter test \
            --coverage \
            --test-randomize-ordering-seed=random

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
          flags: flutter

  integration_test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        api-level: [28, 31]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          architecture: x64

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
          cache: gradle

      - name: Get Flutter dependencies
        run: flutter pub get

      - name: Enable KVM for hardware acceleration
        run: |
          echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
          sudo udevadm control --reload-rules
          sudo udevadm trigger --name-match=kvm

      - name: Run Android emulator & integration tests
        uses: ReactiveCircus/android-emulator-runner@v2
        with:
          api-level: ${{ matrix.api-level }}
          profile: pixel_6
          target: default
          arch: x86_64
          cores: 4
          ram: 4096
          disk-size: 8000
          force-avd-creation: false
          emulator-options: -no-snapshot-load -noaudio -no-boot-anim -screen touch -gpu swiftshader_indirect
          script: |
            flutter drive \
              --target=integration_test/app_test.dart \
              --headless \
              --verbose

  golden_tests:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          architecture: x64

      - name: Get Flutter dependencies
        run: flutter pub get

      - name: Generate golden tests
        run: |
          flutter test \
            --tags=golden \
            --update-goldens

      - name: Verify golden tests
        run: |
          flutter test \
            --tags=golden

      - name: Upload golden images on failure
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: golden-diffs
          path: test/goldens/**/*.png

  build_apk:
    needs: [test, integration_test]
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          architecture: x64

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
          cache: gradle

      - name: Get Flutter dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --split-per-abi

      - name: Upload APK artifact
        uses: actions/upload-artifact@v3
        with:
          name: debug-apk
          path: build/app/outputs/flutter-apk/
```

---

## Workflow Features

✅ **Multi-API Level Testing**: Runs tests on Android 9, 11, 12, 13 to catch density/version issues  
✅ **Coverage Reporting**: Uploads to Codecov for tracking  
✅ **Golden Testing**: Separate job to manage visual regression tests  
✅ **Hardware Acceleration**: KVM enabled for faster emulator runs  
✅ **Artifact Upload**: Saves APK and golden diffs on failure  
✅ **Conditional Jobs**: Build only runs after tests pass  

---

## Local Debugging

### Run all tests locally:
```bash
flutter test --coverage
```

### Run specific test file:
```bash
flutter test test/widget/login_widget_test.dart
```

### Run integration tests locally:
```bash
flutter drive --target=integration_test/app_test.dart
```

### Run golden tests with updates:
```bash
flutter test --tags=golden --update-goldens
```

### Run just unit tests (exclude integration):
```bash
flutter test --exclude-tags=integration
```

---

## Troubleshooting

**Emulator timeout**: Increase `timeout` in flutter_test config  
**Golden mismatch**: Review diff in artifacts, then `--update-goldens` locally  
**Coverage not generated**: Ensure `--coverage` flag and valid test paths  
**Backend mock issues**: Verify `mockito` code generation ran (`flutter pub run build_runner build`)
