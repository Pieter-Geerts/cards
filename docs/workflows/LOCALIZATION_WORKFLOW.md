# Localization Workflow Guide 🌍

This document explains how to manage localization files to prevent merge conflicts and maintain consistency across the project.

## Overview

Our localization system uses Flutter's built-in internationalization support with ARB (Application Resource Bundle) files as the source of truth. Generated Dart files are excluded from version control to prevent merge conflicts.

## File Structure

```
lib/l10n/
├── app_en.arb              # Source (tracked in Git)
├── app_es.arb              # Source (tracked in Git)
├── app_nl.arb              # Source (tracked in Git)
├── app_localizations.dart  # Generated (NOT tracked in Git)
├── app_localizations_en.dart # Generated (NOT tracked in Git)
├── app_localizations_es.dart # Generated (NOT tracked in Git)
└── app_localizations_nl.dart # Generated (NOT tracked in Git)
```

## What Changed

### ✅ Now Tracked in Git

- **Source ARB files** (`app_*.arb`) - These contain the actual translations
- **Configuration** (`l10n.yaml`) - Localization settings

### ❌ No Longer Tracked in Git

- **Generated Dart files** (`app_localizations*.dart`) - Auto-generated from ARB files
- Added to `.gitignore` to prevent future conflicts

## Workflow

### 1. Adding New Translations

To add a new translatable string:

1. **Add to English ARB file** (`lib/l10n/app_en.arb`):

   ```json
   {
     "myNewString": "Hello World",
     "@myNewString": {
       "description": "A greeting message"
     }
   }
   ```

2. **Add to other language files** (`app_es.arb`, `app_nl.arb`):

   ```json
   {
     "myNewString": "Hola Mundo"
   }
   ```

3. **Generate Dart files**:

   ```bash
   flutter gen-l10n
   # or use our script:
   ./scripts/generate-localizations.sh
   ```

4. **Use in code**:
   ```dart
   Text(AppLocalizations.of(context).myNewString)
   ```

### 2. Development Workflow

When working with localization:

```bash
# 1. Pull latest changes
git pull origin main

# 2. Generate localization files locally
flutter gen-l10n

# 3. Make your changes to ARB files
# Edit lib/l10n/app_*.arb files

# 4. Regenerate after changes
flutter gen-l10n

# 5. Test your changes
flutter test

# 6. Commit only ARB files
git add lib/l10n/app_*.arb
git commit -m "Add new translations"
```

### 3. Branch Merging

When merging branches:

1. **If ARB files conflict**: Resolve manually (these are human-readable JSON files)
2. **If generated files conflict**:
   - Delete the conflicted generated files
   - Run `flutter gen-l10n` to regenerate clean files
   - Don't commit the generated files

### 4. Setting Up New Development Environment

When cloning or switching branches:

```bash
git clone <repository>
cd cards
flutter pub get
flutter gen-l10n  # Generate localization files
```

## Automation

### Scripts

We provide several scripts to help manage localizations:

- **`./scripts/generate-localizations.sh`** - Generate localization files
- **`./scripts/pre-release-check.sh`** - Includes localization generation
- **CI/CD Pipeline** - Automatically generates files during builds

### Pre-commit Hook (Optional)

You can add a pre-commit hook to ensure localizations are always generated:

```bash
# .git/hooks/pre-commit
#!/bin/sh
flutter gen-l10n
```

## Troubleshooting

### "AppLocalizations not found" Error

This usually means the generated files are missing:

```bash
flutter gen-l10n
flutter pub get
```

### Merge Conflicts in Generated Files

If you still see conflicts in generated files:

```bash
# Remove the problematic generated files
rm lib/l10n/app_localizations*.dart

# Regenerate them
flutter gen-l10n

# The files should now be clean
```

### Missing Translations

If a translation is missing in one language:

1. Check all ARB files have the same keys
2. Regenerate: `flutter gen-l10n`
3. The missing translation will show as the key name in the app

## Best Practices

### ✅ Do

- Always edit ARB files for translations
- Use descriptive keys: `settingsPageTitle` not `title1`
- Add descriptions in ARB files for translators
- Run `flutter gen-l10n` after ARB changes
- Test all languages before releasing

### ❌ Don't

- Never edit generated Dart files directly
- Don't commit generated Dart files
- Don't manually resolve conflicts in generated files
- Don't skip the generation step in CI/CD

## Benefits of This Approach

1. **No More Merge Conflicts** - Generated files aren't tracked
2. **Consistent Output** - Same ARB → Same generated files
3. **Cleaner Git History** - Only meaningful changes are tracked
4. **Automated Builds** - CI/CD generates files automatically
5. **Developer Friendly** - Simple workflow, fewer conflicts

## Migration Complete

The migration to this new workflow is complete:

- ✅ Generated files removed from Git tracking
- ✅ `.gitignore` updated
- ✅ Scripts updated to include generation
- ✅ CI/CD pipeline updated
- ✅ Documentation created

You should no longer experience localization-related merge conflicts! 🎉
