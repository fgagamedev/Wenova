#!/bin/bash
#
# Identify the platform and run the matching Makefile
#

mode=$1
. metadata.ini

function build()
{
    platform=`uname -a`

    if [[ "$platform" =~ "Linux" ]];
    then
        platform="linux";
    elif [[ "$platform" =~ "Darwin" ]];
	then
    	platform="macos";
    else
        platform="windows";
    fi

    make -f Makefile.$platform MODE=$mode EXECUTABLE_NAME=$EXECUTABLE_NAME
}

# Main
case $mode in
    "release")
        echo "Building the release version..."
        build
        ;;

    *)
        echo "Use: 'build.sh release' to run the release version"
        echo "Building the debug version..."
        mode='debug'
        build
        exit 1
esac
