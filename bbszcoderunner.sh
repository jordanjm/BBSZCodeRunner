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
#!/bin/bash

# Paths and variables
BASEDIR="/opt/mystic/doors/zcode"
LOG_DIR="$BASEDIR/log"
LOG_FILE="$LOG_DIR/zcode-frotz.log"
GAME_DIR="$BASEDIR/games"
SAVES_DIR="$BASEDIR/saves"
USERNAME_MAP="$BASEDIR/usernames.map"
frotz_path="/usr/games/frotz"
dfrotz_path="/usr/games/dfrotz"

# Defaults
debug_mode=false
frotz_command="$frotz_path"

# Sanitize the username (replace invalid characters)
sanitize_username() {
    echo "$1" | sed 's/[^a-zA-Z0-9_-]/_/g'
}

# Ensure required directories exist
mkdir -p "$LOG_DIR" "$SAVES_DIR"

# Parse required args
username="$1"
game_file="$2"
shift 2

# Parse optional flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        -b) debug_mode=true ;;
        -d) frotz_command="$dfrotz_path" ;;
    esac
    shift
done

# Log start time
echo "Script started at $(date)" >> "$LOG_FILE"
echo "Game file being used: $game_file" >> "$LOG_FILE"
echo "Starting game with sanitized username '$username'" >> "$LOG_FILE"

# Check username map
sanitized_username=$(grep -F "^${username}:" "$USERNAME_MAP" | cut -d: -f2)

if [[ -z "$sanitized_username" ]]; then
    sanitized_username=$(sanitize_username "$username")
    if ! grep -q "^${username}:" "$USERNAME_MAP"; then
        echo "${username}:${sanitized_username}" >> "$USERNAME_MAP"
        $debug_mode && echo "Added sanitized username to map: ${username}:${sanitized_username}" >> "$LOG_FILE"
    fi
else
    $debug_mode && echo "Reusing sanitized username: $sanitized_username" >> "$LOG_FILE"
fi

# Prepare paths
game_file_path="$GAME_DIR/$game_file"
game_save_dir="$SAVES_DIR/$(basename "$game_file")/$sanitized_username"
mkdir -p "$game_save_dir"

if [[ ! -f "$game_file_path" ]]; then
    echo "Error: Game file $game_file_path does not exist!" >> "$LOG_FILE"
    exit 1
fi

# Run game
cd "$game_save_dir" || exit 1
"$frotz_command" -R "$game_save_dir" "$game_file_path"

# After game: cleanup save files
save_files=("$game_save_dir"/*.{sav,qzl})
if [[ ${#save_files[@]} -gt 1 ]]; then
    latest_save=$(ls -t "$game_save_dir"/*.{sav,qzl} 2>/dev/null | head -n 1)
    $debug_mode && echo "Keeping latest save: $latest_save" >> "$LOG_FILE"
    for save_file in "${save_files[@]}"; do
        [[ "$save_file" != "$latest_save" ]] && rm -f "$save_file" && $debug_mode && echo "Deleted: $save_file" >> "$LOG_FILE"
    done
else
    $debug_mode && echo "Only one or no save file found. Skipping deletion." >> "$LOG_FILE"
fi

# End log
echo "Game finished for user '$sanitized_username'" >> "$LOG_FILE"
echo "Script ended at $(date)" >> "$LOG_FILE"
