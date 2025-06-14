# Git Workflow Guide 🌊

This guide explains the enhanced Git workflow for your Flutter Cards app, including automated quality gates, hooks, and best practices.

## 🎯 Overview

Your project now has a comprehensive Git workflow system with:

- **Pre-commit hooks** - Quality checks before every commit
- **Automated formatting** - Code style enforcement
- **Conventional commits** - Structured commit messages
- **Post-merge automation** - Dependency updates after pulls
- **Useful aliases** - Streamlined Git commands

## 🛠️ Setup

### Quick Setup
```bash
# Set up the complete workflow
./scripts/setup-git-workflow.sh
./scripts/install-git-hooks.sh
```

### Manual Setup
```bash
# Configure Git settings and aliases
./scripts/setup-git-workflow.sh

# Install Git hooks
./scripts/install-git-hooks.sh
```

## 🔄 Daily Workflow

### Starting New Work
```bash
# Create feature branch
git feature-start my-new-feature
# or manually:
git checkout main && git pull && git checkout -b feature/my-new-feature
```

### Making Changes
```bash
# Your normal development workflow
# Edit files, test, etc.

# Check status
git st  # Short alias for status

# Stage changes
git aa  # Add all files
# or selectively: git add <files>

# Commit (with automatic quality checks)
git commit -m "feat: add new card scanning feature"
```

### Pre-commit Quality Gates
When you commit, these checks run automatically:
- ✅ **Sensitive data detection** - Prevents accidental secrets
- ✅ **Code formatting** - Ensures consistent style
- ✅ **Static analysis** - Catches potential issues
- ✅ **Tests** - Validates functionality
- ✅ **Localization** - Regenerates if ARB files changed

### Finishing Work
```bash
# Push feature branch
git push -u origin feature/my-new-feature

# Create Pull Request on GitHub
# After review and merge:

# Clean up locally
git checkout main
git pull
git branch -d feature/my-new-feature
```

## 📝 Commit Message Format

### Conventional Commits
The workflow encourages conventional commit format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation changes
- **style:** Code formatting (no logic change)
- **refactor:** Code restructuring
- **test:** Adding or modifying tests
- **chore:** Maintenance tasks
- **ci:** CI/CD changes
- **perf:** Performance improvements
- **build:** Build system changes
- **revert:** Revert previous commit

### Examples
```bash
git commit -m "feat(auth): add biometric login support"
git commit -m "fix(ui): resolve card alignment on small screens"
git commit -m "docs: update README with new installation steps"
git commit -m "test(models): add unit tests for CardItem validation"
```

## 🚀 Git Aliases

### Status and History
```bash
git st          # Short status
git lg          # Pretty log with graph
git last        # Show last commit
git br          # Verbose branch listing
```

### Branch Management
```bash
git co <branch>           # Checkout branch
git cob <name>           # Create and checkout new branch
git feature-start <name>  # Start new feature branch from main
git feature-finish <name> # Merge feature branch to main
```

### Staging and Committing
```bash
git aa              # Add all files
git unstage <file>  # Unstage file
git undo           # Undo last commit (soft reset)
```

### Flutter-specific
```bash
git flutter-check   # Run analyze + test
git release-check   # Run pre-release checks
git build-info      # Show build status
```

## 🔧 Git Hooks

### Pre-commit Hook
Runs before every commit:
- Checks for sensitive data
- Formats Dart code
- Runs static analysis
- Executes tests (if needed)
- Regenerates localizations

### Prepare-commit-msg Hook
Provides commit message templates and suggestions for conventional commit format.

### Post-merge Hook
Runs after `git pull` or merge:
- Updates dependencies if `pubspec.yaml` changed
- Regenerates localizations if ARB files changed

### Commit-msg Hook
Validates commit messages:
- Minimum length requirement
- Suggests conventional format
- Warns about overly long first lines

## 🛡️ Quality Gates

### Automatic Checks
Every commit is automatically checked for:
- **Code style** - Dart formatter compliance
- **Static analysis** - No linting errors
- **Test coverage** - All tests pass
- **Secrets** - No sensitive data
- **Dependencies** - Up to date after merges

### Manual Checks
Run these commands when needed:
```bash
git flutter-check    # Quick quality check
git release-check     # Comprehensive pre-release checks
./scripts/build-info.sh  # Current status overview
```

## 🌿 Branching Strategy

### Main Branch
- **Protected** - No direct pushes
- **Always deployable** - All checks pass
- **Release ready** - Can create releases anytime

### Feature Branches
- **Short-lived** - Merge quickly
- **Descriptive names** - `feature/add-barcode-scanning`
- **Single purpose** - One feature per branch

### Recommended Flow
```bash
main
├── feature/add-dark-mode
├── feature/improve-scanning
├── bugfix/fix-card-deletion
└── release/v1.0.4
```

## 🚨 Troubleshooting

### Skip Pre-commit Checks
```bash
# Emergency commits only!
git commit --no-verify -m "emergency fix"
```

### Fix Formatting Issues
```bash
# Format all Dart files
dart format .

# Re-stage and commit
git add .
git commit -m "style: fix code formatting"
```

### Resolve Merge Conflicts
```bash
# During merge conflicts:
git status  # See conflicted files
# Edit files to resolve conflicts
git add <resolved-files>
git commit  # Complete the merge
```

### Reset Working Directory
```bash
# Discard all changes
git reset --hard HEAD

# Discard changes to specific file
git checkout -- <file>

# Undo last commit but keep changes
git undo  # Alias for: git reset --soft HEAD~1
```

## 📊 Workflow Benefits

### Developer Experience
- ✅ **Consistent code style** across the team
- ✅ **Early error detection** before CI/CD
- ✅ **Automated maintenance** tasks
- ✅ **Helpful commit templates**

### Code Quality
- ✅ **No broken commits** to main branch
- ✅ **Comprehensive testing** before merge
- ✅ **Static analysis** enforcement
- ✅ **Dependency freshness**

### Team Collaboration
- ✅ **Clear commit history** with conventional format
- ✅ **Predictable workflow** for all developers
- ✅ **Automated quality gates**
- ✅ **Reduced review overhead**

## 🎛️ Configuration

### Disable/Enable Hooks
```bash
# Disable all hooks temporarily
mv .git/hooks .git/hooks.disabled

# Re-enable hooks
mv .git/hooks.disabled .git/hooks

# Disable specific hook
chmod -x .git/hooks/pre-commit
```

### Customize Pre-commit Checks
Edit `scripts/pre-commit-hook.sh` to:
- Skip certain checks
- Add custom validations
- Modify formatting rules

### Update Git Configuration
Edit `scripts/setup-git-workflow.sh` to:
- Add new aliases
- Modify Git settings
- Enhance .gitattributes

## 📈 Advanced Usage

### Release Workflow Integration
```bash
# Complete release with quality checks
git checkout main
git pull
./scripts/master-release.sh  # Includes all quality gates
```

### Dependency Management
```bash
# Update dependencies safely
./scripts/update-dependencies.sh  # Includes tests and rollback
```

### Continuous Integration
The pre-commit hooks align with your CI/CD pipeline, ensuring local checks match remote validation.

---

**Your Git workflow is now production-ready! 🎉**

This system ensures code quality, prevents issues, and streamlines development while maintaining flexibility for edge cases.
