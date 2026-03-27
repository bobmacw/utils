#!/bin/bash

# open_incognito.sh
# Opens all URLs from a file in Chrome incognito tabs (using AppleScript)
#
# Usage: ./open_incognito.sh [-p /path/to/folder] [-f filename.txt]
#   -p  Directory containing the URL file (default: same folder as this script)
#   -f  Name of the URL file (default: tabs.txt)
#
# Examples:
#   ./open_incognito.sh                             # uses ./tabs.txt
#   ./open_incognito.sh -f work.txt                 # uses ./work.txt
#   ./open_incognito.sh -p ~/Documents              # uses ~/Documents/tabs.txt
#   ./open_incognito.sh -p ~/Documents -f work.txt  # uses ~/Documents/work.txt

SCRIPT_DIR="$(dirname "$0")"
URL_PATH=""
URL_FILE=""

while getopts "p:f:" opt; do
  case $opt in
    p) URL_PATH="$OPTARG" ;;
    f) URL_FILE="$OPTARG" ;;
    *) echo "Usage: $0 [-p /path/to/folder] [-f filename.txt]"; exit 1 ;;
  esac
done

# Apply defaults
URL_PATH="${URL_PATH:-$SCRIPT_DIR}"
URL_FILE="${URL_FILE:-tabs.txt}"
URL_FULL="$URL_PATH/$URL_FILE"

if [ ! -f "$URL_FULL" ]; then
  echo "Error: URL file not found at '$URL_FULL'"
  echo "Usage: $0 [-p /path/to/folder] [-f filename.txt]"
  exit 1
fi

# Read URLs, skipping blank lines and lines starting with #
URLS=()
while IFS= read -r line; do
  line=$(echo "$line" | xargs)  # trim whitespace
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
