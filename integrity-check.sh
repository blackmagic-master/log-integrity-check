#!/bin/bash

def_log="/var/log"
hash_file="/var/hashes.0"


if [ $# == 0 ]; then
	echo "No arguments given"
else
	case $1 in
		"init")
			if [ -z $2 ]; then
				echo "Using default log directory: $def_log"
			else
				echo "Using specified log directory: $2"
				def_log=$2
			fi
			if [ -f $hash_file ]; then
				echo "Hash file already exists: $hash_file"
				echo "Do you want to overwrite it? (Y/n)"
				read answer
				if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
					echo "Operation cancelled."
					exit 1
				fi
				find $def_log -type f | xargs sha256sum > $hash_file
				echo "Hash file created: $hash_file"
			fi
			;;
		"check")
			files=$(cat $hash_file | grep "$2" | awk '{print $2}')
			for file in $files; do
				hash=$(cat $hash_file | grep $file | awk '{print $1}')
				current_hash=$(sha256sum $file | awk '{print $1}')
				if [ "$hash" != "$current_hash" ]; then
					echo "File integrity compromised: $file"
				else
					echo "File integrity verified: $file"
				fi
			done
			;;
		"update")
			echo "update"
			temp_file=$(cat $hash_file)
			cat /dev/null > $hash_file
			for line in $temp_file; do
				if ! grep -q "$line | awk '{print $2}'" $hash_file; then
					echo "$line" >> $hash_file
				fi
			done
			;;
		*)
			echo "Unknown command: $1"
	esac
fi