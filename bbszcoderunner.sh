#!/bin/bash
#
# bbszcoderunner.sh — Secure wrapper for running Frotz/dfrotz in a BBS door environment
# 
# Copyright (C) 2025 Your Name
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# ========== Configuration ==========
set -euo pipefail

# --- Configurable paths ---
FROTZ_CMD="/usr/bin/frotz"
DFROTZ_CMD="/usr/bin/dfrotz"
SAVE_BASE_DIR="/opt/mystic/doors/zcode/saves"
GAME_BASE_DIR="/opt/mystic/doors/zcode/games"
USERNAME_MAP="/opt/mystic/doors/zcode/usernames.map"
LOG_FILE="/opt/mystic/doors/zcode/bbszcoderunner.log"
VERSION="1.0.0"

# --- Usage message ---
usage() {
  echo "Usage: $0 [-d] [-b] [-h] [-v] <username> <game_file.z[1-8]>"
  echo "  -d      Use dfrotz instead of frotz"
  echo "  -b      Enable debug logging"
  echo "  -h      Show this help message"
  echo "  -v      Show script version"
  exit 1
}

# --- Parse flags ---
USE_DFROTZ=false
DEBUG=false

while getopts ":dbhv" opt; do
  case ${opt} in
    d)
      USE_DFROTZ=true
      ;;
    b)
      DEBUG=true
      ;;
    h)
      usage
      ;;
    v)
      echo "bbszcoderunner.sh version $VERSION"
      exit 0
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# --- Validate arguments ---
if [[ $# -ne 2 ]]; then
  usage
fi

username="$1"
game_file="$2"

if [[ ! "$game_file" =~ \.z[1-8]$ ]]; then
  echo "Error: Game file must end in .z1 through .z8"
  exit 1
fi

game_file_path="$GAME_BASE_DIR/$game_file"
if [[ ! -f "$game_file_path" ]]; then
  echo "Error: Game file not found: $game_file_path"
  exit 1
fi

# --- Choose interpreter ---
frotz_command="$FROTZ_CMD"
if [ "$USE_DFROTZ" = true ]; then
  frotz_command="$DFROTZ_CMD"
fi

# --- Sanitize username ---
sanitize_username() {
  echo "$1" | tr -cd '[:alnum:]_-'
}

if [[ ! -f "$USERNAME_MAP" ]]; then
  touch "$USERNAME_MAP"
fi

sanitized_username=$(grep -F "^${username}:" "$USERNAME_MAP" | cut -d: -f2)

if [[ -z "$sanitized_username" ]]; then
  sanitized_username=$(sanitize_username "$username")
  {
    flock -e 200
    echo "${username}:${sanitized_username}" >> "$USERNAME_MAP"
  } 200>"$USERNAME_MAP"
  $DEBUG && echo "Sanitized username: $sanitized_username" >> "$LOG_FILE"
else
  $DEBUG && echo "Reusing sanitized username: $sanitized_username" >> "$LOG_FILE"
fi

# --- Setup save directory ---
game_save_dir="$SAVE_BASE_DIR/$game_file/$sanitized_username"
mkdir -p "$game_save_dir"

# --- Logging ---
$DEBUG && {
  echo "---" >> "$LOG_FILE"
  echo "Game started: $(date)" >> "$LOG_FILE"
  echo "User: $username -> $sanitized_username" >> "$LOG_FILE"
  echo "Game file: $game_file_path" >> "$LOG_FILE"
}

# --- Run the game ---
cd "$game_save_dir"
"$frotz_command" -R "$game_save_dir" "$game_file_path"

# --- Cleanup old save files ---
save_files=("$game_save_dir"/*.qzl "$game_save_dir"/*.sav)
latest_save="$(ls -t ${save_files[@]} 2>/dev/null | head -n1)"

$DEBUG && {
  echo "Deleting old save files, keeping only the newest: $latest_save" >> "$LOG_FILE"
}

for file in "${save_files[@]}"; do
  if [[ "$file" != "$latest_save" ]]; then
    rm -f "$file"
    $DEBUG && echo "Deleted save file: $file" >> "$LOG_FILE"
  fi
done

# --- Final log ---
$DEBUG && echo "Game ended: $(date)" >> "$LOG_FILE"
