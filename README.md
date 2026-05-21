# Log Integrity Check Tool

A simple Bash-based tool for hashing log files and verifying their integrity.

## Overview

This tool scans a log directory, stores SHA256 hashes for each file, and lets you verify whether files have been modified since the last snapshot.

## Install

The tool must be installed and run as `root`.

1. Open a terminal in the repository root.
2. Run:

```bash
sudo ./setup.sh
```

This copies `integrity-check.sh` to `/usr/bin/integrity-check` and makes it executable.

## Remove

To uninstall the tool, run:

```bash
sudo ./uninstall.sh
```

This removes `/usr/bin/integrity-check`.

## Usage

The command is installed as `integrity-check`.

```bash
sudo integrity-check [command] [argument]
```

### Commands

- `init [log_directory]`
  - Creates or overwrites the hash file with SHA256 hashes for all files in the log directory.
  - Default log directory: `/var/log`
  - Default hash file: `/var/hashes.0`

- `check file`
  - Verifies the integrity of the specified file using the hash stored in the hash file.

- `update`
  - Updates the hash file with any new files in the log directory.

- `config [option] [value]`
  - Configure the tool permanently by updating the script itself.
  - Options:
    - `log [log_directory]` — set the default log directory.
    - `hash [hash_file]` — set the hash file location.
    - `default` — reset the configuration to defaults.
    - `show` — display current and default configuration values.

- `help`
  - Displays usage information.

## Examples

Initialize hashing for `/var/log`:

```bash
sudo integrity-check init
```

Initialize hashing for a custom directory:

```bash
sudo integrity-check init /tmp/logs
```

Check a file's integrity:

```bash
sudo integrity-check check /var/log/syslog
```

Update the hash file with new log files:

```bash
sudo integrity-check update
```

Show current configuration:

```bash
sudo integrity-check config show
```

Reset configuration to defaults:

```bash
sudo integrity-check config default
```

## Notes

- This tool requires superuser privileges for installation and for reading log files in protected directories.
- The implementation stores the default hash file at `/var/hashes.0`.

## Author

BlackMagic Master
Szymon G.