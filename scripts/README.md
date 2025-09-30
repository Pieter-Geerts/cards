# scripts/

This folder contains helper scripts used by the project for releases, testing and documentation.

Purpose
- Keep scripts discoverable and documented.
- Provide a helper to normalize shebangs and make scripts executable safely.
# scripts/

This folder contains helper scripts used by the project for releases, testing and documentation.

## Purpose

- Keep scripts discoverable and documented.
- Provide a helper to normalize shebangs and make scripts executable safely.

## Common scripts

- `build-info.sh` - Print build metadata.
- `bump-version.sh` - Bump project version and tags.
- `docs-maintenance.sh` - Run documentation cleanup and checks (timestamps, generated files).
- `generate-localizations.sh` - Run Flutter localization generation.
- `generate-release-notes.sh` - Create release notes drafts.
- `install-git-hooks.sh` - Install repository git hooks (pre-commit, pre-push, ...).
- `pre-commit-hook.sh`, `pre-push.sh` - Hook scripts referenced by `install-git-hooks.sh`.
- `run-tests.sh` - Run the project's test suite locally.
- `release.sh`, `master-release.sh`, `quick-release.sh` - Various release helpers.

## How to use

Run a script directly from the repository root. Example:

```bash
./scripts/run-tests.sh
```

If you see scripts with inconsistent shebangs or missing execute bits, run the helper below:

```bash
./scripts/normalize-shebangs.sh
```

### About `normalize-shebangs.sh`

- The helper will rewrite the first line of `*.sh` files to `#!/usr/bin/env bash` and add execute permissions.
- It only operates on regular files in `scripts/` (not subdirectories) and keeps a `.bak` when updating (deleted afterwards).

### Safety notes

- The script updates files in-place. Use Git to review changes and revert if needed.

---

# Release helper scripts

This section lists common release and automation scripts found in this directory.

| Script                      | Purpose                                | Usage                                       |
| --------------------------- | -------------------------------------- | ------------------------------------------- |
| `master-release.sh`         | Guided release process                 | `./master-release.sh`                       |
| `quick-release.sh`          | Quick patch release                    | `./quick-release.sh`                        |
| `release.sh`                | Full release with options              | `./release.sh [patch\|minor\|major\|X.Y.Z]` |
| `update-dependencies.sh`    | Update Flutter dependencies            | `./update-dependencies.sh`                  |
| `generate-localizations.sh` | Generate localization files            | `./generate-localizations.sh`               |
| `install-git-hooks.sh`      | Install Git hooks                      | `./install-git-hooks.sh`                    |
| `docs-maintenance.sh`       | Documentation maintenance              | `./docs-maintenance.sh`                     |
| `smart-release-notes.sh`    | Smart release notes generator          | `./smart-release-notes.sh [from] [to]`      |
| `generate-release-notes.sh` | Basic release notes from commits       | `./generate-release-notes.sh [from] [to]`   |
| `review-release-notes.sh`   | Release notes reviewer & editor        | `./review-release-notes.sh [file]`          |
| `build-info.sh`             | Show app and build status              | `./build-info.sh`                           |
| `run-tests.sh`              | Run the project's tests                | `./run-tests.sh`                            |
| `bump-version.sh`           | Version management helper              | `./bump-version.sh [type\|version]`         |

## Typical workflow

1. Check status: `./build-info.sh`
2. Run checklist: `./release-checklist.sh`
3. Create release: `./master-release.sh` or `./quick-release.sh`
4. Upload generated AAB/AAP to Play Store as needed

## Tips

- Scripts aim to be safe and idempotent; review changes with Git before committing.
- Use `./scripts/normalize-shebangs.sh` if you see inconsistent shebangs or missing execute bits.

---

Happy releasing!


See `../GIT_WORKFLOW.md` for complete documentation.

## 📦 Dependency Management

Keep your Flutter dependencies up to date with automated tools.

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
