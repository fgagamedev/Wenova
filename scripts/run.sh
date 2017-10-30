#!/bin/bash
#
# Identify the platform and run the matching Makefile
#

mode=$1
. metadata.ini

game=$EXECUTABLE_NAME

function run_windows()
{
	rm -rf bin/windows
    mkdir -p bin/windows
    ln -f src/$EXECUTABLE_NAME\_$mode bin/windows

    dirs=`ls -d lib/*/`

    for dir in $dirs;
    do
        cp -P $dir"windows/"$mode/* bin/windows
    done;

    bin/windows/$EXECUTABLE_NAME\_$mode
}

function run_linux()
{
    rm -rf bin/linux
    mkdir -p bin/linux
    cp src/$EXECUTABLE_NAME\_$mode bin/linux

    dirs=`ls -d lib/*/`

    for dir in $dirs;
    do
        cp -P $dir"linux/"$mode/* bin/linux/
    done;

    LD_LIBRARY_PATH=bin/linux bin/linux/$EXECUTABLE_NAME\_$mode
}

function run_macos()
{
	rm -rf bin/macos

	mkdir -p bin/macos/MacOS
	ln -f src/$game\_$mode bin/macos/MacOS/

	mkdir -p bin/macos/Frameworks

	dirs=`ls -d lib/*/`

	for dir in $dirs;
    do
        cp -r $dir"macos/"$mode/* bin/macos/Frameworks/
    done;

    ln -s $(PWD)/resources bin/macos/Resources
	bin/macos/MacOS/$game\_$mode
}

function run()
{
    platform=`uname -a`

    if [[ "$platform" =~ "Linux" ]];
    then
        run_linux
    elif [[ "$platform" =~ "Darwin" ]];
	then
    	run_macos
    else
        run_windows
    fi
}

# Main
case $mode in
    "release")
        echo "Running the release version..."
        run
        ;;

    *)
        echo "Running the debug version. Use 'run.sh release' to run the release version"
        mode='debug'
        run
esac
