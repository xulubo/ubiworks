FILE=theubi/android/oobi/AndroidManifest.xml
BINDIR=theubi/android/oobi/bin
RELEASE_APK=${BINDIR}/theubi-release.apk
CURVER=`grep android:versionName $FILE | sed -e "s/>//g" -e "s/=//g" -e "s/\"//g" -e "s/android:versionName//g" -e "s/ //g"`
MAJOR_VER=`echo $CURVER | sed "s/[\.-]/ /g"  | gawk '{print $1;}'`
MINOR_VER=`echo $CURVER | sed "s/[\.-]/ /g"  | gawk '{print $2;}'`
REVISE_VER=`echo $CURVER | sed "s/[\.-]/ /g"  | gawk '{print $3;}'`
REVISE_VER=$((REVISE_VER+1))
DATE=`date +"%Y%m%d"`
NEWVER="$MAJOR_VER.$MINOR_VER.$REVISE_VER-$DATE"

echo ">>>>>>>>>>STAGE: pre build"
echo current version is $CURVER
echo new version will be $NEWVER
echo updating AndroidManifest.xml for updating version number
sed -i "s/$CURVER/$NEWVER/g" $FILE

if [ -f ${RELEASE_APK} ]; then
	rm ${RELEASE_APK}
fi

echo ">>>>>>>>>>STAGE: build"
build.sh fromsrc 
if [ $? -ne 0 ];then
	echo Failed! APK was not built
	echo press Enter to exit
	read x
fi

echo ">>>>>>>>>>STAGE: post build"
if [ $? -eq 0 ] && [ -f ${RELEASE_APK} ]; then
	cp ${RELEASE_APK} ${BINDIR}/theubi-${NEWVER}.apk
	cd theubi
	git commit -a -m "auto-committed by release.sh for version $NEWVER"
	git tag $NEWVER
else
	echo could not find release apk ${RELEASE_APK}
	echo build failed
fi

echo press Enter to exit
read x