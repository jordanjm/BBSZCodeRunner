# ----------------------------------------------------------------------------
# BBSZCodeRunner - Clean, frotz-based Z-Code game runner with save templates
# ----------------------------------------------------------------------------

# ZCode Runner Script

This is a bash script to run ZCode-based interactive fiction (IF) games with save file management and user sanitization. It supports logging and allows you to specify a sanitized username for each player. Additionally, the script can log game information and manage save files.

## Features

- **Sanitized Usernames**: Automatically sanitizes user-provided usernames by replacing invalid characters with underscores.
- **Game File Execution**: Runs ZCode-based games (e.g., `zork1.z3`) using the Frotz interpreter.
- **Save File Management**: Deletes old save files while preserving the most recent save.
- **Logging**: Logs various game-related activities, including sanitized usernames, save file deletions, and game start/end times.
- **Debug Mode**: Option to enable detailed debug logs for troubleshooting.

## Requirements

- **Frotz**: A ZCode interpreter for running interactive fiction games. You can install it on most systems using your package manager.
- **Bash**: The script is designed for use on Linux-based systems with bash.
- **Directory Setup**: The script expects a specific directory structure for game files, save files, and username mappings.

## Installation

1. Clone the repository or download the script to your server.

   ```bash
   git clone https://github.com/yourusername/zcode-runner.git
   cd zcode-runner

    Ensure that the required directories exist and that Frotz is installed on your system.

        The script assumes the following directory structure:

            games/: Contains the .z3 or .z5 game files.

            saves/: Contains save files for the games.

            usernames.map: A file that maps unsanitized usernames to sanitized versions.

    Modify the script's directory paths if necessary to match your server's structure.

    Make the script executable:

    chmod +x bbszcoderunner.sh

Usage
Normal Mode (Minimal Logging)

To run the script in normal mode (only basic information logged):

./bbszcoderunner.sh <username> <gamefile>

Example:

./bbszcoderunner.sh user game.z3

Debug Mode (Verbose Logging)

To run the script in debug mode (with detailed logging):

./bbszcoderunner.sh <username> <gamefile> -b

Example:

./bbszcoderunner.sh user game.z3 -b

Arguments

    <username>: The username of the player. If the username contains invalid characters, it will be sanitized.

    <gamefile>: The name of the .z3 or .z5 game file to run.

    -b (optional): Enable detailed debug logging. Without this flag, only essential information (start/end times, sanitized username, and game file used) is logged.

Logging

    The script writes logs to the following file: log/zcode-frotz.log.

    Log entries include:

        Start and end times for each game run.

        Sanitized username used.

        Information about save file management (deleting old saves, retaining the most recent save).

        Debug logs when -b is enabled, including detailed information about username map management and any issues encountered.

Notes

    The script assumes that the game files and save directories are organized correctly. Adjust paths as needed for your setup.

    This script is currently designed for ZCode games and Frotz but can be adapted for other interpreters if needed.

    The usernames.map file is used to store sanitized usernames, ensuring that players reuse the same sanitized username across sessions.

License

GPL v3. See LICENSE for details.
Acknowledgments

    The ZCode format is developed by Infocom and used for interactive fiction games.

    Frotz is a popular ZCode interpreter available for various platforms.
