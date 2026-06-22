#!/usr/bin/env bash
# Insert file contents BEFORE the line matching pattern (literal string match)
# Usage: insert-before.sh <target_file> <pattern> <insert_file>
set -e
TARGET="$1"
PATTERN="$2"
INSERT="$3"
TMP="${TARGET}.tmp"
# Use awk index() for literal string matching (not regex)
awk -v pattern="$PATTERN" -v insert="$INSERT" '
  index($0, pattern) {
    while ((getline line < insert) > 0) print line
    matched = 1
  }
  { print }
  END { if (!matched) { print "WARNING: Pattern not found: " pattern > "/dev/stderr"; exit 1 } }
' "$TARGET" > "$TMP"
mv "$TMP" "$TARGET"
echo "Inserted $INSERT before \"$PATTERN\" in $TARGET"
