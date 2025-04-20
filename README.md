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

Step 2: Download the Script

Clone or download the BBSZGameRunner script into a directory on your server:

cd /opt/mystic/doors/zcode/
git clone https://github.com/your-repo/BBSZGameRunner.git

Step 3: Configure BASE_DIR

The script uses the BASE_DIR variable to determine the root directory for game files, save directories, and logs. You will need to update this variable in the script to match your setup.

    Open the script file BBSZGameRunner.sh in a text editor.

    Find the line that defines BASE_DIR (it will look like this):

BASE_DIR="/opt/mystic/doors/zcode"

Change /opt/mystic/doors/zcode to the path where you have installed your games, saves, and log directories.

Example: If your ZCode files are located in /home/bbs/games/zcode, change it like so:

    BASE_DIR="/home/bbs/games/zcode"

    Save the script file.

Step 4: Set Permissions

Ensure the script is executable and that the correct permissions are set for the directories involved:

chmod +x BBSZGameRunner.sh

Step 5: Configure Game Directories and Saves

Ensure your directories for games and save files exist and have the correct permissions. The game files and save directories will be created automatically if they don't exist, but you can ensure they are set up as follows:

mkdir -p $BASE_DIR/games
mkdir -p $BASE_DIR/saves
chmod 755 $BASE_DIR/games
chmod 700 $BASE_DIR/saves

Step 6: Add Game Files

Add your ZCode game files (e.g., ZORK1.DAT) to the $BASE_DIR/games/ directory. The script will automatically detect these games when it runs.
Step 7: Configure Mystic BBS (Optional)

If you're using Mystic BBS, ensure that it is properly set up to execute the script when a user starts a game. You can add a door configuration in Mystic BBS to trigger this script.
Usage
Running the Script

To start a ZCode game, run the script from the command line with the following syntax:

./BBSZGameRunner.sh <username> <game_file>

    <username>: The player's username (can be an existing Mystic BBS user).

    <game_file>: The game file you want to run (e.g., ZORK1.DAT).

Example:

./BBSZGameRunner.sh jordanjm ZORK1.DAT

Debug Mode

If you want to enable debug logging to view all actions (including user sanitization and save directory creation), you can add the -debug flag:

./BBSZGameRunner.sh -debug jordanjm ZORK1.DAT

Special Username Flag

If you want to treat the username as an existing one, even if it doesn't exist in the username file, use the -sun flag:

./BBSZGameRunner.sh jordanjm-sun ZORK1.DAT

This will treat the username as an existing entry and avoid creating a new sanitized version.
Configuration
Sanitizing Usernames

Usernames are sanitized for file system safety and security. The script ensures usernames:

    Are alphanumeric or contain safe characters like underscores (_).

    Do not contain directory traversal characters like ../ or \0.

Save Files

The script automatically creates save directories for each game and each user. Save files are stored in the following directory:

$BASE_DIR/saves/<game_name>/<sanitized_username>/

    The username is sanitized and stored with an incrementing hexadecimal suffix if necessary.

    A checksum is calculated for each save file to ensure data integrity.

Checksum Validation

Each save file is validated with a SHA-256 checksum to ensure it hasn't been tampered with. If the checksum does not match when loading the game, the script will terminate and prompt the user to delete the corrupted save file.
License

This project is licensed under the GNU General Public License v3.0. See LICENSE for details.

Feel free to modify and use the script as needed. Contributions are welcome!
