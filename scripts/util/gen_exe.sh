#!/bin/bash
#
# Generates .exe installer for Windows
#

# Include project metadata
. metadata.ini

WXS_PATH="dist/windows/$PACKAGE_NAME.wxs"
OUTPUT_FILE=$EXECUTABLE_NAME.exe
PACKAGE_VERSION=$VERSION_MAJOR.$VERSION_MINOR.$VERSION_RELEASE

function gen_exe() {
	rm -rf bin/windows
	mkdir -p bin/windows

	for DIR in $(ls -D lib);
	do
		cp -P lib/$DIR/windows/release/* bin/windows
	done;

	if ! [ -e $WXS_PATH ];
	then
		scripts/util/gen_wxs.sh
	fi

	mkdir -p .tmp
	cp -u src/$EXECUTABLE_NAME\_release .tmp/$OUTPUT_FILE

	cp -u bin/windows/* .tmp/
	cp -f $WXS_PATH .tmp/$PACKAGE_NAME.wxs

	# cp -u dist/windows/Manual.pdf .tmp/
	cp -ur resources .tmp/

	cd .tmp

	candle.exe $PACKAGE_NAME.wxs
	light.exe -sice:ICE60 -ext WixUIExtension $PACKAGE_NAME.wixobj
	cp $PACKAGE_NAME.msi ..
	cd ..
}

echo "Generating "$OUTPUT_FILE "..."
gen_exe
echo "Done"
