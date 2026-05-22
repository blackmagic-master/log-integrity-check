#!/bin/bash
# Check if the script is run as root and uninstall the integrity-check tool
if [ "$(whoami)" != "root" ]; then
    echo "error: this tool must be run as root."
    exit 1
fi
rm -f /usr/bin/integrity-check
echo "Integrity Check tool uninstalled successfully."
