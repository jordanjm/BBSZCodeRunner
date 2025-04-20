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

# Define the root path
BASE_DIR="/opt/mystic/doors/zcode-frotz"

# Define directories for games, saves, and logs
GAMES_DIR="${BASE_DIR}/games"
SAVES_DIR="${BASE_DIR}/saves"
LOG_DIR="${BASE_DIR}/log"

# Define the mystic user and group (make sure mystic exists)
MYSTIC_USER="mystic"
MYSTIC_GROUP="mystic"

# Function to create directories and set permissions
create_dirs() {
    echo "Creating directory structure..."

    # Create the main directories if they don't exist
    mkdir -p "$GAMES_DIR"
    mkdir -p "$SAVES_DIR"
    mkdir -p "$LOG_DIR"

    # Create subdirectories for each game in the saves directory
    for GAME in $(ls "$GAMES_DIR"); do
        GAME_NAME="${GAME%.*}"  # Strip the extension from the game file name
        mkdir -p "$SAVES_DIR/$GAME_NAME"
    done

    # Set permissions for the directories and files
    echo "Setting directory permissions..."

    # Set ownership to mystic:mystic for all relevant directories
    chown -R "$MYSTIC_USER":"$MYSTIC_GROUP" "$BASE_DIR"

    # Set appropriate permissions for the game, saves, and log directories
    chmod 755 "$GAMES_DIR"        # Games should be readable and executable
    chmod 700 "$SAVES_DIR"        # Saves should be private
    chmod 700 "$LOG_DIR"          # Logs should be private

    # Set permissions for each game's save directory
    for GAME_DIR in "$SAVES_DIR"/*; do
        if [ -d "$GAME_DIR" ]; then
            chmod 700 "$GAME_DIR"
        fi
    done

    # Set permissions for log files (ensure only mystic can write)
    chmod 600 "$LOG_DIR"/*.log

    echo "Directory structure and permissions have been set."
}

# Function to ensure the script is not run as root
check_if_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "This script should NOT be run as root. Exiting."
        exit 1
    fi
}

# Check if the mystic user exists, if not, exit with error
check_mystic_user() {
    if ! id "$MYSTIC_USER" &>/dev/null; then
        echo "User '$MYSTIC_USER' does not exist. Please create the user first. Exiting."
        exit 1
    fi
}

# Run checks before proceeding
check_if_root
check_mystic_user

# Run the directory creation function
create_dirs

echo "Setup complete!"
