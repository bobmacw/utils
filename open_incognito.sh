#!/bin/bash

# open_incognito.sh
# Opens all URLs from a file in Chrome incognito tabs (using AppleScript)
#
# Usage: ./open_incognito.sh [-p /path/to/folder] [-f filename.txt]
#   -p  Directory containing the URL file (default: $SCRIPT_DIR or script's own directory)
#   -f  Name of the URL file (default: tabs.txt)
#
# Examples:
#   ./open_incognito.sh                             # uses $SCRIPT_DIR/tabs.txt
#   ./open_incognito.sh -f work.txt                 # uses $SCRIPT_DIR/work.txt
#   ./open_incognito.sh -p ~/Documents              # uses ~/Documents/tabs.txt
#   ./open_incognito.sh -p ~/Documents -f work.txt  # uses ~/Documents/work.txt

URL_DIR=""
URL_FILE=""

while getopts "p:f:" opt; do
  case $opt in
    p) URL_DIR="$OPTARG" ;;
    f) URL_FILE="$OPTARG" ;;
    *) echo "Usage: $0 [-p /path/to/folder] [-f filename.txt]"; exit 1 ;;
  esac
done

# Apply defaults
URL_DIR="${URL_DIR:-$SCRIPT_DIR}"
URL_FILE="${URL_FILE:-tabs.txt}"
URL_FULL="$URL_DIR/$URL_FILE"

if [ ! -f "$URL_FULL" ]; then
  echo "Error: URL file not found at '$URL_FULL'"
  echo "Usage: $0 [-p /path/to/folder] [-f filename.txt]"
  exit 1
fi

# Read URLs, skipping blank lines, whitespace-only lines, and lines starting with #
URLS=()
while IFS= read -r line; do
  line="${line//[$'\t\r\n']}"  # strip tabs and carriage returns
  line="${line## }"             # strip leading spaces
  line="${line%% }"             # strip trailing spaces
  [[ -z "$line" || "$line" == \#* ]] && continue
  URLS+=("$line")
done < "$URL_FULL"

if [ ${#URLS[@]} -eq 0 ]; then
  echo "No URLs found in '$URL_FULL'"
  exit 1
fi

echo "Opening ${#URLS[@]} tab(s) from '$URL_FILE' in Chrome incognito..."

# Open the first URL in a new incognito window
osascript <<EOF
tell application "Google Chrome"
  make new window with properties {mode:"incognito"}
  set URL of active tab of window 1 to "${URLS[0]}"
end tell
EOF

# Open remaining URLs as additional tabs in that incognito window
for url in "${URLS[@]:1}"; do
  osascript <<EOF
tell application "Google Chrome"
  tell window 1
    make new tab with properties {URL:"$url"}
  end tell
end tell
EOF
done

echo "Done."
