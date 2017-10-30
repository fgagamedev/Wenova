#!/bin/bash
#
# Generates .deb package for Linux
#

# Include project metadata
. metadata.ini

PACKAGE_NAME=$EXECUTABLE_NAME
PACKAGE_VERSION=$VERSION_MAJOR.$VERSION_MINOR-$VERSION_RELEASE
OUTPUT_FILE=$PACKAGE_NAME\_$PACKAGE_VERSION.rpm

function gen_rpm()
{
    work_dir=`pwd`

    # RPM build dir setup
    rpmdev-setuptree

    # Preparing the spec file
    spec_file=$PACKAGE_NAME.spec
    cp dist/linux/redhat/template-test.spec ~/rpmbuild/SPECS/$spec_file
    cp dist/linux/debian/template-test.6 dist/linux/debian/$PACKAGE_NAME.6

    sed -i -- 's/%%PACKAGE_NAME%%/'$PACKAGE_NAME'/g' ~/rpmbuild/SPECS/$spec_file
    sed -i -- 's/%%VERSION_MAJOR%%/'$VERSION_MAJOR'/g' ~/rpmbuild/SPECS/$spec_file
    sed -i -- 's/%%VERSION_MINOR%%/'$VERSION_MINOR'/g' ~/rpmbuild/SPECS/$spec_file
    sed -i -- 's/%%VERSION_RELEASE%%/'$VERSION_RELEASE'/g' ~/rpmbuild/SPECS/$spec_file
    sed -i -- 's/%%GAME_DESCRIPTION%%/'"$GAME_DESCRIPTION"'/g' ~/rpmbuild/SPECS/$spec_file

    # Launcher script dir
    printf "#!/bin/bash\nexport LD_LIBRARY_PATH=/var/games/$PACKAGE_NAME/lib && cd /var/games/$PACKAGE_NAME/ && ./$EXECUTABLE_NAME\n" > dist/linux/redhat/$EXECUTABLE_NAME

    # Preparing the source package
    rm -rf /tmp/$PACKAGE_NAME-$VERSION_MAJOR.$VERSION_MINOR
    mkdir -p /tmp/$PACKAGE_NAME-$VERSION_MAJOR.$VERSION_MINOR
    cp -r * /tmp/$PACKAGE_NAME-$VERSION_MAJOR.$VERSION_MINOR/
    cd /tmp && tar -czpf ${PACKAGE_NAME}.tar.gz $PACKAGE_NAME-$VERSION_MAJOR.$VERSION_MINOR/
    cp /tmp/${PACKAGE_NAME}.tar.gz ~/rpmbuild/SOURCES/

    # Build and check the package
    cd ~/rpmbuild/SPECS && rpmbuild -ba $spec_file
    cp ~/rpmbuild/RPMS/x86_64/* $work_dir
    cd $work_dir && rpmlint $PACKAGE_NAME-$VERSION_MAJOR.*
}

echo "Generating "$OUTPUT_FILE "..."
gen_rpm
echo "Done"
