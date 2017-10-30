#!/bin/bash
#
# Retorns the current platform
#

platform=`uname -a`

if [[ "$platform" =~ "Linux" ]];
then
	if [[ "`sed '4q;d' /etc/os-release`" =~ "debian" ]]; then
		echo "debian";
	else
		echo "rhel"
	fi
elif [[ "$platform" =~ "Darwin" ]];
then
    echo "macos";
else
    echo "windows";
fi
