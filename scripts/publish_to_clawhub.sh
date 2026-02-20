#!/usr/bin/env bash
# publish_to_clawhub.sh
# Publish a skill to ClawhHub registry
# Usage: publish_to_clawhub.sh <skill_dir> [version] [changelog]
# Requires: clawhub CLI logged in (clawhub login)

set -e

SKILL_DIR="${1:?Usage: publish_to_clawhub.sh <skill_dir> [version] [changelog]}"
VERSION="${2:-1.0.0}"
CHANGELOG="${3:-Initial release}"

SKILL_NAME=$(basename "$SKILL_DIR")

echo "🚀 Publishing $SKILL_NAME to ClawhHub..."

# Check login
if ! clawhub whoami &>/dev/null; then
  echo "❌ Not logged in to ClawhHub. Run: clawhub login"
  exit 1
fi

clawhub publish "$SKILL_DIR" \
  --slug "$SKILL_NAME" \
  --name "$SKILL_NAME" \
  --version "$VERSION" \
  --changelog "$CHANGELOG"

echo "✅ Published: https://clawhub.com/skills/$SKILL_NAME"
