ubiworks
========


build.sh
	update souce code from github
	build apk
	copy ROM files to ROM work folder for making ROM
	

release.sh
	update AndroidManifest.xml for increasing version
	call build.sh for build apk and preparation of ROM
	commit code
	add tag to code with new version number
