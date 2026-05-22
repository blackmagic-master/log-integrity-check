#!/bin/bash

# Default configuration variables
store_in_def="/var/log"
hash_file_name_def="hashes.0"
hash_file_def="$store_in_def/.hashes"

hash_file_name="$hash_file_name_def"

# Passed arguments
ARGS=($1 $2 $3)

# Script path and version
script=$(realpath $0)
version="1.1"



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
                    if [ -f "$dir/.$hash_file_name" ]; then
                        echo "Hash file already exists: $dir/.$hash_file_name"
                        temp_store=$(cat $dir/.$hash_file_name)
                        find ${ARGS[1]} -type f | xargs sha256sum > $dir/.$hash_file_name 2> /dev/null
                        for i in $(echo $temp_store | awk '{print $2}'); do
                            if ! grep -q "$(echo $i | awk '{print $2}')" $dir/.$hash_file_name; then
                                echo $i >> $dir/.$hash_file_name
                            fi
                        done
                    else
                        touch "$dir/.$hash_file_name"
                        echo "Hash file created: $dir/.$hash_file_name"
                        find ${ARGS[1]} -type f | xargs sha256sum > $dir/.$hash_file_name 2> /dev/null
                    fi
                else
                    echo "error: could not determine directory from specified path: ${ARGS[1]}"
                    exit 1
                fi
        fi
    else
        echo "Using default log directory: $store_in_def"
        if [ -f "$hash_file_def" ]; then
            echo "Hash file already exists: $hash_file_def"
            temp_store=$(cat $hash_file_def)
            find $store_in_def -type f | xargs sha256sum > $hash_file_def 2> /dev/null
            for i in $(echo $temp_store | awk '{print $2}'); do
                if ! grep -q "$(echo $i | awk '{print $2}')" $hash_file_def; then
                    echo $i >> $hash_file_def
                fi
            done
        else
            touch "$hash_file_def"
            echo "Hash file created: $hash_file_def"
            find $store_in_def -type f | xargs sha256sum > $hash_file_def 2> /dev/null
        fi
    fi
}

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
                    if [ -f "$dir/.$hash_file_name" ]; then
                        echo "Hashes are stored in: $dir/.$hash_file_name"
                        files=$(cat $dir/.$hash_file_name | grep "${ARGS[1]}" | awk '{print $2}')
						for file in $files; do
							hash=$(cat $dir/.$hash_file_name | grep $file | awk '{print $1}')
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
                        echo "error: hash file does not exist: $dir/.$hash_file_name"
						exit 1
                    fi
                else
                    echo "error: could not determine directory from specified path: ${ARGS[1]}"
                    exit 1
                fi
        fi
	else
		echo "Hashes are stored in: $dir/.$hash_file_def"
		files=$(cat $hash_file_def | grep "$store_in_def" | awk '{print $2}')
		for file in $files; do
			hash=$(cat $dir/.$hash_file_def | grep $file | awk '{print $1}')
			current_hash=$(sha256sum $file | awk '{print $1}')
			if ! grep -q "$hash_file_def" $file; then
				if [ "$hash" != "$current_hash" ]; then
					echo "File integrity compromised: $file"
				else
					echo "File integrity verified: $file"
				fi
			fi
		done
    fi
}

config(){
    echo "config function called with argument: ${ARGS[1]}"
}

version(){
	echo "Integrity Check Tool"
	echo "Version: $version"
	echo "Author: BlackMagic Master - Szymon G."
	echo "Version date: 2026-05-21"
}

main(){
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
            echo "Usage: $0 {store|check|config} [options]"
            ;;
        "clean")
            echo "Clean function not implemented yet."
            ;;
        "version")
            version
            ;;
        *)
            echo "Invalid command: ${ARGS[0]}"
            echo "Usage: $0 {store|check|update|config} [options]"
            exit 1
            ;;
    esac
}

main