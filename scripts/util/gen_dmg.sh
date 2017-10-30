#!/bin/bash
#
# Generates .dmg package for MacOS
#

# Include project metadata
. metadata.ini

PACKAGE_NAME=$EXECUTABLE_NAME
OUTPUT_FILE=$PACKAGE_NAME.dmg
VERSION=$VERSION_MAJOR.$VERSION_MINOR.$VERSION_RELEASE

function gen_dmg()
{
	base_dir=.dmg/"$PACKAGE_NAME".app/Contents
    macos_dir=$base_dir/MacOS
	mkdir -p $macos_dir
	cp -f src/$EXECUTABLE_NAME\_release $macos_dir/$EXECUTABLE_NAME
	install_name_tool -add_rpath @loader_path/../Frameworks $macos_dir/$EXECUTABLE_NAME
	
    cp -f dist/macos/Info.plist $base_dir
	sed -i -- 's/%%PACKAGE_NAME%%/'$PACKAGE_NAME'/' $base_dir/Info.plist
	sed -i -- 's/%%DEVELOPER%%/'"$DEVELOPER"'/' $base_dir/Info.plist
	sed -i -- 's/%%VERSION%%/'"$VERSION"'/' $base_dir/Info.plist
	sed -i -- 's/%%EXECUTABLE_NAME%%/'"$EXECUTABLE_NAME"'/' $base_dir/Info.plist
	
    lib_dir=$base_dir/Frameworks
	mkdir -p $lib_dir

    for extlib in `ls lib`;
    do
        cp -rf lib/$extlib/macos/release/* $lib_dir/;
    done
	
	cp -r resources $base_dir/
    
    # Build the .dmg
	cd .dmg
	rm -f $OUTPUT_FILE
	create_dmg --volname "$GAME_TITLE Installer" --window-pos 200 120 --window-size 800 400 --app-drop-link 600 185 $OUTPUT_FILE .
	cp *.dmg ..
	cd ..
}

echo "Generating "$OUTPUT_FILE "..."
gen_dmg
echo "Done"
