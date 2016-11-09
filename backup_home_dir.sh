#!/bin/bash

# This script will compress your $HOME directory into a .tar.gz file and save
# it to $HOME/backups/. Most options can be easily changed via variable. For
# instance, to change your default backup directory simply modify the
# $destination variable to your preferred backup directory.
#
# The script also has built-in directory exclusion support via an optional 
# file called "exclude_dir.txt". If you do not want to take advantage of
# directory exclusion in tar then simply delete the "exclude_dir.txt" file.
# It is recommended to at least exclude your backup directory, if it resides in
# your home directory.
#
# Otherwise you can add directories to exclude to "exclude_dir.txt" in the
# following format:
# 
# backups
# Pictures
# Downloads/etc
#
# The script will assume the $HOME directory when excluding and set up the 
# directories appropriately. When adding to "exclude_dir.txt" omit the home 
# directory.

# points to exclude_dir.text, for excluding directories
exclude_file="exclude_dir.txt"

# constructs command for backing up $HOME to a compressed .tar.gz archive
Backup() {

    # grab hostname for file
    pc=$(hostname)

    # grab os name
    os=$(cat /etc/*-release | grep 'PRETTY_NAME' | sed -e 's/^.*=//g;s/"//g;s/\(.*\)/\L\1/' | awk '{ print $1 }')

    # machine type
    machine="laptop"

    # backup destination
    destination="$HOME/backups"

    # current date
    day=$(date +%m%d%y)

    # current time
    military_time=$(date +%R | sed 's/://g')

    # options for tar
    # create archive, use gzip, preserve permissions, output file
    options="-czpf"

    # create backup file and destination for tar
    backup_file="$destination/$pc-$os-$machine-$day-$military_time.tar.gz"

    # check if exclude_dir.txt exists; if it doesn't ignore
    if [[ -e $exclude_file ]]; then

        # read lines from $exclude_file
        while read -r line; do
            # ignore empty lines
            if [[ -n $line ]]; then
                # add each line to exclude_dirs
                exclude_dirs="${exclude_dirs}--exclude=${HOME}/${line} "  

            fi

        done < $exclude_file
    
    # set exclude_dirs to empty string
    else
        exclude_dirs=""

    fi
    
    # check if exclude_dirs is an empty string
    if [[ -z $exclude_dirs ]]; then
        # run tar w/o exclude_dirs
        tar $options $backup_file $HOME &>/dev/null

    else
        # run tar w/ exclude_dirs
        tar $exclude_dirs $options $backup_file $HOME &>/dev/null
    
    fi

}

##################################
###        SCRIPT START        ###
##################################

# run backup
Backup

