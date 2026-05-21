#!/bin/bash
if [ "$(whoami)" != "root" ]; then
    echo "error: this tool must be run as root."
    exit 1
fi
rm -f /usr/bin/integrity-check
echo "Integrity Check tool uninstalled successfully."
