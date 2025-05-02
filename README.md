# ----------------------------------------------------------------------------
# BBSZCodeRunner - Clean, frotz-based Z-Code game runner with save templates
# ----------------------------------------------------------------------------
    
# ZCode Runner Script
        
This is a bash script to run ZCode-based interactive fiction (IF) games with save file management and user sanitization. It supports logging and allows you to specify a sanitized username for each player. Additionally, the script can log game information and manage save files.

## Features

- Supports `frotz` and `dfrotz` interpreters
- Maintains a map of sanitized usernames
- Automatically creates save directories per user and game
- Cleans up older save files, keeping only the most recent
- Logs game runs with optional debug information
- Clean, user-friendly command-line interface
    
## Installation

1. Clone the repository or download the script to your server:

   ```bash
   git clone https://github.com/yourusername/zcode-runner.git
   cd zcode-runner
   ```

2. Run the setup script to create the necessary directory structure and permissions:

   ```bash
   sudo ./setup_zcode_env.sh
   ```

   This will:

   - Create the `games/`, `saves/`, and `bbszcoderunner.log` paths under `/opt/mystic/doors/zcode/`
   - Create a blank `usernames.map` file if it doesn’t exist
   - Set proper ownership and permissions (edit the script to match your user/group)

3. Make the main runner script executable:

   ```bash
   chmod +x bbszcoderunner.sh
   ```

4. Ensure `frotz` or `dfrotz` is installed on your system. 

Install on the following Distributions: Red Hat / Fedora / CentOS / AlmaLinux / Rocky

```bash
sudo dnf install frotz
```

Install on the following Distributions: Arch Linux / Manjaro

```bash
sudo pacman -S frotz
```

Install on Gentoo

```bash
sudo emerge --ask games-engines/frotz
```
*Note: dfrotz is often bundled with frotz, but availability may vary depending on your distro.*

Install from Source (GitHub)

If your distribution does not package dfrotz, or you want the latest version:

```bash
git clone https://github.com/DavidGriffith/frotz.git
cd frotz
make unix
sudo make install
```

This will build and install the latest version of frotz and dfrotz from source.

## Usage

```bash
./bbszcoderunner.sh [-d] [-b] [-h] [-v] <username> <game_file.z[1-8]>
```

### Arguments

- `<username>`: BBS username or session username
- `<game_file>`: Name of the Z-code file to run (e.g., `zork1.z3`)

### Options

- `-d` – Use `dfrotz` instead of `frotz`
- `-b` – Enable debug logging (adds detailed logs to the log file)
- `-h` – Display help message
- `-v` – Show script version

## Configuration

Paths are set via script variables:

```bash
FROTZ_CMD="/usr/bin/frotz"
DFROTZ_CMD="/usr/bin/dfrotz"
SAVE_BASE_DIR="/opt/mystic/doors/zcode/saves"
GAME_BASE_DIR="/opt/mystic/doors/zcode/games"
USERNAME_MAP="/opt/mystic/doors/zcode/usernames.map"
LOG_FILE="/opt/mystic/doors/zcode/bbszcoderunner.log"
```

Update these paths as needed for your environment.

## Logging

If the `-b` flag is set, detailed logs are written to the log file specified in `LOG_FILE`, including:

- Game start and end times
- Username and sanitized name
- Game file used
- Save file cleanup details

Otherwise, only critical errors are shown in terminal output.

## Example

```bash
./bbszcoderunner.sh -d -b alice zork1.z3
```

Runs `zork1.z3` using `dfrotz` for the user `alice`, with debug logging enabled.

## Version

`bbszcoderunner.sh` version 1.0.0

## Notes

- The script assumes that the game files and save directories are organized correctly. Adjust paths as needed for your setup.
- This script is currently designed for ZCode games and Frotz but can be adapted for other interpreters if needed.
- The `usernames.map` file is used to store sanitized usernames, ensuring that players reuse the same sanitized username across sessions.

## License
## License

This project is licensed under the **GNU GPL v3**.
