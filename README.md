# BBSZGameRunner

BBSZGameRunner is a script designed for running ZCode games on a Mystic BBS system. It handles user management, save files, and game execution, all while ensuring secure and organized operation. The script automates the process of saving/loading games, managing save directories, sanitizing usernames, and verifying data integrity with checksums.
Features

    Sanitizes Usernames: Ensures all usernames are safe for use in file systems.

    Checksum Validation: Verifies the integrity of saved games with SHA-256 checksums.

    File Locking: Prevents race conditions while accessing save files.

    Monochrome Mode: Automatically runs ZCode games in monochrome mode.

    Logging: Detailed logging of game sessions with support for debug mode.

    Automatic Save Management: Automatically creates save directories and files, ensuring no duplicates.

    Supports Multiple Games: Works with all ZCode games in a Mystic BBS environment.

## Prerequisites

    Linux-based System (preferably a server running a BBS like Mystic BBS)

    Bash Shell (for script execution)

    Jzip (for running ZCode games)

    Optional: A configured Mystic BBS system for user management and game interaction.

## Installation

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

To set up the necessary directories and permissions, run the installation script (bbszgameinstall.sh)

./bbszgameinstall.sh  --Script is included in the repository--

This will create the necessary directory structure, set proper permissions, and ensure everything is in place for running the ZCode games.
Step 7: Add Game Files

Add your ZCode game files (e.g., ZORK1.DAT) to the $BASE_DIR/games/ directory. The script will automatically detect these games when it runs.
Usage

## Running the Script

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

## Calling the Script from Mystic BBS

To integrate BBSZGameRunner with Mystic BBS, you can set it up to be called from within your BBS as a part of your game's setup. This can be done by adding the script to your BBS's game menu or using Mystic BBS's external programs feature to execute the script.
Step 1: Create an External Program in Mystic BBS

    Edit the external_programs configuration in your Mystic BBS setup:

        Open the Mystic BBS config file for external programs (usually located in /usr/local/mystic/config/external_programs.cfg or the appropriate path based on your installation).

        Add a new entry to the file, which will link to the bbszgamerunner.sh script.

Example entry in external_programs.cfg:

[ZCode Game Runner]
command="/path/to/bbszgamerunner.sh %1 %2"
description="Run a ZCode game"

Step 2: Create a Menu Option in Mystic BBS

You can create a menu option that calls the BBSZGameRunner script directly:

    Edit the BBS's main menu configuration (typically located in /usr/local/mystic/config/menu.cfg or in your BBS's setup area).

    Add a new menu option to allow users to select the game they want to play.

Example menu option in menu.cfg:

[ZCode Game Runner]
  "Play ZCode Game"   - External Program

When the user selects this option, it will call the bbszgamerunner.sh script to run the game.
Step 3: Passing Parameters

Mystic BBS allows you to pass user data and game names as parameters to external programs. You can customize the external program command in the external_programs.cfg file to receive the correct parameters (username and game file) as shown in the example above.

The %1 and %2 represent the username and game file, respectively. Mystic will automatically replace these placeholders with the appropriate data when the user runs the external program.

This should allow Mystic BBS users to easily run the BBSZGameRunner script directly from the BBS interface. Let me know if you'd like further details or modifications!

## License

This project is licensed under the GNU General Public License v3.0. See LICENSE for details.

Feel free to modify and use the script as needed. Contributions are welcome!

This README is now linked to your actual GitHub repository (https://github.com/jordanjm/BBSZCodeRunner). Let me know if there's anything else you want to add or modify!
