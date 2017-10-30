#!/bin/bash
#
# Generates .deb package for Linux
#

# Include project metadata
. metadata.ini

PACKAGE_NAME=$EXECUTABLE_NAME
PACKAGE_VERSION=$VERSION_MAJOR.$VERSION_MINOR-$VERSION_RELEASE
OUTPUT_FILE=$PACKAGE_NAME\_$PACKAGE_VERSION.deb

function gen_deb()
{
    # Build dir
    tmp_dir=/tmp/$PACKAGE_NAME\_$PACKAGE_VERSION
    rm -rf $tmp_dir
    mkdir -p $tmp_dir

    # Data dir: resources, scripts and executable
    var_dir=$tmp_dir/var
    data_dir=$var_dir/games
    install_dir=$data_dir/$PACKAGE_NAME
    mkdir -p $install_dir

    cp src/$EXECUTABLE_NAME\_release $install_dir/$EXECUTABLE_NAME

    lib_dir=$install_dir/lib
    mkdir -p $lib_dir

    for extlib in `ls lib`;
    do
        cp -P lib/$extlib/linux/release/* $lib_dir;
    done

    # Removing embedded libraries
    rm $lib_dir/libjpeg*
    rm $lib_dir/libpng*

    resources_dir=$install_dir/resources
    mkdir -p $resources_dir

    cp -r resources/* $resources_dir/

    # Launcher script dir
    usr_dir=$tmp_dir/usr
    exec_dir=$usr_dir/games
    mkdir -p $exec_dir

    printf "#!/bin/bash\nexport LD_LIBRARY_PATH=/var/games/$PACKAGE_NAME/lib && cd /var/games/$PACKAGE_NAME/ && ./$EXECUTABLE_NAME" > $exec_dir/$EXECUTABLE_NAME

    # Debian package info dir
    mkdir -p $tmp_dir/DEBIAN
    cp dist/linux/debian/control $tmp_dir/DEBIAN/
    sed -i -- 's/%%PACKAGE_NAME%%/'"$PACKAGE_NAME"'/' $tmp_dir/DEBIAN/control
    sed -i -- 's/%%PACKAGE_VERSION%%/'"$PACKAGE_VERSION"'/' $tmp_dir/DEBIAN/control
    sed -i -- 's/%%MAINTAINER_NAME%%/'"$MAINTAINER_NAME"'/' $tmp_dir/DEBIAN/control
    sed -i -- 's/%%MAINTAINER_CONTACT%%/'"$MAINTAINER_CONTACT"'/' $tmp_dir/DEBIAN/control
    sed -i -- 's/%%GAME_DESCRIPTION%%/'"$GAME_DESCRIPTION"'/' $tmp_dir/DEBIAN/control

    # Documentation
    share_dir=$tmp_dir/usr/share
    doc_dir=$tmp_dir/usr/share/doc/$PACKAGE_NAME
    mkdir -p $doc_dir

    cp changelog $doc_dir/changelog.Debian
    cp LICENSE $doc_dir/copyright
    gzip -n9 $doc_dir/changelog.Debian

    man_dir=$share_dir/man
    section_dir=$man_dir/man6
    mkdir -p $section_dir

    cp dist/linux/debian/template-test.6 $section_dir/$PACKAGE_NAME.6
    gzip -n9 $section_dir/$PACKAGE_NAME.6

    # Set the permissions
    scripts/util/set_permissions.sh $tmp_dir
    chmod 755 $exec_dir/$EXECUTABLE_NAME
    chmod 755 $install_dir/$EXECUTABLE_NAME

    # Strip executable debug symbols
    strip $install_dir/$EXECUTABLE_NAME

    # Build and check the package
    fakeroot dpkg-deb --build $tmp_dir
    mv /tmp/$OUTPUT_FILE .
    lintian $OUTPUT_FILE
}

echo "Generating "$OUTPUT_FILE "..."
gen_deb
echo "Done"
