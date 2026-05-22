# Integrity Check Tool

A small shell-based log integrity utility for storing and verifying SHA-256 hashes of files. It supports storing hashes for a default log directory or a custom path, checking file integrity, cleaning stored hashes, and configuring default behavior.

## Features

- Store SHA-256 hashes for files in a directory or single file
- Verify file integrity against stored hashes
- Clean (remove) saved hash files
- Configure default log directory and hash file name
- Install/uninstall wrapper for `/usr/bin/integrity-check`

## Requirements

- Linux or Unix-like environment (including macOS)
- `bash`
- `sha256sum`
- Root privileges for install, uninstall, and running the tool

## Installation

1. Run the setup script as root:

```bash
sudo ./setup.sh
```

2. This installs the tool to `/usr/bin/integrity-check`.

## Usage

```bash
sudo integrity-check <command> [path or options]
```

### Commands

- `store [path]` - Store hashes for files in the specified path. If no path is provided, the default is `/var/log`.
- `check [path]` - Verify current file hashes against the saved hash file. Defaults to `/var/log` when no path is provided.
- `clean [path]` - Remove the stored hash file for the specified path or the default path.
- `config <option> <value>` - Change or display configuration.
- `version` - Show tool version information.
- `help` - Display help usage.

### Configuration options

- `log <path>` - Set the default log directory.
- `hash <filename>` - Set the hash file name.
- `default` - Reset `store_in` and `hash_file_name` to defaults.
- `show` - Display current and default configuration.

## Examples

Store hashes for `/var/log`:

```bash
sudo integrity-check store
```

Store hashes for a custom directory:

```bash
sudo integrity-check store /path/to/directory
```

Check integrity for the default log directory:

```bash
sudo integrity-check check
```

Check integrity for a specific directory or file:

```bash
sudo integrity-check check /path/to/directory
```

Clean saved hashes for the default directory:

```bash
sudo integrity-check clean
```

Set a custom log directory:

```bash
sudo integrity-check config log /path/to/logs
```

Show current configuration:

```bash
sudo integrity-check config show
```

## Uninstallation

Run the uninstall script as root:

```bash
sudo ./uninstall.sh
```

## Notes

- The tool currently stores hashes in a file named `.hashes.0` by default.
- The script expects root permissions for all commands.
- `store` and `check` rely on `sha256sum` to compute file hashes.

## Author

BlackMagic Master
Szymon G.