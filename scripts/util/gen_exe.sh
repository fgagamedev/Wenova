#!/bin/bash
#
# Generates .exe installer for Windows
#

# Include project metadata
. metadata.ini

OUTPUT_FILE=$PACKAGE_NAME.exe

function gen_exe()
{
	mkdir -p .tmp
	cp -u src/$EXECUTABLE_NAME\_release .tmp/$EXECUTABLE_NAME.exe
	cp -u lib/SDL/windows/release/*.dll .tmp/
	cp -u lib/SDL_image/windows/release/*.dll .tmp/
	cp -u lib/SDL_image/windows/release/LICENSE* .tmp/
	cp -u dist/windows/$PACKAGE_NAME.wxs .tmp/
	cp -u dist/windows/Manual.pdf .tmp/
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
