#!/bin/bash
#
# Generates .exe installer for Windows
#

. metadata.ini

WXS_PATH="dist/windows/$PACKAGE_NAME.wxs"
OUTPUT_FILE=$EXECUTABLE_NAME.exe
PACKAGE_VERSION=$VERSION_MAJOR.$VERSION_MINOR.$VERSION_RELEASE


function get_uuid(){
	UUID=`uuidgen`
	UUID=${UUID^^}
	echo $UUID
}

function clean_id(){
	ID=${1//\//_} # Replace backslash with underscore
	ID=${ID//-/_} # Replace minus with underscore
	ID=${ID//+/_} # Replace plus with underscore
	echo _$ID
}

COMPONENT_IDS="MainExecutable "

function create_directory_file() {
	cat >> $WXS_PATH <<EOF
		<Directory Id='TARGETDIR' Name='SourceDir'>
			<Directory Id='ProgramFilesFolder' Name='PFiles'>
				<Directory Id='UnBGames' Name='UnB Games'>
					<Directory Id='INSTALLDIR' Name="$PACKAGE_NAME $PACKAGE_VERSION">
						<Component Id='MainExecutable' Guid="`get_uuid`">
							<File
								Id="$PACKAGE_NAME"
								Name="$OUTPUT_FILE"
								DiskId='1'
								Vital='yes'
								Source="$OUTPUT_FILE"
								KeyPath='yes'>
							</File>
EOF
}

function append_file_tag() {
	FILE_NAME=$1
	ID=`clean_id $1`
	cat >> $WXS_PATH <<EOF
	<File
		Id="_${ID^^}"
		Name="${FILE_NAME##*/}"
		DiskId='1'
		Source="$FILE_NAME"/>
EOF
}

function append_icon_tag() {
	ID=`clean_id $ICON_FILE`
	cat >> $WXS_PATH <<EOF
	<Icon Id="$ID" SourceFile="resources/$ICON_FILE" />
EOF
}


function append_component_tag() {
	FILE_NAME=$1
	ID=`clean_id $1`
	COMPONENT_IDS+="$ID "
	cat >> $WXS_PATH <<EOF
	<Component Id="$ID" Guid="`get_uuid`" KeyPath='yes'>
EOF
}

function append_directory_tag() {
	DIR_NAME=$1
	ID=`clean_id $1`
	cat >> $WXS_PATH <<EOF
	<Directory Id="_${ID^^} Name="$DIR_NAME">
EOF
}

function close_tag() {
	TAG=$1
	cat >> $WXS_PATH <<EOF
	</${TAG}>
EOF
}

function append_shortcut_tag () {
	DIRECTORY=$1
	cat >> $WXS_PATH <<EOF
	<Shortcut
		Id="$DIRECTORY$PACKAGE_NAME"
		Directory="$DIRECTORY"
		Name="$PACKAGE_NAME $PACKAGE_VERSION"
		WorkingDirectory='INSTALLDIR'
		Icon="$ICON_FILE"
		IconIndex="0"
		Advertise="yes"/>
EOF
}

function append_componentRef_tag() {
	ID=$1
	cat >> $WXS_PATH <<EOF
	<ComponentRef Id="$ID" />
EOF
}

function append_feature_tag() {
	ID=$1
	cat >> $WXS_PATH <<EOF
	<Feature
		Id="$ID"
		Title='$PACKAGE_NAME%% $PACKAGE_VERSION%%'
		Description='$GAME_DESCRIPTION'
		Display='expand'
		Level='1'
		ConfigurableDirectory='INSTALLDIR'>
EOF
}

function check_directory_for_file() {
	BASE_DIR=$1

	for FILE in $(ls $BASE_DIR);
	do
		FILE_PATH="$BASE_DIR/$FILE"
		if [ -d $FILE_PATH ];
		then
			append_directory_tag $FILE
			check_directory_for_file $FILE_PATH
			close_tag "Directory"
		else
			append_component_tag $FILE
			append_file_tag $FILE_PATH
			close_tag "Component"
		fi
	done
	BASE_DIR=${BASE_DIR%/*}
}

function gen_header() {
	cat > $WXS_PATH <<EOF
<?xml version='1.0' encoding='windows-1252'?>
<Wix xmlns='http://schemas.microsoft.com/wix/2006/wi'>
	<Product
		Name="$PACKAGE_NAME $PACKAGE_VERSION"
		Id="`get_uuid`"
		UpgradeCode="`get_uuid`"
		Language='1046'
		Codepage='1252'
		Version="$PACKAGE_VERSION"
		Manufacturer='UnB Games'>
	<Package
		Id='*'
		Keywords='Installer'
		Description="$PACKAGE_NAME $PACKAGE_VERSION installer"
		Manufacturer='UnB Games'
		InstallerVersion='100'
		Languages='1046'
		SummaryCodepage='1252'
		Compressed='yes'/>

		<Media
			Id='1'
			Cabinet='$PACKAGE_NAME.cab'
			EmbedCab='yes'
			DiskPrompt="Disk #1"
		/>

		<Property
			Id='DiskPrompt'
			Value="$PACKAGE_NAME $PACKAGE_VERSION Installation [1]"
		/>
EOF
}

function append_TEST () {
	cat >> $WXS_PATH <<EOF
	<Directory Id="ProgramMenuFolder" Name="Programs">
		<Directory Id="ProgramMenuDir" Name="$PACKAGE_NAME $PACKAGE_VERSION">
			<Component Id="ProgramMenuDir" Guid="`get_uuid`">
				<RemoveFolder
					Id='ProgramMenuDir'
					On='uninstall'/>
				<RegistryValue
					Root='HKCU'
					Key='Software\[Manufacturer]\[ProductName]'
					Type='string'
					Value=''
					KeyPath='yes'/>
			</Component>
		</Directory>
	</Directory>
EOF
}
function append_property () {
	cat >> $WXS_PATH <<EOF
	<UIRef Id="WixUI_InstallDir" />
	<UIRef Id="WixUI_ErrorProgressText" />
	<Property Id='WIXUI_INSTALLDIR' Value='INSTALLDIR' />
EOF
}


function gen_directory() {
	create_directory_file
	append_shortcut_tag "ProgramMenuDir"
	append_shortcut_tag "DESKTOPFOLDERDIR"
	close_tag "Component"

	append_component_tag "SDL"
	for DLL in $(ls bin/windows/ -I *.exe);
	do
		append_file_tag $DLL
	done
	close_tag "Component"

	append_directory_tag "resources"
	check_directory_for_file "resources"
	close_tag "Directory"

	append_TEST

	append_directory_tag "DesktopFolder"

	close_tag "Directory"

	close_tag "Directory"
	close_tag "Directory"
	close_tag "Directory"
	close_tag "Directory"

	## Add manual!

}

function gen_feature() {
	append_feature_tag "Complete"
	append_feature_tag "MainExecutable"
	for COMP_ID in $COMPONENT_IDS;
	do
		append_componentRef_tag $COMP_ID
	done
	append_componentRef_tag "ProgramMenuDir"
	close_tag "Feature"
	close_tag "Feature"

	append_property
	append_icon_tag

	close_tag "Product"
	close_tag "Wix"
}

gen_header
gen_directory
gen_feature
