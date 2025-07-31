#!/bin/bash
# Watches the repository directory for changes and then syncs the addon files into your WoW directory
# Requires inotify-tools (apt install inotify-tools on WSL2)
# Usage: ./development.sh [addon install directory]

ADDON_NAME=PinyinNext

# Get the directory of the script itself (even when sourced or symlinked)
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${1:-/mnt/c/Program Files (x86)/World of Warcraft/_retail_/Interface/AddOns/${ADDON_NAME}}"

EXCLUDES=(
  "--exclude=.*"
  "--exclude=development.sh"
  "--exclude=LICENSE"
  "--exclude=pkgmeta.yaml"
  "--exclude=README.md"
)

# Construct rsync command
COPY_CMD="rsync --archive --delete --verbose ${EXCLUDES[*]} \"$SRC_DIR/\" \"$DEST_DIR\""

echo "Initial sync from $SRC_DIR to $DEST_DIR..."
eval $COPY_CMD

echo "Watching $SRC_DIR for changes to .lua, .xml, or .toc files..."
echo "Changes will be synced to: $DEST_DIR"

# Watch for modify, create, delete, move events on specific file types
inotifywait -m -r -e modify -e create -e delete -e move \
  --format '%w%f' \
  --exclude '(^|/)\..*' \
  "$SRC_DIR" | while read FILE
do
  if [[ "$FILE" =~ \.(lua|xml|toc)$ ]]; then
    echo "Change detected in $FILE. Syncing..."
    eval $COPY_CMD
    echo "Sync complete."
  fi
done
