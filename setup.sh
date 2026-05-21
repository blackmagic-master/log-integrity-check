#!/bin/bash
if [ "$(whoami)" != "root" ]; then
    echo "error: this tool must be run as root."
    exit 1
fi
cp integrity-check.sh /usr/bin/integrity-check
chmod +x /usr/bin/integrity-check
echo "Integrity Check tool installed successfully."