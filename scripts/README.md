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
| `update-dependencies.sh`    | 📦 **Update Flutter dependencies**     | `./update-dependencies.sh`                  |
| `generate-localizations.sh` | 🌍 Generate localization files         | `./generate-localizations.sh`               |
| `setup-git-workflow.sh`     | 🌊 **Configure Git workflow**          | `./setup-git-workflow.sh`                   |
| `install-git-hooks.sh`      | 🪝 **Install Git hooks**               | `./install-git-hooks.sh`                    |
| `pre-commit-hook.sh`        | 🔍 Pre-commit quality checks           | _(auto-runs on commit)_                      |
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

## 🌊 Git Workflow Enhancement

Improve your development workflow with automated quality gates:

### One-time Setup
```bash
# Configure Git settings and aliases
./setup-git-workflow.sh

# Install quality check hooks
./install-git-hooks.sh
```

### What You Get
- **Pre-commit hooks**: Automatic code formatting, linting, and testing
- **Commit templates**: Conventional commit format suggestions
- **Post-merge automation**: Dependencies and localizations auto-update
- **Useful aliases**: Streamlined Git commands
- **Quality gates**: Prevent broken commits

### New Git Commands
```bash
git st                    # Short status
git feature-start <name>  # Create feature branch
git flutter-check         # Run analyze + test
git release-check         # Pre-release validation
```

See `../GIT_WORKFLOW.md` for complete documentation.

## 📦 Dependency Management

Keep your Flutter dependencies up to date with automated tools:

### Manual Updates
```bash
# Interactive dependency update with safety checks
./update-dependencies.sh
```

### Automated Updates (GitHub)
- **Dependabot**: Automatically creates PRs for dependency updates (configured in `.github/dependabot.yml`)
- **Weekly Checks**: GitHub Actions workflow runs weekly to check for outdated dependencies
- **Status in build-info**: `./build-info.sh` shows current dependency status

### Localization Files
```bash
# Regenerate localization files from ARB sources
./generate-localizations.sh
```

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
