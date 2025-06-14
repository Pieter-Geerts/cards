# Release Notes Tools - Quick Reference

## 🚀 TL;DR - Just Want Release Notes?

```bash
# Generate smart release notes and review them
./scripts/smart-release-notes.sh
./scripts/review-release-notes.sh

# Copy the improved notes to Google Play Console
```

## 📝 Example Output

**Before (technical commits):**

```
• Fix failing tests in CardDetailPage
• pipeline
• import from photo
• share cards
• localizations
```

**After (user-friendly):**

```
🆕 What's New:
• Added photo import functionality
• Added card sharing functionality

🛠️ Improvements:
• Fixed app stability issues
• Enhanced language support
```

## 🔧 Tool Details

### `smart-release-notes.sh`

- Converts technical git commits to user-friendly descriptions
- Automatically categorizes changes (features, fixes, improvements)
- Respects Google Play Store 500-character limit
- Filters out technical/internal changes

### `review-release-notes.sh`

- Analyzes release notes quality
- Detects technical jargon and vague descriptions
- Provides improvement suggestions
- Interactive editing with character count
- macOS clipboard integration

### `generate-release-notes.sh`

- Basic commit-to-release-notes converter
- Less intelligent than smart version
- Good for technical audiences
- Preserves original commit structure

## 💡 Pro Tips

1. **Run after every few commits** to see how your commit messages translate
2. **Write better commit messages** - they become your release notes!
3. **Use conventional commits** for better categorization:
   ```
   feat: add photo import functionality
   fix: resolve app crash on card deletion
   improve: enhance card sharing experience
   ```
4. **Review before publishing** - always use the review tool
5. **Customize for your audience** - technical vs general users

## 🎯 Integration with Release Process

The tools are automatically integrated into:

- `master-release.sh` - Full guided process with release notes
- `release.sh` - Includes optional release notes review
- `quick-release.sh` - Fast releases with auto-generated notes

## 📱 Google Play Console Integration

1. Use the tools to generate notes
2. Copy the "Google Play Store Version" section
3. Paste directly into Play Console release notes
4. No manual formatting needed!

---

**Making release notes as easy as your releases! 🎉**
