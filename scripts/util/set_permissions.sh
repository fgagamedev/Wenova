#!/bin/bash
#
# Set all target_dir and its subdirs permissions to 755, and its files to 644
#

# Check the script parameters
if [ -z "$1" ];
then
    echo 'Usage:' $0 '{target_dir}'
    exit -1
fi

# Finding all dirs
dirs=`find $1 -type d`

# Set dirs permissions
for dir in $dirs;
do
    chmod 755 $dir
done;

# Finding all files
files=`find $1 -type f`

# Set dirs permissions
for file in $files;
do
    chmod 644 $file
done;
