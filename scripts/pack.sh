#!/bin/bash
#
# Identify the platform and run the matching Makefile
#

# Main
platform=`scripts/util/get_platform.sh`

# Run build release to check if there's a release version of the game.
scripts/build.sh release

case $platform in
    "debian")
        scripts/util/gen_deb.sh
        ;;

    "rhel")
        scripts/util/gen_rpm.sh
        ;;

    "windows")
        scripts/util/gen_exe.sh
        ;;

    "macos")
        scripts/util/gen_dmg.sh
        ;;

    *)
        echo "Invalid platform! ("$platform")"
        exit 1
esac
