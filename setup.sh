#!/bin/bash
# Check if the script is run as root and install the integrity-check tool
if [ "$(whoami)" != "root" ]; then
    echo "error: this tool must be run as root."
    exit 1
fi
cp integrity-check.sh /usr/bin/integrity-check
chmod +x /usr/bin/integrity-check
echo "Integrity Check tool installed successfully."