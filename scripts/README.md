# Release Scripts

This directory contains automated scripts to make releasing your Flutter app as easy as possible.

## 🚀 Quick Start

**New to releases? Start here:**

```bash
./master-release.sh
```

**Experienced? Use this for quick patch releases:**

```bash
./quick-release.sh
```

## 📁 Available Scripts

| Script                      | Purpose                                | Usage                                       |
| --------------------------- | -------------------------------------- | ------------------------------------------- |
| `master-release.sh`         | 🎯 **Guided release process**          | `./master-release.sh`                       |
| `quick-release.sh`          | ⚡ Quick patch release                 | `./quick-release.sh`                        |
| `release.sh`                | 🔧 Full release with options           | `./release.sh [patch\|minor\|major\|X.Y.Z]` |
| `smart-release-notes.sh`    | 🤖 **Smart release notes generator**   | `./smart-release-notes.sh [from] [to]`      |
| `review-release-notes.sh`   | ✨ **Release notes reviewer & editor** | `./review-release-notes.sh [file]`          |
| `generate-release-notes.sh` | 📝 Basic release notes from commits    | `./generate-release-notes.sh [from] [to]`   |
| `build-info.sh`             | 📊 Show app and build status           | `./build-info.sh`                           |
| `release-checklist.sh`      | ✅ Interactive pre-release checklist   | `./release-checklist.sh`                    |
| `pre-release-check.sh`      | 🔍 Automated quality checks            | `./pre-release-check.sh`                    |
| `bump-version.sh`           | 🔢 Version management only             | `./bump-version.sh [type\|version]`         |

## 📝 Documentation Files

- `release-notes-template.md` - Template for Google Play Store release notes
- `release-notes-config.txt` - Configuration for automated release notes generation
- `../RELEASE.md` - Complete release documentation

## 📝 Release Notes Workflow

1. **Generate**: `./smart-release-notes.sh` (creates user-friendly notes from commits)
2. **Review**: `./review-release-notes.sh` (analyzes and helps improve the notes)
3. **Copy**: Use the reviewed notes in Google Play Console

### Release Notes Features:

- 🤖 **Smart conversion** of technical commits to user-friendly descriptions
- 📊 **Quality analysis** (character count, technical jargon detection)
- ✏️ **Interactive editing** with built-in suggestions
- 📋 **Google Play optimization** (500 character limit compliance)
- 🎯 **Benefit-focused** language recommendations

## 🎯 Typical Workflow

1. **Check status**: `./build-info.sh`
2. **Run checklist**: `./release-checklist.sh`
3. **Create release**: `./master-release.sh` or `./quick-release.sh`
4. **Upload to Play Store** using the generated AAB file

## 💡 Tips

- All scripts are designed to be safe - they check for issues before making changes
- Scripts will show you exactly what they're doing
- You can always cancel by pressing Ctrl+C
- The `master-release.sh` script is perfect for first-time users

---

**Happy releasing! 🎉**
