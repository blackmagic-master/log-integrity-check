#!/bin/bash

# Default configuration variables
store_in_def="/var/log"
hash_file_name_def=".hashes.0"
hash_file_def="$store_in_def/$hash_file_name_def"

# Current configuration variables (can be overridden by passed arguments)
store_in="$store_in_def"
hash_file_name="$hash_file_name_def"
hash_file="$store_in/$hash_file_name"

# Passed arguments
ARGS=($1 $2 $3)

# Script path and version
script=$(realpath $0)
version="1.1"

root_check(){
	if [ "$EUID" -ne 0 ]; then
		echo "error: this script must be run as root"
		exit 1
	fi
}

# Function to check if a given path exists
existance_check(){
	if [ ! -e "$1" ]; then
		echo "error: given path does not exist: $1"
		exit 1
	fi
}

# Store hashes of files in the specified path (or default path if not specified)
store(){
    dir=""
    if [ ! -z "${ARGS[1]}" ]; then
        if [ ! -e "${ARGS[1]}" ]; then
            echo "error: specified path does not exist: ${ARGS[1]}"
            exit 1
            else
                if [ -d "${ARGS[1]}" ]; then
                    dir=$(echo "$(dirname "${ARGS[1]}")/$(basename "${ARGS[1]}")")
                elif [ -f "${ARGS[1]}" ]; then
                    dir=$(dirname "${ARGS[1]}")
                else
                    echo "error: specified path is not a file or directory: ${ARGS[1]}"
                    exit 1
                fi
                if [ ! -z "$dir" ]; then
                    if [ -f "$dir/$hash_file_name" ]; then
                        echo "Hash file already exists: $dir/$hash_file_name"
                        temp_store=$(cat $dir/$hash_file_name)
                        find ${ARGS[1]} -type f | xargs sha256sum > $dir/$hash_file_name 2> /dev/null
                        for i in $(echo $temp_store | awk '{print $2}'); do
                            if ! grep -q "$(echo $i | awk '{print $2}')" $dir/$hash_file_name; then
                                echo $i >> $dir/$hash_file_name
                            fi
                        done
                    else
                        touch "$dir/$hash_file_name"
                        echo "Hash file created: $dir/$hash_file_name"
                        find ${ARGS[1]} -type f | xargs sha256sum > $dir/$hash_file_name 2> /dev/null
                    fi
                else
                    echo "error: could not determine directory from specified path: ${ARGS[1]}"
                    exit 1
                fi
        fi
    else
        echo "Using default log directory: $store_in"
        if [ -f "$hash_file" ]; then
            echo "Hash file already exists: $hash_file"
            temp_store=$(cat $hash_file)
            find $store_in -type f | xargs sha256sum > $hash_file 2> /dev/null
            for i in $(echo $temp_store | awk '{print $2}'); do
                if ! grep -q "$(echo $i | awk '{print $2}')" $hash_file; then
                    echo $i >> $hash_file
                fi
            done
        else
            touch "$hash_file"
            echo "Hash file created: $hash_file"
            find $store_in -type f | xargs sha256sum > $hash_file 2> /dev/null
        fi
    fi
}

# Check integrity of files in the specified path (or default path if not specified)
check(){
	dir=""
    if [ ! -z "${ARGS[1]}" ]; then
        if [ ! -e "${ARGS[1]}" ]; then
            echo "error: specified path does not exist: ${ARGS[1]}"
            exit 1
            else
                if [ -d "${ARGS[1]}" ]; then
                    dir=$(echo "$(dirname "${ARGS[1]}")/$(basename "${ARGS[1]}")")
                elif [ -f "${ARGS[1]}" ]; then
                    dir=$(dirname "${ARGS[1]}")
                else
                    echo "error: specified path is not a file or directory: ${ARGS[1]}"
                    exit 1
                fi
                if [ ! -z "$dir" ]; then
                    if [ -f "$dir/$hash_file_name" ]; then
                        echo "Hashes are stored in: $dir/$hash_file_name"
                        files=$(cat $dir/$hash_file_name | grep "${ARGS[1]}" | awk '{print $2}')
						for file in $files; do
							hash=$(cat $dir/$hash_file_name | grep $file | awk '{print $1}')
							current_hash=$(sha256sum $file | awk '{print $1}')
							if ! grep -q "$hash_file_name" $file; then
								if [ "$hash" != "$current_hash" ]; then
									echo "File integrity compromised: $file"
								else
									echo "File integrity verified: $file"
								fi
							fi
						done
                    else
                        echo "error: hash file does not exist: $dir/$hash_file_name"
						exit 1
                    fi
                else
                    echo "error: could not determine directory from specified path: ${ARGS[1]}"
                    exit 1
                fi
        fi
	else
		if [ -f "$hash_file" ]; then
			echo "Hashes are stored in: $hash_file"
			files=$(cat $hash_file | grep "$store_in" | awk '{print $2}')
			for file in $files; do
				hash=$(cat $hash_file | grep $file | awk '{print $1}')
				current_hash=$(sha256sum $file | awk '{print $1}')
				if ! grep -q "$hash_file" $file 2> /dev/null; then
					if [ "$hash" != "$current_hash" ]; then
						echo "File integrity compromised: $file"
					else
						echo "File integrity verified: $file"
					fi
				fi
			done
		else
			echo "error: hash file does not exist: $hash_file"
			exit 1
		fi
    fi
}

# Clean stored hashes for the specified path (or default path if not specified)
clean(){
	if [ ! -z "${ARGS[1]}" ]; then
        if [ ! -e "${ARGS[1]}" ]; then
            echo "error: specified path does not exist: ${ARGS[1]}"
            exit 1
            else
                if [ -d "${ARGS[1]}" ]; then
                    dir=$(echo "$(dirname "${ARGS[1]}")/$(basename "${ARGS[1]}")")
                elif [ -f "${ARGS[1]}" ]; then
                    dir=$(dirname "${ARGS[1]}")
                else
                    echo "error: specified path is not a file or directory: ${ARGS[1]}"
                    exit 1
                fi
                if [ ! -z "$dir" ]; then
                    if [ -f "$dir/$hash_file_name" ]; then
                        echo "Hashes are stored in: $dir/$hash_file_name"
                        echo "Cleaning hashes..."
						rm -f $dir/$hash_file_name
						echo "Hashes cleaned: $dir/$hash_file_name"
                    else
                        echo "Nothing to do. Hash file does not exist: $dir/$hash_file_name"
						exit 1
                    fi
                else
                    echo "error: could not determine directory from specified path: ${ARGS[1]}"
                    exit 1
                fi
        fi
	else
		echo "Hashes are stored in: $hash_file"
		echo "Cleaning hashes..."
		rm -f $hash_file
		echo "Hashes cleaned: $hash_file"
    fi
}

# Configure settings (log directory, hash file name, reset to default, show configuration)
config(){
    case ${ARGS[1]} in
		"log")
			existance_check "${ARGS[2]}"
			sed -i'' "0,/store_in=.*/s|store_in=.*|store_in=\"${ARGS[2]}\"|" "$script"
			echo "Log directory set to: ${ARGS[2]}"
			;;
		"hash")
			sed -i'' "0,/hash_file_name=.*/s|hash_file_name=.*|hash_file_name=\"${ARGS[2]}\"|" "$script"
			echo "Hash file name set to: ${ARGS[2]}"
			;;
		"default")
			sed -i'' "0,/store_in=.*/s|store_in=.*|store_in=\"$store_in_def\"|" "$script"
			sed -i'' "0,/hash_file_name=.*/s|hash_file_name=.*|hash_file_name=\"$hash_file_name_def\"|" "$script"
			echo "Configuration reset to default values"
			;;
		"show")
			echo "##### configuration #######"
			echo "Default configuration:"
			echo "Log directory: $store_in_def"
			echo "Hash file name: $hash_file_name_def"
			echo "###########################"
			echo "Current configuration:"
			echo "Log directory: $store_in"
			echo "Hash file name: $hash_file_name"
			echo "###########################"
			;;
		*)
			echo "error: unknown configuration option: ${ARGS[1]}"
			echo "use 'help' command for usage information"
			exit 5
	esac
}

# Show version information
version(){
	echo "Integrity Check Tool"
	echo "Version: v.$version"
	echo "Author: BlackMagic Master - Szymon G."
	echo "Version date: 2026-05-22"
}

# Show usage information
help(){
	echo "Usage: $(basename $0) {store|check|clean|config|version|help} [options]"
	echo "Commands:"
	echo "  store [path]   - Store hashes of files in the specified path (default: $store_in_def)"
	echo "  check [path]   - Check integrity of files in the specified path (default: $store_in_def)"
	echo "  clean [path]   - Clean stored hashes for the specified path (default: $store_in_def)"
	echo "  config option value - Configure settings (options: log, hash, default, show)"
	echo "                   log - Set log directory"
	echo "                   hash - Set hash file name"
	echo "                   default - Reset configuration to default values"
	echo "                   show - Show current and default configuration"
	echo "  version        - Show version information"
	echo "  help           - Show this help message"
}

# Show error message for invalid command
error(){
			echo "Invalid command: ${ARGS[0]}"
            echo "Usage: $(basename $0) {store|check|update|config|version|help} [options]"
            exit 1
}

# Main function to parse command and execute corresponding function
main(){
	root_check
    case "${ARGS[0]}" in
        "store")
            store
            ;;
        "check")
            check
            ;;
        "config")
            config
            ;;
        "help")
            help
            ;;
        "clean")
            clean
            ;;
        "version")
            version
            ;;
        *)
            error
            ;;
    esac
}

# Running the tool
main