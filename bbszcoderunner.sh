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
# Paths and variables
BASEDIR="/opt/mystic/doors/zcode"
LOG_DIR="$BASEDIR/log"
LOG_FILE="$LOG_DIR/zcode-frotz.log"
GAME_DIR="$BASEDIR/games"
SAVES_DIR="$BASEDIR/saves"
USERNAME_MAP="$BASEDIR/usernames.map"
frotz_command="frotz"  # Or dfrotz if using that

# Ensure log and save directories exist
mkdir -p "$LOG_DIR" "$SAVES_DIR"

# Sanitize the username (replace invalid characters)
sanitize_username() {
    sanitized=$(echo "$1" | sed 's/[^a-zA-Z0-9_-]/_/g')
    echo "$sanitized"
}

# Input parameters
username=$1
game_file=$2
debug_mode=false  # Default is not in debug mode

# Check for -b flag to turn on debugging
if [[ "$3" == "-b" ]]; then
    debug_mode=true
fi

# Capture script start time and initial message
if $debug_mode; then
    echo "Script started at $(date)" >> "$LOG_FILE"
    echo "Running game with unsanitized username: $username" >> "$LOG_FILE"
fi

# Check for sanitized username in the map
sanitized_username=$(grep -F "^${username}:" "$USERNAME_MAP" | cut -d: -f2)

if [[ -z "$sanitized_username" ]]; then
    # If no sanitized username found, sanitize and add it
    sanitized_username=$(sanitize_username "$username")
    if $debug_mode; then
        echo "Sanitized username: $sanitized_username" >> "$LOG_FILE"
    fi
    
    # Ensure unique sanitized username and add to map if new
    if ! grep -q "^${username}:" "$USERNAME_MAP"; then
        echo "${username}:${sanitized_username}" >> "$USERNAME_MAP"
        if $debug_mode; then
            echo "Added sanitized username to map: ${username}:${sanitized_username}" >> "$LOG_FILE"
        fi
    else
        if $debug_mode; then
            echo "Username already exists in map, skipping addition." >> "$LOG_FILE"
        fi
    fi
else
    if $debug_mode; then
        echo "Reusing sanitized username: $sanitized_username" >> "$LOG_FILE"
    fi
fi

# Prepare the save directory for the game
game_save_dir="$SAVES_DIR/$(basename "$game_file")/$sanitized_username"
mkdir -p "$game_save_dir"

# Ensure the game file exists
game_file_path="$GAME_DIR/$game_file"
if [[ ! -f "$game_file_path" ]]; then
    echo "Error: Game file $game_file does not exist!" >> "$LOG_FILE"
    exit 1
fi

# Log starting game info
if $debug_mode; then
    echo "Game file being used: $game_file" >> "$LOG_FILE"
    echo "Starting game with sanitized username '$sanitized_username'..." >> "$LOG_FILE"
fi

# Start the game, without redirecting standard output (it remains to terminal)
cd "$game_save_dir" || exit 1
"$frotz_command" -R "$game_save_dir" "$game_file_path"

# Log after the game finishes
if $debug_mode; then
    echo "Game finished with sanitized username '$sanitized_username'" >> "$LOG_FILE"
fi

# Delete old save files except the newest
save_files=("$game_save_dir"/*.{sav,qzl})
if [[ ${#save_files[@]} -gt 1 ]]; then
    latest_save=$(ls -t "$game_save_dir"/*.{sav,qzl} | head -n 1)
    if $debug_mode; then
        echo "Deleting old save files, keeping only the newest: $latest_save" >> "$LOG_FILE"
    fi
    
    # Remove all except the latest save
    for save_file in "${save_files[@]}"; do
        if [[ "$save_file" != "$latest_save" ]]; then
            rm -f "$save_file"
            if $debug_mode; then
                echo "Deleted save file: $save_file" >> "$LOG_FILE"
            fi
        fi
    done
else
    if $debug_mode; then
        echo "Only one save file found, skipping deletion." >> "$LOG_FILE"
    fi
fi

# Capture script end time
if $debug_mode; then
    echo "Script ended at $(date)" >> "$LOG_FILE"
fi
