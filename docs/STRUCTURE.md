# Documentation Structure

This file shows the current organization of all documentation.

```
docs/
├── README.md                    # 📚 Main documentation index
├── STRUCTURE.md                 # 📋 This file - documentation organization
├── workflows/                   # 🔧 Development workflows
│   ├── GIT_WORKFLOW.md         # Git workflow automation
│   ├── GIT_WORKFLOW_SUMMARY.md # Quick Git reference
│   ├── DEPENDENCY_MANAGEMENT.md # Flutter dependencies
│   └── LOCALIZATION_WORKFLOW.md # App translations
├── guides/                      # 📖 Development guides
│   ├── RELEASE.md              # Release process guide
│   ├── TEST_COVERAGE.md        # Testing strategy
│   └── REFACTORING_COMPLETE.md # Refactoring history
└── generated/                   # 🤖 Auto-generated files
    ├── smart-release-notes-*.md # Generated release notes
    └── ...                     # Other generated docs

../scripts/                      # 🛠️ Related script documentation
├── README.md                   # Scripts overview
└── RELEASE_NOTES_GUIDE.md      # Release notes automation

../                             # 📱 Root level documentation
├── README.md                   # Main project README
└── PRIVACY_POLICY.md          # Privacy policy
```

## Documentation Guidelines

### File Naming
- Use kebab-case for multi-word files: `git-workflow.md`
- Use UPPER_CASE for important guides: `README.md`, `RELEASE.md`
- Prefix generated files with type: `smart-release-notes-v1.0.2.md`

### Organization
- **workflows/**: How to do development tasks
- **guides/**: What to know about the project
- **generated/**: Auto-created files (don't edit manually)

### Maintenance
- Run `./scripts/docs-maintenance.sh` periodically
- Update timestamps in documentation index
- Check for broken links regularly
- Move generated files to proper directories

