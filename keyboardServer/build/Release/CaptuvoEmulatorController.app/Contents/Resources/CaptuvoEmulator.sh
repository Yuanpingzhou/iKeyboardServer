# Important - CaptuvoEmulator requires xcode settings changes under Preference|Locations.   Set derviced data to relative /build.   The script should be executed from the directory contiang teh script (CaptuvoEmulator.sh)

# CaptuvoEmulator application support debug of captuvosdk.

DISTRO_FOLDER=CaptuvoEmulatorDebug
DISTRO_ZIP=CaptuvoEmulatorController.zip
OUTPUT_APP=CaptuvoEmulatorController.app
CURDIR="`pwd`"/"`dirname $0`"
echo $CURDIR

echo "***Environment Setup***"
rm -rf build *.zip $CURDIR/${DISTRO_FOLDER}


mkdir -p $CURDIR/${DISTRO_FOLDER}
mkdir -p $CURDIR/${DISTRO_FOLDER}/Documents

echo "***Compiling for Mac OS***"

xcodebuild -project $CURDIR/CaptuvoEnulatorController/CaptuvoEmulatorController.xcodeproj -target CaptuvoEmulatorController

#copy this simulator build for Emulator
cp -R $CURDIR/CaptuvoEnulatorController/build/Release/${OUTPUT_APP} $CURDIR/${DISTRO_FOLDER}/


echo "***Coping files***"

# Copy release documentation to distribution folder
cp -r $CURDIR/Documents/*.pdf $CURDIR/${DISTRO_FOLDER}/Documents/

# Cleanup distribution folder
find $CURDIR/${DISTRO_FOLDER} -type f -name *.DS_Store -print0 | xargs -0 rm -rdf
find $CURDIR/${DISTRO_FOLDER} -type d -name *.svn -print0 | xargs -0 rm -rdf
find $CURDIR/${DISTRO_FOLDER} -type d -name Build -print0 | xargs -0 rm -rdf
find $CURDIR/${DISTRO_FOLDER} -type d -name build -print0 | xargs -0 rm -rdf

echo "***Creating Zip***"
#zip -rq ${DISTRO_ZIP} ${DISTRO_FOLDER}/*

echo "***Cleaning up***"
rm -rf $CURDIR/build
#rm -rf $CURDIR/${DISTRO_FOLDER}
#echo "#define BUILD_NUMBER @\"Develoment Build\"" > ${PROJECT_SUB_FOLDER}/${BUILD_INFO_HEADER}



