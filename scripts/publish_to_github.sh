#!/usr/bin/env bash
# publish_to_github.sh
# Create a GitHub repo and upload skill files via gh API (no git push needed)
# Usage: publish_to_github.sh <skill_dir> <github_owner> [description]

set -e

SKILL_DIR="${1:?Usage: publish_to_github.sh <skill_dir> <github_owner> [description]}"
OWNER="${2:?Usage: publish_to_github.sh <skill_dir> <github_owner> [description]}"
DESCRIPTION="${3:-OpenClaw agent skill}"

SKILL_NAME=$(basename "$SKILL_DIR")
REPO="$OWNER/$SKILL_NAME"

echo "📦 Publishing $SKILL_NAME to GitHub..."

# 1. Create repo (skip if exists)
if gh api "repos/$REPO" --jq '.html_url' 2>/dev/null; then
  echo "  ℹ️  Repo already exists: https://github.com/$REPO"
else
  gh repo create "$REPO" --public --description "$DESCRIPTION" 2>&1
  echo "  ✅ Created: https://github.com/$REPO"
fi

# 2. Upload all files via API
upload_file() {
  local rel_path="$1"
  local abs_path="$SKILL_DIR/$rel_path"
  local content
  content=$(cat "$abs_path" | /usr/bin/base64)

  # Check if file already exists (get its SHA for update)
  local sha
  sha=$(gh api "repos/$REPO/contents/$rel_path" --jq '.sha' 2>/dev/null || echo "")

  if [ -n "$sha" ]; then
    gh api --method PUT "repos/$REPO/contents/$rel_path" \
      -f message="Update $rel_path" \
      -f content="$content" \
      -f sha="$sha" \
      --jq '.content.path' 2>&1
  else
    gh api --method PUT "repos/$REPO/contents/$rel_path" \
      -f message="Add $rel_path" \
      -f content="$content" \
      --jq '.content.path' 2>&1
  fi
}

echo "  📤 Uploading files..."
find "$SKILL_DIR" -type f \
  -not -path "*/.git/*" \
  -not -path "*/node_modules/*" \
  -not -name "*.skill" \
  | while read -r abs_path; do
    rel_path="${abs_path#$SKILL_DIR/}"
    echo -n "    $rel_path ... "
    upload_file "$rel_path"
  done

echo ""
echo "✅ Done: https://github.com/$REPO"
