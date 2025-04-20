#!/bin/bash

# Define the root path for the game setup
BASE_DIR="/opt/mystic/doors/zcode"

# Define directories for games, saves, and logs
GAMES_DIR="${BASE_DIR}/games"
SAVES_DIR="${BASE_DIR}/saves"
LOG_DIR="${BASE_DIR}/log"

# Define the mystic user and group
MYSTIC_USER="mystic"
MYSTIC_GROUP="mystic"

# Secret username flag to identify existing usernames
SECRET_USERNAME_FLAG="-sun"

# Function to prevent running as root
check_for_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "This script cannot be run as root. Exiting."
        exit 1
    fi
}

# Ensure we don't run as root
check_for_root

# Ensure directories exist
mkdir -p "$GAMES_DIR"
mkdir -p "$SAVES_DIR"
mkdir -p "$LOG_DIR"

# Ensure log files exist in the log directory
touch "$LOG_DIR/zcode-jzip.log"

# Set file permissions (so the mystic user can access them without root)
chmod 755 "$GAMES_DIR"           # Games should be readable and executable
chmod 700 "$SAVES_DIR"           # Saves should be private
chmod 700 "$LOG_DIR"             # Logs should be private

# Set appropriate log file permissions (ensure only mystic can write)
chmod 600 "$LOG_DIR"/*.log

# Function to sanitize username (same as before)
sanitize_username() {
    local username="$1"
    sanitized_username=$(echo "$username" | tr -cd 'a-zA-Z0-9_')
    echo "$sanitized_username"
}

# Check if username is a secret one
handle_secret_username_flag() {
    local username="$1"
    if [[ "$username" == *"$SECRET_USERNAME_FLAG" ]]; then
        # Remove the flag part
        username="${username%-sun}"
        # Check if this is an existing user in the lookup file
        # If so, use their sanitized version from the user file
        SANITIZED_USER=$(grep "^$username" "$USER_LOOKUP_FILE" | awk '{print $2}')
        if [ -z "$SANITIZED_USER" ]; then
            # If the user does not exist, treat this as a new username
            echo "This username doesn't exist in the lookup file, treating as new." >> "$LOG_DIR/zcode-jzip.log"
            SANITIZED_USER=$(sanitize_username "$username")
        else
            echo "Using existing sanitized username: $SANITIZED_USER" >> "$LOG_DIR/zcode-jzip.log"
        fi
    else
        # If it's not a secret, sanitize as usual
        SANITIZED_USER=$(sanitize_username "$username")
    fi
    echo "$SANITIZED_USER"
}

# Look-up file location
USER_LOOKUP_FILE="$BASE_DIR/usernames.txt"

# Main game logic
USER_INPUT="$1"
GAME_FILE="$2"
USERNAME="$USER_INPUT"

# Lookup sanitized username or create new one
SANITIZED_USER=$(handle_secret_username_flag "$USERNAME")

# Check if the sanitized username exists in the lookup file, otherwise create a new one
if [ ! -f "$USER_LOOKUP_FILE" ]; then
    touch "$USER_LOOKUP_FILE"
fi

# Ensure the username and its sanitized version are logged if new
if ! grep -q "^$USERNAME" "$USER_LOOKUP_FILE"; then
    # Add to the lookup file, starting with the base sanitized username (suffix in case of duplicates)
    suffix=$(printf "%X" $(($(wc -l < "$USER_LOOKUP_FILE") + 1))) # Generate hex suffix
    echo "$USERNAME $SANITIZED_USER$suffix" >> "$USER_LOOKUP_FILE"
fi

# Define the save directory based on the sanitized username
SAVE_DIR="$SAVES_DIR/$GAME_FILE/$SANITIZED_USER"
SAVE_FILE="$SAVE_DIR/${SANITIZED_USER}.sav"

# Ensure the save directory exists
mkdir -p "$SAVE_DIR"

# Check if the save file exists, if not, create it
if [ ! -f "$SAVE_FILE" ]; then
    echo "No save file found. Creating a new save file..." >> "$LOG_DIR/zcode-jzip.log"
    touch "$SAVE_FILE"
else
    echo "Found existing save file for $SANITIZED_USER." >> "$LOG_DIR/zcode-jzip.log"
fi

# Run the game with the jzip interpreter
echo "Starting game: $GAME_FILE" >> "$LOG_DIR/zcode-jzip.log"

/usr/games/jzip -l 20 -c 80 -m -s "$SAVE_DIR" "$GAMES_DIR/$GAME_FILE" 2>> "$LOG_DIR/zcode-jzip.log"

echo "Game session for $SANITIZED_USER ended." >> "$LOG_DIR/zcode-jzip.log"