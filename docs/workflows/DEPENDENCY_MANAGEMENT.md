# Dependency Management Guide 📦

This guide explains the comprehensive dependency automation system implemented for your Flutter Cards app.

## 🎯 Overview

Your project now has multiple automated systems to keep dependencies up to date:

1. **Dependabot** - Automatic Pull Requests for updates
2. **Weekly Checks** - GitHub Actions workflow for monitoring
3. **Manual Script** - Safe interactive updating
4. **Build Integration** - Status monitoring in existing tools

## 🤖 Automatic Updates (Dependabot)

### What It Does
- **Monitors** your `pubspec.yaml` and GitHub Actions workflows
- **Creates Pull Requests** automatically when updates are available
- **Runs weekly** on Mondays at 9:00 AM UTC
- **Tests compatibility** through CI/CD before merging

### Configuration
File: `.github/dependabot.yml`

```yaml
version: 2
updates:
  - package-ecosystem: "pub"        # Flutter/Dart dependencies
  - package-ecosystem: "github-actions"  # Workflow dependencies
```

### What You'll See
- **Pull Requests** with titles like "Bump flutter_lints from 5.0.0 to 6.0.0"
- **Automatic labels**: `dependencies`, `automated`
- **You as assignee/reviewer** for approval
- **Compatibility checks** run automatically

### Managing Dependabot PRs
```bash
# Review and merge via GitHub UI, or locally:
git checkout main
git pull origin main
git branch -D dependabot/branch-name  # Clean up after merge
```

## 📊 Weekly Monitoring

### GitHub Actions Workflow
File: `.github/workflows/dependency-check.yml`

**What it does:**
- **Runs every Monday** at 9:00 AM UTC
- **Checks for outdated dependencies**
- **Creates GitHub Issues** when updates are available
- **Provides detailed status reports**

**Manual trigger:**
- Go to GitHub Actions → "Weekly Dependency Update Check" → "Run workflow"

### What You'll See
- **GitHub Issues** titled "📦 Weekly Dependency Update Available"
- **Summary reports** in Actions tab
- **Detailed instructions** for updating

## 🛠️ Manual Updates

### Interactive Update Script
```bash
./scripts/update-dependencies.sh
```

**Features:**
- ✅ **Safety checks** before updating
- ✅ **Backup and rollback** capability
- ✅ **Comprehensive testing** after updates
- ✅ **Interactive prompts** for control
- ✅ **Detailed reporting** of changes

**What it does:**
1. Checks git status and warns about uncommitted changes
2. Backs up current `pubspec.lock`
3. Updates Flutter SDK
4. Shows outdated dependencies
5. Asks permission before updating
6. Runs tests to check for breaking changes
7. Offers rollback if tests fail
8. Shows what changed

### Quick Status Check
```bash
./scripts/build-info.sh
```

Now includes dependency status:
- Shows count of outdated packages
- Displays last update date
- Provides quick action commands

## 🔧 Integration with Existing Tools

### Build Info Script
The `build-info.sh` script now shows:
```
Dependencies:
  Status: 16 packages can be updated
  Run: ./scripts/update-dependencies.sh
  Last Updated: 2025-06-15
```

### Pre-release Checks
The `pre-release-check.sh` now includes:
- Dependency updates
- Localization generation
- Comprehensive testing

### Quick Actions
All scripts now reference dependency management:
```
• Update dependencies: ./scripts/update-dependencies.sh
```

## 📋 Workflow Recommendations

### For Regular Development
1. **Let Dependabot handle routine updates** - Review and merge PRs
2. **Check status weekly** with `./scripts/build-info.sh`
3. **Manual updates before releases** with `./scripts/update-dependencies.sh`

### For Major Updates
1. **Use the manual script** for control and testing
2. **Update in a separate branch** for safety
3. **Test thoroughly** before merging to main

### Before Releases
1. **Run pre-release checks** - includes dependency updates
2. **Ensure all tests pass** after updates
3. **Document significant dependency changes** in release notes

## 🔍 Monitoring Commands

```bash
# Check current status
./scripts/build-info.sh

# See what's outdated
flutter pub outdated

# Interactive update
./scripts/update-dependencies.sh

# Just update lock file (existing versions)
flutter pub get

# Upgrade to newer versions
flutter pub upgrade

# Major version upgrades
flutter pub upgrade --major-versions
```

## 🚨 Troubleshooting

### Failed Dependency Updates

**If tests fail after update:**
```bash
# The script will offer to revert automatically, or manually:
git checkout pubspec.lock  # Revert to previous versions
flutter pub get
flutter gen-l10n
```

**If build fails:**
```bash
# Check for breaking changes in package documentation
flutter pub deps --style=tree  # See dependency tree
flutter doctor  # Check Flutter setup
```

### Dependabot Issues

**Too many PRs:**
- Adjust `open-pull-requests-limit` in `.github/dependabot.yml`
- Pause Dependabot temporarily if needed

**Failed CI on Dependabot PR:**
- Check the Actions logs
- Often indicates breaking changes in dependencies
- May need manual intervention

### Weekly Check Issues

**Missing GitHub Issues:**
- Check if workflow is enabled in Actions tab
- Verify repository permissions for issue creation

## 📈 Benefits

### Automated Benefits
- ✅ **Never miss security updates**
- ✅ **Consistent update schedule**
- ✅ **Automated testing** before adoption
- ✅ **Clear review process** via PRs

### Manual Benefits
- ✅ **Full control** over timing
- ✅ **Safety nets** and rollback
- ✅ **Comprehensive testing**
- ✅ **Detailed change reports**

### Integration Benefits
- ✅ **Status visibility** in existing tools
- ✅ **Release workflow integration**
- ✅ **Consistent with app quality standards**

## 🎯 Next Steps

1. **Review the first Dependabot PRs** when they arrive (Monday)
2. **Test the manual update script** on a feature branch
3. **Customize schedules** if needed in configuration files
4. **Set up notifications** for dependency-related GitHub Issues

---

**Your dependencies are now fully automated! 🎉**

The system will keep your app secure, up-to-date, and stable with minimal manual intervention.
