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

# === Base Directory Configuration ===
BASE_DIR="/opt/mystic/doors/zcode"
FROTZ_CMD="/usr/games/frotz"
DFROTZ_CMD="/usr/games/dfrotz"

SAVE_BASE_DIR="$BASE_DIR/saves"
GAME_BASE_DIR="$BASE_DIR/games"
LOG_BASE_DIR="$BASE_DIR/logs"
USERNAME_MAP="$BASE_DIR/usernames.map"
LOG_FILE="$LOG_BASE_DIR/zcode-frotz.log"
VERSION="1.0.2"

USE_DFROTZ=false
DEBUG=false

# === Logging helper ===
log_debug() {
    if [[ "$DEBUG" == true ]]; then
        mkdir -p "$(dirname "$LOG_FILE")"
        echo "$(date '+%F %T') DEBUG: $*" >> "$LOG_FILE"
    fi
}

# === Sanitize username ===
sanitize_username() {
    local raw="$1"
    echo "$raw" | tr -dc '[:alnum:]_-'
}

# === Parse options ===
while getopts ":dbhv" opt; do
    case "$opt" in
        d) USE_DFROTZ=true ;;
        b) DEBUG=true ;;
        h)
            echo "Usage: $0 [-d] [-b] <username> <game_file>"
            echo "  -d : Use dfrotz instead of frotz"
            echo "  -b : Enable debug logging"
            echo "  -h : Show help"
            echo "  -v : Show version"
            exit 0
            ;;
        v)
            echo "$0 version $VERSION"
            exit 0
            ;;
        \?)
            echo "Unknown option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

# === Check required args ===
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 [-d] [-b] <username> <game_file>" >&2
    exit 1
fi

username="$1"
game_file="$2"

# === Validate game file ===
if [[ ! "$game_file" =~ \.z[1-8]$ ]]; then
    echo "Unsupported file type: $game_file" >&2
    exit 1
fi

game_path="$GAME_BASE_DIR/$game_file"
if [[ ! -f "$game_path" ]]; then
    echo "Game file not found: $game_path" >&2
    exit 1
fi

# === Resolve sanitized username ===
mkdir -p "$(dirname "$USERNAME_MAP")"
touch "$USERNAME_MAP"

sanitized=$(grep -F "^${username}:" "$USERNAME_MAP" | cut -d: -f2 || true)
if [[ -z "$sanitized" ]]; then
    sanitized=$(sanitize_username "$username")
    echo "${username}:${sanitized}" >> "$USERNAME_MAP"
    log_debug "Added new sanitized username: $sanitized"
else
    log_debug "Reusing sanitized username: $sanitized"
fi

# === Setup save directory ===
game_save_dir="$SAVE_BASE_DIR/$game_file/$sanitized"
mkdir -p "$game_save_dir"
log_debug "Save directory: $game_save_dir"

# === Select interpreter ===
frotz_cmd="$FROTZ_CMD"
[[ "$USE_DFROTZ" == true ]] && frotz_cmd="$DFROTZ_CMD"
log_debug "Interpreter: $frotz_cmd"

# === Run game ===
log_debug "Running: $frotz_cmd -R \"$game_save_dir\" \"$game_path\""
exec "$frotz_cmd" -R "$game_save_dir" "$game_path"
