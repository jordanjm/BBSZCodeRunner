#!/bin/bash

# ----------------------------------------------------------------------------
# BBSZCodeRunner - A script to run Z-Code games on Mystic BBS with game save support.
# BBSZCodeInstall - A script to create the file structure and permissions needed for BBSZCodeRunner.
#
# Created by jordanjm (jordanjm@excalibursheath.com)
# Developed for Mystic BBS at bbs.excalibursheath.com
#
# GitHub Repository: https://github.com/jordanjm/BBSZCodeRunner
#
# Copyright (C) 2025 jordanjm
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# ----------------------------------------------------------------------------

# Configuration
BASE_DIR="/set/base/directory/"
GAME_DIR="$BASE_DIR/games"
SAVE_DIR="$BASE_DIR/saves"
LOG_FILE="$BASE_DIR/bbszcoderunner.log"
USERNAME_MAP="$BASE_DIR/usernames.map"
OWNER="bbsuser"          # Change to your user
GROUP="bbs"              # Change to your group
DIR_PERMS=775            # drwxrwxr-x
FILE_PERMS=664           # -rw-rw-r--

# Create necessary directories
echo "Creating directories..."
mkdir -p "$GAME_DIR" "$SAVE_DIR"
echo "Directories ensured: $GAME_DIR, $SAVE_DIR"

# Create usernames.map if it doesn't exist
if [ ! -f "$USERNAME_MAP" ]; then
    touch "$USERNAME_MAP"
    echo "Created usernames.map"
fi

# Create the log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    echo "Created log file: $LOG_FILE"
fi

# Set ownership and permissions
echo "Setting ownership and permissions..."
chown -R "$OWNER:$GROUP" "$BASE_DIR"
chmod -R "$DIR_PERMS" "$GAME_DIR" "$SAVE_DIR"
chmod "$FILE_PERMS" "$USERNAME_MAP" "$LOG_FILE"

echo "Environment setup complete."
