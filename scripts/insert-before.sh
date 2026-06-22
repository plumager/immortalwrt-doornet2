#!/usr/bin/env bash
# Insert file contents BEFORE the line matching pattern
# Usage: insert-before.sh <target_file> <pattern> <insert_file>
set -e
TARGET="$1"
PATTERN="$2"
INSERT="$3"
TMP="${TARGET}.tmp"
# Use awk to insert file contents before matching line
awk -v pattern="$PATTERN" -v insert="$INSERT" '
  $0 ~ pattern {
    while ((getline line < insert) > 0) print line
  }
  { print }
' "$TARGET" > "$TMP"
mv "$TMP" "$TARGET"
echo "Inserted $INSERT before \"$PATTERN\" in $TARGET"
