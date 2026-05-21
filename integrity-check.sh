#!/bin/bash

def_log="/var/log"
hash_file="/var/hashes.0"
ARGS=($1 $2 $3)
version="alpha"

init(){
	if [ -z $1 ]; then
		echo "Using default log directory: $def_log"
	else
		echo "Using specified log directory: $1"
		def_log=$1
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
}

check(){
	files=$(cat $hash_file | grep "$1" | awk '{print $2}')
	for file in $files; do
		hash=$(cat $hash_file | grep $file | awk '{print $1}')
		current_hash=$(sha256sum $file | awk '{print $1}')
		if [ "$hash" != "$current_hash" ]; then
			echo "File integrity compromised: $file"
		else
			echo "File integrity verified: $file"
		fi
	done
}

update(){
	echo "update"
	temp_file=$(cat $hash_file)
	cat /dev/null > $hash_file
	for line in $temp_file; do
		if ! grep -q "$line | awk '{print $2}'" $hash_file; then
			echo "$line" >> $hash_file
		fi
	done
}

help(){
	echo "Log integrity check tool v.$version"
	echo "usage: integrity-check [command] file [argument]"
	echo "note:  this tool requires superuser privileges"
	echo "commands:"
	echo "  init [log_directory] - initialize the hash file with the specified log directory (default: /var/log)"
	echo "  check file - check the integrity of the specified file"
	echo "  update - update the hash file with any new files in the log directory"
	echo "  help - display this help message"
}

error(){
	echo "error: unknown command: $1"
	echo "use 'help' command for usage information"
	exit 2
}

main(){
	if [ -z $ARGS ]; then
		echo "No arguments given"
		echo "use 'help' command for usage information"
		exit 1
	else
		case ${ARGS[0]} in
			"init")
				init ${ARGS[1]}
				;;
			"check")
				check ${ARGS[1]}
				;;
			"update")
				update
				;;
			"help")
				help
				;;
			*)
				error ${ARGS[0]}
		esac
	fi
}

main