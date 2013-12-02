WORKDIR=`pwd`
UBI_DIR=$WORKDIR/theubi
SETUP_DIR=$WORKDIR/setup
ROM_DIR=$SETUP_DIR/tools/FactoryToolV3.4/Temp
RELEASE_APK=$UBI_DIR/android/oobi/bin/theubi-release.apk
APK_DIR=$SETUP_DIR/theubi/APKs



prerequisite() {
	echo -n 1. checking ROM build environment ... 

	if [ ! -d $ROM_DIR ]; then
		echo couldn\'t find $ROM_DIR
		fatal "ERROR: please use ROMTOOL to unpack the base ROM image first"
	fi

	echo OK!
}
	
update_source_code() {
	echo 2. updating source code from github ... 

	cd $UBI_DIR
	git pull -v --progress "origin" 
	if [ $? -ne 0 ]; then
		fatal "ERROR: something wrong while updating souce code"
	fi
	cd $WORKDIR
	echo OK!
}
	
clean_output_folders() {
	echo -n 3. cleaning build directories ... 
	rm -rf $UBI_DIR/android/oobi/bin         $UBI_DIR/android/oobi/gen
	rm -rf $UBI_DIR/android/ubisdk/bin       $UBI_DIR/android/ubisdk/gen
	rm -rf $UBI_DIR/android/OobiMediaSdk/bin $UBI_DIR/android/OobiMediaSdk/gen 
	echo OK!
}

build_apk() {
	echo -n 4. building APK ... 
	cd $UBI_DIR/android/oobi
	cmd.exe /c "ant.bat release" > /bin/nul
	if [ $? -ne 0 ]; then
		fatal "failed to build APK"
	fi
	
	if [ ! -f bin/theubi-release.apk ]; then
		fatal "Failed! APK file was not built"
	fi
	
	cd $WORKDIR
	echo OK!
}


copy_to_rom_folder() {
	echo -n 5. copying files to ROM folder ... 

	cp -f $RELEASE_APK $APK_DIR/theubi.apk
	if [ $? -ne 0 ]; then
		fatal "Failed! couldn't copy theubi-release.apk"
	fi
	
	cp -f $RELEASE_APK $SETUP_DIR/theubi/ROM/system/etc/theubi/factory/theubi.apk
	if [ $? -ne 0 ]; then
		fatal "Failed! couldn't copy theubi-release.apk"
	fi


  # ==========================================================
  # copy user apps
  # ==========================================================	
  for apk in theubi ubiupdater googlesearchbox adbkonnect MiniPcUpTime OobiGrasp; do
		cp -f $APK_DIR/$apk.apk $ROM_DIR/System/app/$apk.nm
		if [ $? -ne 0 ]; then
			fatal "Failed! could not copy $apk.apk"
		fi
  done
	

  # ==========================================================
  # copy system apps
  # ==========================================================
	for apk in IvonaTTS; do
		cp -f $SETUP_DIR/theubi/APKs/$apk.apk $ROM_DIR/System/app/$apk.apk
		if [ $? -ne 0 ]; then
			fatal "Failed! could not copy $apk.apk"
		fi
	done

  # -----------------
  # /system/lib
  #
	cp -r -f $SETUP_DIR/theubi/ROM/system/* $ROM_DIR/System/
	if [ $? -ne 0 ]; then
		fatal "Failed! while copying /system/*"
	fi

  # -----------------
  # /Boot/ramdisk/
  #
	cp -r -f $SETUP_DIR/theubi/ROM/Boot/ramdisk/* $ROM_DIR/Boot/ramdisk/
	if [ $? -ne 0 ]; then
		fatal "Failed! while copying /Boot/ramdisk/*"
	fi  
  
	echo OK!
}
	


fatal()
{
	echo $1
	echo Print Enter to exit
	read x
	exit 1
}

prerequisite

if [ $# -gt 0 ] && [ $1 == "fromsrc" ]; then
	update_source_code
	clean_output_folders
	build_apk
fi

copy_to_rom_folder

if [ $# -gt 0 ]; then
	exit 0
fi

echo press Enter to exit build
read x
