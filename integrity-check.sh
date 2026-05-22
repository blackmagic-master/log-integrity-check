#!/bin/bash

# Default configuration variables
def_log_init="/var/log"
hash_file_init="$def_log_init/.hashes"

# Current configuration variables (can be modified by config command)
def_log=$def_log_init
hash_file="$def_log/.hashes"

# Passed arguments
ARGS=($1 $2 $3)

# Script path and version
script=$(realpath $0)
version="1.1"

# Check if the specified path exists
existance_check(){
	if [ ! -e "$1" ]; then
		echo "error: specified path does not exist: $1"
		exit 10
	fi
}

# Error handling for unknown commands
error(){
	echo "error: unknown command: $1"
	echo "use 'help' command for usage information"
	exit 3
}

# Check if the script is run as root
root_check(){
	if [ "$(whoami)" != "root" ]; then
		echo "error: this tool must be run as root."
		exit 1
	fi
}

# Initialize the hash file with the specified log directory (or default if not provided)
init(){
	if [ ! -z $2 && $2 != "-y" ]; then
		error $2
	else
		if [ -z $1 ]; then
			echo "Using default log directory: $def_log"
		else
			existanse_check $1
			echo "Using specified log directory: $1"
			def_log=$1
		fi
		if [ -f $hash_file ]; then
			echo "Hash file already exists: $hash_file"
			if [ $2 != "-y" ]; then
				echo "Do you want to overwrite it? (Y/n)"
				read answer
				if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
					echo "Operation cancelled."
					exit 2
				fi
			fi
			find $def_log -type f | xargs sha256sum > $hash_file
			echo "Hash file created: $hash_file"
		else
			find $def_log -type f | xargs sha256sum > $hash_file
			echo "Hash file created: $hash_file"
		fi
	fi
}

# Check the integrity of the specified file against the hash file
check(){
	if [ ! -z $1 ]; then
		existanse_check $1
	fi
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

# Update the hash file with any new files in the log directory (or default if not provided)
update(){
	if [ -z $1 ]; then
		echo "Using default log directory: $def_log"
		log_dir=$def_log
		new_hashes=$(find $log_dir -type f | xargs sha256sum)
		temp_file=$(cat $hash_file)
		cat /dev/null > $hash_file
		for line in $temp_file; do
			if ! grep -q "$line | awk '{print $2}'" $hash_file; then
				echo "$line" >> $hash_file
			fi
		done
	else
		existanse_check $1
		log_dir=$1
	fi
}

# Display help message with usage information
help(){
	echo "Log integrity check tool v.$version"
	echo "usage: integrity-check [command] file [argument]"
	echo "note:  this tool requires superuser privileges"
	echo "commands:"
	echo "  init [log_directory] [-y] - initialize the hash file with the specified log directory (default: /var/log)"
	echo "		-y - skip confirmation prompt when overwriting existing hash file"
	echo "		to use -y option, the log_directory argument must be provided (can be default)"
	echo "  check file - check the integrity of the specified file"
	echo "  update - update the hash file with any new files in the log directory"
	echo "  help - display this help message"
	echo "  config [option] [value] - configure the tool (options: log, hash, default, show)"
	echo "   	 log [log_directory] - set the log directory (default: /var/log)"
	echo "   	 hash [hash_file] - set the hash file (default: /var/hashes.0)"
	echo "   	 default - reset to default configuration"
	echo "   	 show - display current and default configuration"
}

# Configure the tool with the specified option and value
config(){
	case $1 in
		"log")
			sed -i'' "0,/def_log=.*/s|def_log=.*|def_log=\"$2\"|" "$script"
			echo "Log directory set to: $2"
			;;
		"hash")
			sed -i'' "0,/hash_file=.*/s|hash_file=.*|hash_file=\"$2\"|" "$script"
			echo "Hash file set to: $2"
			;;
		"default")
			sed -i'' "0,/def_log=.*/s|def_log=.*|def_log=$def_log_init|" "$script"
			sed -i'' "0,/hash_file=.*/s|hash_file=.*|hash_file=$hash_file_init|" "$script"
			echo "Configuration reset to default values"
			;;
		"show")
			echo "##### configuration #######"
			echo "Default configuration:"
			echo "Log directory: $def_log_init"
			echo "Hash file: $hash_file_init"
			echo "###########################"
			echo "Current configuration:"
			echo "Log directory: $def_log"
			echo "Hash file: $hash_file"
			echo "###########################"
			;;
		*)
			echo "error: unknown configuration option: $1"
			echo "use 'help' command for usage information"
			exit 5
	esac
}

# Check if any arguments were provided
args_check(){
	if [ -z $ARGS ]; then
		echo "No arguments given"
		echo "use 'help' command for usage information"
		exit 4
	fi
}

# Main function
main(){
	root_check
	args_check
	case ${ARGS[0]} in
		"init")
			init ${ARGS[1]} ${ARGS[2]}
			;;
		"check")
			check ${ARGS[1]}
			;;
		"update")
			update ${ARGS[1]}
			;;
		"help")
			help
			;;
		"config")
			config ${ARGS[1]} ${ARGS[2]}
			;;
		*)
			error ${ARGS[0]}
	esac
}

# Running the script
main