path
@echo off
set _=%CD%
set UBI_DIR=%_%\theubi
set SETUP_DIR=%_%\setup
set ROM_DIR=%SETUP_DIR%\tools\FactoryToolV3.4\Temp

:BEGIN

:PREREQUISITE 
	echo | set /p dummy=1. checking ROM build environment ... 

	if not exist %ROM_DIR% (
		echo ERROR: please use ROMTOOL to unpack the base ROM image first
		goto ERROR
	)

	echo OK!
	
:UPDATE_SOURCE
	echo | set /p dummy=2. updating source code from github ... 

	git pull --recurse-submodules=yes > nul
	if %ERRORLEVEL% neq 0 goto ERROR

	cd %UBI_DIR%
	git pull -v --progress "origin" master
	if %ERRORLEVEL% neq 0 goto ERROR
	cd %_%
	echo OK!
	
:CLEAN_OUPUT_FILES
	echo | set /p dummy=3. cleaning build directories ... 
	rd /q /s %UBI_DIR%\android\oobi\bin %UBI_DIR%\android\oobi\gen
	rd /q /s %UBI_DIR%\android\ubisdk\bin %UBI_DIR%\android\ubisdk\gen
	rd /q /s %UBI_DIR%\android\OobiMediaSdk\bin %UBI_DIR%\android\OobiMediaSdk\gen 
	echo OK!

:BUILD
	echo | set /p dummy=4. building APK ... 
	cd %UBI_DIR%\android\oobi
	call ant release 
	if %ERRORLEVEL% neq 0 goto ERROR
	if not exist bin\theubi-release.apk (
		echo Failed!
		echo APK file was not built
		goto ERROR
	)
	cd %_%
	echo OK!

:COPY_TO_ROM_TMP
	echo | set /p dummy=5. copying files to ROM folder ... 
	copy %UBI_DIR%\android\oobi\bin\theubi-release.apk %SETUP_DIR%\theubi\APKs\theubi.apk
	if %ERRORLEVEL% neq 0 goto ERROR_COPY
	
	copy %UBI_DIR%\android\oobi\bin\theubi-release.apk %SETUP_DIR%\theubi\ROM\etc\theubi\factory\theubi.apk
	if %ERRORLEVEL% neq 0 goto ERROR_COPY

	copy %SETUP_DIR%\theubi\APKs\theubi.apk %ROM_DIR%\System\etc\theubi\factory\theubi.apk
	if %ERRORLEVEL% neq 0 goto ERROR_COPY

	copy %SETUP_DIR%\theubi\ROM\system\bin\* %ROM_DIR%\System\bin\
	if %ERRORLEVEL% neq 0 goto ERROR_COPY

	copy %SETUP_DIR%\theubi\ROM\system\etc\permissions\* %ROM_DIR%\System\etc\permissions\
	if %ERRORLEVEL% neq 0 goto ERROR_COPY

	rd /q /s %ROM_DIR%\system\etc\theubi
	xcopy %SETUP_DIR%\theubi\ROM\etc\* %ROM_DIR%\system\etc\ /E /I /Y
	if %ERRORLEVEL% neq 0 goto ERROR_COPY

	echo OK!
	goto END
	
:ERROR_COPY
	echo ERROR: failed to copy files
	
:END
	echo succeeded!
	pause
	exit
	
:ERROR
	echo failed!
	pause