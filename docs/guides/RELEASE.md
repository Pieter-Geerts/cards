# Release Guide 🚀

This guide explains how to release your Flutter cards app to Google Play Store as easily as possible.

## Super Quick Start (Easiest Way!)

**For the easiest experience, just run:**

```bash
./scripts/master-release.sh
```

This interactive script will guide you through everything step-by-step!

## Quick Start Options

### 1. Guided Release (Recommended for beginners)

```bash
./scripts/master-release.sh
```

### 2. Quick Patch Release (for experienced users)

```bash
./scripts/quick-release.sh
```

### 3. Pre-release Checklist Only

```bash
./scripts/release-checklist.sh
```

The quick release will:

- ✅ Run all tests and checks
- ✅ Bump the patch version (e.g., 1.0.2 → 1.0.3)
- ✅ Build the Android App Bundle (AAB)
- ✅ **Auto-generate user-friendly release notes**
- ✅ Create a git commit and tag
- ✅ Provide upload instructions

## 📝 Automated Release Notes

Your release process now includes **smart release notes generation**:

### Features:

- 🤖 **Smart conversion** of technical commits to user-friendly descriptions
- 📊 **Quality analysis** with character count and jargon detection
- ✏️ **Interactive editing** with improvement suggestions
- 📋 **Google Play optimization** (500 character limit compliance)

### Usage:

```bash
# Generate release notes from commits
./scripts/smart-release-notes.sh

# Review and improve generated notes
./scripts/review-release-notes.sh

# Basic release notes (less intelligent)
./scripts/generate-release-notes.sh
```

The release notes are automatically generated during the release process and shown for easy copy-pasting to Google Play Console.

## Manual Release Options

### 1. Standard Release Script

```bash
# Patch release (1.0.2 → 1.0.3)
./scripts/release.sh patch

# Minor release (1.0.2 → 1.1.0)
./scripts/release.sh minor

# Major release (1.0.2 → 2.0.0)
./scripts/release.sh major

# Custom version
./scripts/release.sh 1.5.0
```

### 2. Pre-release Checks Only

```bash
./scripts/pre-release-check.sh
```

### 4. Build Information

```bash
./scripts/build-info.sh
```

### 6. Version Bump Only

```bash
./scripts/bump-version.sh patch
```

## GitHub Actions (Automated)

### Manual Trigger

1. Go to **Actions** tab in GitHub
2. Select **Release & Build** workflow
3. Click **Run workflow**
4. Choose version type (patch/minor/major)
5. Optionally enable Google Play Store upload

### Tag-based Release

Push a tag to trigger automatic release:

```bash
git tag v1.0.3
git push --tags
```

## Google Play Store Upload

### Option 1: Manual Upload (Recommended)

1. Download AAB file from GitHub Actions artifacts or local build
2. Go to [Google Play Console](https://play.google.com/console)
3. Select your app → Release → Production
4. Create new release
5. Upload AAB file
6. Add release notes
7. Review and publish

### Option 2: Automated Upload

Set up these GitHub secrets for automated uploads:

- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_STORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

## Prerequisites

### Android Signing

Create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=upload-keystore.jks
```

### Secrets File

Ensure `lib/secrets.dart` exists (copy from `lib/secrets_template.dart`).

## Release Checklist

Before releasing, ensure:

- [ ] All tests pass (`flutter test`)
- [ ] No analysis issues (`flutter analyze`)
- [ ] Working directory is clean (no uncommitted changes)
- [ ] Android signing is configured
- [ ] Release notes are prepared

## Common Commands

```bash
# MASTER COMMAND - Guided release process
./scripts/master-release.sh

# Check app and build status
./scripts/build-info.sh

# Run interactive checklist
./scripts/release-checklist.sh

# Check current version
grep '^version:' pubspec.yaml

# Run all pre-checks
./scripts/pre-release-check.sh

# Build AAB manually
flutter build appbundle --release

# View AAB location
ls -la build/app/outputs/bundle/release/

# Check git status
git status

# View recent releases
git tag -l --sort=-version:refname | head -10
```

## Troubleshooting

### "Working directory is not clean"

Commit or stash your changes:

```bash
git add .
git commit -m "Prepare for release"
```

### "Android signing not configured"

Create the keystore and `key.properties` file as described in Prerequisites.

### "Tests failing"

Fix failing tests before releasing:

```bash
flutter test
```

### "AAB file not found"

Ensure the build completed successfully and check:

```bash
ls -la build/app/outputs/bundle/release/
```

## File Locations

- **Release scripts**: `scripts/`
- **AAB output**: `build/app/outputs/bundle/release/app-release.aab`
- **APK output**: `build/app/outputs/flutter-apk/app-release.apk`
- **Android config**: `android/app/build.gradle.kts`
- **Signing config**: `android/key.properties`

## Tips

1. **Use quick-release.sh** for most releases
2. **Test locally first** before using GitHub Actions
3. **Keep release notes updated** in Google Play Console
4. **Monitor app size** (shown in pre-release checks)
5. **Use semantic versioning** (major.minor.patch)

---

**Happy releasing! 🎉**
