BBSZGameRunner

BBSZGameRunner is a script designed for running ZCode games on a Mystic BBS system. It handles user management, save files, and game execution, all while ensuring secure and organized operation. The script automates the process of saving/loading games, managing save directories, sanitizing usernames, and verifying data integrity with checksums.
Features

    Sanitizes Usernames: Ensures all usernames are safe for use in file systems.

    Checksum Validation: Verifies the integrity of saved games with SHA-256 checksums.

    File Locking: Prevents race conditions while accessing save files.

    Monochrome Mode: Automatically runs ZCode games in monochrome mode.

    Logging: Detailed logging of game sessions with support for debug mode.

    Automatic Save Management: Automatically creates save directories and files, ensuring no duplicates.

    Supports Multiple Games: Works with all ZCode games in a Mystic BBS environment.

Prerequisites

    Linux-based System (preferably a server running a BBS like Mystic BBS)

    Bash Shell (for script execution)

    Jzip (for running ZCode games)

    Optional: A configured Mystic BBS system for user management and game interaction.

Installation
Step 1: Install Jzip

If Jzip isn't installed on your system yet, you can install it from source. Download the latest release from Jzip's official page or use the following commands to install it on a Debian-based system:

sudo apt-get update
sudo apt-get install jzip

Step 2: Clone the Repository

To access the scripts, clone the repository from GitHub. Use the following command to clone the repository to your server:

git clone https://github.com/jordanjm/BBSZCodeRunner.git

Step 3: Configure BASE_DIR

The script uses the BASE_DIR variable to determine the root directory for game files, save directories, and logs. You will need to update this variable in the script to match your setup.

    Open the script file bbszgamerunner.sh in a text editor.

    Find the line that defines BASE_DIR (it will look like this):

BASE_DIR="/opt/mystic/doors/zcode"

Change /opt/mystic/doors/zcode to the path where you have installed your games, saves, and log directories.

Example: If your ZCode files are located in /home/bbs/games/zcode, change it like so:

    BASE_DIR="/home/bbs/games/zcode"

    Save the script file.

Step 4: Set Permissions

Ensure the script is executable and that the correct permissions are set for the directories involved:

chmod +x bbszgamerunner.sh
chmod +x bbszgameinstall.sh

Step 5: Configure Game Directories and Saves

Ensure your directories for games and save files exist and have the correct permissions. The game files and save directories will be created automatically if they don't exist, but you can ensure they are set up as follows:

mkdir -p $BASE_DIR/games
mkdir -p $BASE_DIR/saves
chmod 755 $BASE_DIR/games
chmod 700 $BASE_DIR/saves

Step 6: Run the Installation Script

To set up the necessary directories and permissions, run the installation script (bbszgameinstall.sh):

    Download or copy the following script as bbszgameinstall.sh into your zcode directory:

#!/bin/bash

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

    Make it executable:

chmod +x bbszgameinstall.sh

    Run the installation script:

./bbszgameinstall.sh

This will create the necessary directory structure, set proper permissions, and ensure everything is in place for running the ZCode games.
Step 7: Add Game Files

Add your ZCode game files (e.g., ZORK1.DAT) to the $BASE_DIR/games/ directory. The script will automatically detect these games when it runs.
Usage
Running the Script

To start a ZCode game, run the main script (bbszgamerunner.sh) from the command line with the following syntax:

./bbszgamerunner.sh <username> <game_file>

    <username>: The player's username (can be an existing Mystic BBS user).

    <game_file>: The game file you want to run (e.g., ZORK1.DAT).

Example:

./bbszgamerunner.sh jordanjm ZORK1.DAT

Debug Mode

If you want to enable debug logging to view all actions (including user sanitization and save directory creation), you can add the -debug flag:

./bbszgamerunner.sh -debug jordanjm ZORK1.DAT

Special Username Flag

If you want to treat the username as an existing one, even if it doesn't exist in the username file, use the -sun flag:

./bbszgamerunner.sh jordanjm-sun ZORK1.DAT

This will treat the username as an existing entry and avoid creating a new sanitized version.
License

This project is licensed under the GNU General Public License v3.0. See LICENSE for details.

Feel free to modify and use the script as needed. Contributions are welcome!

This README is now linked to your actual GitHub repository (https://github.com/jordanjm/BBSZCodeRunner). Let me know if there's anything else you want to add or modify!
