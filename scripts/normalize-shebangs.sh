#!/usr/bin/env bash
# normalize-shebangs.sh
# Ensure shell scripts in ./scripts have a portable shebang and are executable.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"

echo "Normalizing shebangs and permissions in: $SCRIPTS_DIR"

shopt -s nullglob
for f in "$SCRIPTS_DIR"/*.sh; do
    if [ ! -f "$f" ]; then
        continue
    fi
    echo "Processing: $(basename "$f")"

    # Read the first line
    read -r first_line < "$f" || first_line=""

    # If first line is not the desired shebang, replace it
    desired='#!/usr/bin/env bash'
    if [[ "$first_line" != "$desired" ]]; then
        echo "  - Updating shebang"
        cp "$f" "$f.bak"
        # Use awk to replace first line safely
        awk -v shebang="$desired" 'NR==1{print shebang; next} {print}' "$f.bak" > "$f"
        rm -f "$f.bak"
    else
        echo "  - Shebang already normalized"
    fi

    # Add execute permission for owner
    chmod u+x "$f"
done

echo "Done. Review changes with: git status --porcelain && git diff"
