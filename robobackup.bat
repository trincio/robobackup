@echo off
REM ROBOCOPY ERRORLEVEL  HANDLED VIA !ERRORLEVEL!
REM DETAILS: https://stackoverflow.com/questions/24866477/if-call-exit-and-errorlevel-in-a-bat

REM FEW, FEW COMMENTS IN THE CODE, BECAUSE IT IS ALMOST SELF-EXPLANATORY

setlocal enabledelayedexpansion 


cls

set robocopy_erorlevel=-1

set ERRLOG=.\ERR.LOG


echo +-----------------------------------------------+  
echo ^|Info: the 1st param is a file where to set the ^|
echo ^|following values, semicolon separated:         ^|
echo ^|                                               ^|
echo ^|-Origin path                                   ^|
echo ^|-Destination path                              ^|
echo ^|-Description                                   ^|
echo ^|-Short description for filenames               ^|
echo ^|                                               ^|
echo ^|In order to change the backup log destination  ^|
echo ^|please change the variable CurMainLogPath      ^|
echo +-----------------------------------------------+


echo BACKUPS PREPARATION.....

for /f "tokens=1,2,3,4 delims=;" %%a in (.\%1) do (


	REM DETERMINING THE TOKENIZED DATA AND VARIABLES FOR TIMESTAMP
	
	echo.
	echo.

	set SOURCE=%%a
	set DESTINATION=%%b
	set DESCRIPTION=%%c
	set DESCRIPTION_FILENAME_DETAILS=%%d
	
	set CurDate=!date:~6,4!!date:~3,2!!date:~0,2!
	set CurTime=!time:~0,2!.!time:~3,2!.!time:~6,2!
	
	set CurMainLogPath=.\robobackup_LOG
	set CurMainLogFile=!CurMainLogPath!\!CurDate!-!CurTime!_robobackup.MAIN.LOG
	set CurDetailedLogFile=!CurDate!-!CurTime!_robobackup.DETAILS_!DESCRIPTION_FILENAME_DETAILS!.LOG

	echo. 
	echo. >> !CurMainLogFile!
	echo                 --------- PROCESS BEGINNING --------- 
	echo                 --------- PROCESS BEGINNING --------- >> !CurMainLogFile!

	
	
	echo !CurDate!-!CurTime! found the source and destination for the backup '%%c'
	echo !CurDate!-!CurTime! found the source and destination for the backup '%%c' >> !CurMainLogFile!

	IF EXIST !SOURCE! (
	echo SOURCE OK         : !SOURCE!
	echo SOURCE OK         : !SOURCE! >> !CurMainLogFile!
	) ELSE (
	echo Problems reaching !SOURCE!. Probably the process will be skipped
	echo Problems reaching !SOURCE!. Probably the process will be skipped >> !CurMainLogFile!
	)

	IF EXIST !DESTINATION! (
	echo DESTINATION OK    : !DESTINATION!
	echo DESTINATION OK    : !DESTINATION! >> !CurMainLogFile!
	) ELSE (
	echo Problems reaching !DESTINATION!. Probably the process will be skipped 
	echo Problems reaching !DESTINATION!. Probably the process will be skipped >> !CurMainLogFile!
	)

	
	echo !CurDate!-!CurTime! details will be written here: '!CurDetailedLogFile!'
	echo !CurDate!-!CurTime! details will be written here: '!CurDetailedLogFile!' >> !CurMainLogFile!



	set timestamp=!date:~6,4!!date:~3,2!!date:~0,2! !time:~0,2!.!time:~3,2!.!time:~6,2!
	echo !timestamp! BEGINNING THE ROBOCOPY BETWEEN THE AFOREMENTIONED FOLDERS >> !CurMainLogFile!
	
	
	
	robocopy !SOURCE!  !DESTINATION!  /Compress /XO /fft /V /NP /R:3 /E /Z /W:5 /MT:32 /LOG+:!CurMainLogPath!\!CurDetailedLogFile!

	set robocopy_erorlevel=!ERRORLEVEL!
	echo robocopy has exited with errorlevel: !robocopy_erorlevel!
	
	
	
 
	set timestamp=!date:~6,4!!date:~3,2!!date:~0,2! !time:~0,2!.!time:~3,2!.!time:~6,2!
	echo !timestamp! FINISHED THE ROBOCOPY BETWEEN THE AFOREMENTIONED FOLDERS - ANY FURTHER MESSAGES IN THE LINES BELOW>> !CurMainLogFile!
	
	echo. >> !CurMainLogFile!
 
	

	IF !robocopy_erorlevel! EQU 0 (
		echo No issues but same files in the destination directory has been found. No action taken. Means: no copy. >> !CurMainLogFile!
	) 
	
	if !robocopy_erorlevel! EQU 1 (
		echo All selected files copied. >> !CurMainLogFile!
	) 
	
	if !robocopy_erorlevel! EQU 2 (
		echo Destination contains files not in the origin. No files copied. See the detailed log. >> !CurMainLogFile!
	) 
	
	if !robocopy_erorlevel! EQU 4 (
		echo Some files copied. The destination contains mismatched files. See the detailed log. >> !CurMainLogFile!
	) 
	
	if !robocopy_erorlevel! EQU 8 (
		echo Some files or directories could not be copied and the retry limit was exceeded. . See the detailed log. >> !CurMainLogFile!
	) 
	
	if !robocopy_erorlevel! EQU 16 (
		echo Robocopy did not copy any files.  Check the command line parameters and verify that Robocopy has enough rights to write to the destination folder. >> !CurMainLogFile!
	) 


)

	echo                --------- PROCESS COMPLETED --------- 
	echo                --------- PROCESS COMPLETED --------- >> !CurMainLogFile!

	setlocal disabledelayedexpansion

echo.
echo.
echo BACKUPS COMPLETED (see the logs)..... 
 
