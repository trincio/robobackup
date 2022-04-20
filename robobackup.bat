@echo off

 

REM ROBOCOPY ERRORLEVEL  HANDLED VIA !ERRORLEVEL!
REM DETAILS: https://stackoverflow.com/questions/24866477/if-call-exit-and-errorlevel-in-a-bat

REM FEW, FEW COMMENTS IN THE CODE, BECAUSE IT IS ALMOST SELF-EXPLANATORY

setlocal enabledelayedexpansion 
REM delayed expansion makes the errorlevel check bit different
 


cls

set robocopy_erorlevel=-1

set ERRLOG=.\ERR.LOG

REM THE DRIVE FOR THE DESTINATION
set DRIVE=%2
REM CHECK IF NOT SET
if "%~2" equ "" set DRIVE=NOT SET

REM THE SHORT PATH FOR ROBOBACKUP. E.g., if the DRIVE is C and SHORTPATH is RBK, the DESTINATION will be C:\RBK
REM !!! IMPORTANT: IT IS HARDCODED TO AVOID LONG TEXT AND MINIMIZE 255 CHAR PATH ISSUES !!!
set SHORTPATH=RBK

set CURRENTSETTINGFILE=%1
REM REMOVE THE QUOTATION MARK " 
set CURRENTSETTINGFILE=%CURRENTSETTINGFILE:"=%
REM CHECK IF NOT SET
if "%~1" equ "" set CURRENTSETTINGFILE=NOT SET

set HEAD_DESTINATION=undefined

set DEFAULT_GENERAL_TIMEOUT=10

set GENERAL_TIMEOUT=%3

IF "" == "%3" (
set GENERAL_TIMEOUT=%DEFAULT_GENERAL_TIMEOUT%
echo.
echo       INFO:
echo.
echo.
echo No timeout for the questions has been set^.
echo Robobackup is going to use the default ^(%DEFAULT_GENERAL_TIMEOUT% seconds^).
echo.
echo Press M to Move on. 
choice /C M /D M /t %DEFAULT_GENERAL_TIMEOUT%

cls
)


REM COLOR VARIABLE SETTINGS
set NEXT_LABEL=undefined

set CL_GREEN=[1;92m
set CL_RED=[1;91m
set CL_WHITE=[0m
set CL_BLUETTE=[1;94m
set CL_CYAN=[1;36m
set CL_BRIGHT=[1;97m

set CL_YELLOW=[1;33m
set CL_GROON=[1;32m
 




REM BRIEF INFO
echo +-------------------------------------------------------+  
echo ^|      THIS VERSION MUST BE RUN AS ADMIN TO WORK        ^|
echo ^|         PROPERLY AVOIDING PERMISSION ISSUES           ^|
echo ^|                                                       ^|
echo ^|    following values, semicolon separated:             ^|
echo ^|                                                       ^|
echo ^|    -Origin path                                       ^|
echo ^|    -Destination path                                  ^|
echo ^|    -Description                                       ^|
echo ^|    -Short description for filenames                   ^|
echo ^|                                                       ^|
echo ^|    In order to change the backup log destination      ^|
echo ^|    please change the variable CurMainLogPath          ^|
echo +-------------------------------------------------------+



echo. 
echo. 
echo. 
 
echo Please choose if you need to proceed (A)utomatically, (M)anually or see the (H)elp
echo (after 10 seconds the app will moveon automatically)
choice /c AMH /d A /t 10

set curerrl=%ERRORLEVEL%
REM CHOICE IS H >> HELP
if %curerrl% EQU 3  goto show_help
REM CHOICE IS M >> MAIN MENU
if %curerrl% EQU 2  goto main_menu
REM ELSE  IF A (errorlevel 1) >>  PROCEED
if %curerrl% EQU 1  goto proceed_automatically




REM AUTOEXPLICATIVE
:main_menu
cls

echo.
echo.
echo.
echo %CL_WHITE% -- ROBOBACKUP MENU --
echo.
echo D^) Set the destination %CL_BLUETTE%D%CL_WHITE%rive (currently: %CL_GREEN%'%DRIVE%:'%CL_WHITE%)
echo.
echo L^) %CL_BLUETTE%L%CL_WHITE%ist the backups stored in the destination (currently: %CL_GREEN%'%DRIVE%:'%CL_WHITE%)
echo.
echo A^) Open the %CL_BLUETTE%A%CL_WHITE%dvanced menu
echo.
echo F^) Load a setting %CL_BLUETTE%F%CL_WHITE%ile (current file: %CL_GREEN%'%CURRENTSETTINGFILE%'%CL_WHITE%).
echo.
echo P^) %CL_BLUETTE%P%CL_WHITE%rints the current setting file content.
echo.
echo B^) Move on with the %CL_BLUETTE%B%CL_WHITE%ACKUP using the current settings.
echo.
echo X^) E%CL_BLUETTE%x%CL_WHITE%it.
echo.
echo H^) Show the %CL_BLUETTE%h%CL_WHITE%elp.
echo.
echo ^(if the app doesn't get an answer in 10 minutes, will exit.^).
echo.
choice /c DLAFPBXH /d X /t 600

set curerrl=%ERRORLEVEL%

REM CHOICE IS H >> HELP
if %curerrl% EQU 8  goto show_help

REM CHOICE IS X >> EXIT
if %curerrl% EQU 7  goto end

REM CHOICE IS B >> BACKUP
if %curerrl% EQU 6 goto do_the_BACKUP

REM CHOICE IS P >> PRINT
if %curerrl% EQU 5  goto print_settingfile

REM CHOICE IS F >> FILE SETTING
if %curerrl% EQU 4  goto load_settingfile

REM CHOICE IS A >> ADVANCED MENU 
if %curerrl% EQU 3  goto advanced_menu

REM CHOICE IS L >> LIST THE BACKUPS 
if %curerrl% EQU 2  goto list_available_backups

REM CHOICE IS D >> set the DESTINATION
if %curerrl% EQU 1 goto set_destination
GOTO:EOF


:advanced_menu

rem call :proceed_or_cancel
cls
echo ADVANCED MENU
echo . 

echo T^) Define a scheduled  ^(t^)ask in windows ^(not yet implemented)
echo M^) ^(M^)anage a scheduled task in windows ^(not yet implemented)


echo.
echo You can contribute implementing the missing features via github:
echo. 
echo %CL_BLUETTE%  https://github.com/trincio/robobackup    %CL_WHITE%  
echo. 
echo. 

echo ^(if the app doesn't get an answer in 10 minutes, will exit.^).
echo.
choice /c TMC /d C /t 600

set curerrl=%ERRORLEVEL%
 
REM CHOICE IS T >>  
if %curerrl% EQU 3  goto main_menu

REM CHOICE IS M >>  
if %curerrl% EQU 2  goto main_menu

REM CHOICE IS X >> 
if %curerrl% EQU 1 goto main_menu

GOTO:EOF

:set_destination
cls
echo. 

echo %curerrl%


echo          Now it is quite important to get the right 
echo             destination from the listed disks
echo    (naturally destination can be mapped remote shares)
echo. 

echo please wait while the wmic gets the system drives...
echo.
REM GETTING THE LIST OF DISKS VIA WMIC
wmic logicaldisk get description,name, caption, filesystem, freespace, providername



echo.
if "%DRIVE%" NEQ ""  echo ^(please notice a letterdrive has already been previously set:%CL_GREEN%  %DRIVE% %CL_WHITE%^)

set /p DRIVE="Select the drive from the ones listed above (letter only): "
echo %DRIVE%

REM dir %DRIVE%:
REM IF ERRORLEVEL 1 goto notworking_driveletter

if exist %DRIVE%:\%SHORTPATH%\ (
  echo %CL_BLUETTE%%DRIVE%:\%SHORTPATH%\%CL_WHITE% found. Lets proceeed.
  set /p "=Press any key to move on..."
  goto main_menu
) else (
  echo unfortunately there's no  %CL_RED%'%DRIVE%:\%SHORTPATH%\' %CL_WHITE% folder reachable by Robobackup.
  echo Robobackup needs a reachable drive ^(current choice: '%DRIVE%'^) AND a folder %SHORTPATH% inside.
  echo The reason behind this that could seem an annoyance, comes from the fact that 
  echo it is easier and more robust to have a specific folder name for the backups, 
  echo and having a short-name folder minimizes the 255 char length folder issue ^(this 
  echo considering also that Robobackup needs some subfolder for setting the FULL and delta/incrementals^).
  echo. 
  echo [1mWhat to do in a short to make Robobackup working? 
  echo Simply exit the app and create a '%DRIVE%:\%SHORTPATH%\' folder. Thank you.%CL_WHITE%
  echo.
  set /p "=Press any key to move on..."
  goto main_menu
)

GOTO:EOF


:manage_task
goto not_implemented
:define_task
goto not_implemented

:not_implemented
cls
echo.
echo.
echo.
echo.

echo %CL_BLUETTE%   **  Unfortunately this feature has not been implemented yet  ** %CL_WHITE%  
echo.
echo.
  set /p "=Press any key to move on..."
  goto main_menu
GOTO:EOF 
 

:show_help
goto intro_help
GOTO:EOF

:detailed_help


cls
echo %CL_RED%+-------------------------------------------------------------+%CL_WHITE% 
echo %CL_RED%^|   %CL_GREEN%                                                           %CL_RED%^|%CL_WHITE% 
echo %CL_RED%^|   %CL_GREEN%                Robackup Help                              %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%                                                           %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%Robobackup works in a quite self-explanatory way.          %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%Basically the command asks for:                            %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%1. a destination drive letter                              %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%2. the path of a setting file                              %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%                                                           %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%Robobackup then runs robocopy for each item in the set-    %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%ting file.                                                 %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%                                                           %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%Robobackup, if the destination and the setting file are    %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%passed correctly, runs automatically on these settings.    %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%Otherwise it lets the user choosing  manually  the set-    %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%tings.                                                     %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%                                                           %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%Robobackup also works with the following syntax and pa-    %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%rameters:                                                  %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%                                                           %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_BLUETTE%Robobackup settingPath destinationDiskLetter timeout       %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%                                                           %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%The Robocopy used parameters are:                          %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%                                                           %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_BLUETTE%/Compress /Z /B /XO /fft /V /NP /R:3 /E /Z /W:5 /MT:32     %CL_RED%^|%CL_WHITE%
echo %CL_RED%^|   %CL_GREEN%                                                           %CL_RED%^|%CL_WHITE%
echo %CL_RED%+-------------------------------------------------------------+%CL_WHITE%  
  



  set /p "=Press any key to move to the main menu..."
  goto main_menu
GOTO:EOF

:list_available_backups
cls
echo Listing the %DRIVE%:\%SHORTPATH%\ folder (further improvements in the next releases)
echo. 
echo %CL_CYAN%

if exist %DRIVE%:\%SHORTPATH%\ (


	REM DIR ONLY NAMES, ORDERD BY NAMES AND PAGED
	dir /B /ON /P %DRIVE%:\%SHORTPATH%\

	echo %CL_WHITE%
	set /p "=Press any key to move on..."
	goto main_menu
) else (

	echo %CL_WHITE%
	echo unfortunately there's no %CL_RED%'%DRIVE%:\%SHORTPATH%\'%CL_WHITE% folder reachable by Robobackup.
	set /p "=Press any key to move back to the menu and define a drive letter..."
	goto main_menu
)
GOTO:EOF

:print_settingfile
cls
if exist %CURRENTSETTINGFILE% (

	set /p "=Press any key to read the file content..."

	more %CURRENTSETTINGFILE%

	set /p "=Press any key to go back to the menu..."

	goto main_menu
) else (

echo unfortunately  %CL_RED%'%CURRENTSETTINGFILE%'%CL_WHITE% setting file is not reachable by Robobackup.
set CURRENTSETTINGFILE=undefined
set /p "=Press any key to move back to the menu, define a different setting file or make a different choice..."
goto main_menu
)
 
GOTO:EOF


:load_settingfile
cls

echo Robobackup needs a setting file.
echo Here you can define it.
echo The current setting file is %CL_GREEN%'%CURRENTSETTINGFILE%'%CL_WHITE% ^(not yet set if empty^).
echo. 
set /p CURRENTSETTINGFILE="Type its path here: "
  
if exist %CURRENTSETTINGFILE% (

	set /p "=Press any key to read the file content..."

	more %CURRENTSETTINGFILE%

	set /p "=Press any key to proceed..."

	goto main_menu
) else (

echo unfortunately  %CL_RED%'%CURRENTSETTINGFILE%'%CL_WHITE% setting file is not reachable by Robobackup.
set CURRENTSETTINGFILE=undefined
set /p "=Press any key to move back to the menu, retry or make a different choice..."
goto main_menu
)
 
GOTO:EOF


:show-help
cls
echo Help
GOTO:EOF

:proceed_automatically
:do_the_BACKUP


cls
 
set HEAD_DESTINATION=%DRIVE%:\%SHORTPATH%\



if exist %HEAD_DESTINATION% (
echo. 
) else (

echo unfortunately the destination %CL_RED%'%HEAD_DESTINATION%'%CL_WHITE% is not reachable by Robobackup.
set HEAD_DESTINATION=undefined
set /p "=Press any key to move back to the menu, retry or make a different choice..."
goto main_menu
)



REM IN THE FILE PASSED TO THE CORE PART, WE'VE CURRENTLY 4 FIELDS:
rem SOURCE 
rem DESTINATION 
rem DESCRIPTION 
rem DESCRIPTION_FILENAME_DETAILS


	cls
	REM DETERMINING THE TOKENIZED DATA AND VARIABLES FOR TIMESTAMP

 

	set SOURCE=%%a
	set DESTINATION=%%b
	set DESCRIPTION=%%c
	set DESCRIPTION_FILENAME_DETAILS=%%d
	
	REM REMOVE THE QUOTATION MARK " 
	set SOURCE=!SOURCE:"=!
	set DESTINATION=!DESTINATION:"=!
	set DESCRIPTION=!DESCRIPTION:"=!
	set DESCRIPTION_FILENAME_DETAILS=!DESCRIPTION_FILENAME_DETAILS:"=!
	


 
	
	set CurDate=!date:~6,4!!date:~3,2!!date:~0,2!
	set CurTime=!time:~0,2!.!time:~3,2!.!time:~6,2!


	REM ADD THE HEAD PATH TO THE DESTINATION
	set COMPLETE_PATH_DESTINATION=!HEAD_DESTINATION!!DESTINATION!\!CurDate!
	
	set CurMainLogPath=!HEAD_DESTINATION!LOGS\

	echo               PRELIMINARY CHECK

	echo.
	echo.	
	REM CHECK OF THE DESTINATION HAS ALREADY DONE. NOW TIME TO CHECK THE LOGS DIRECTORY (if missing create it)
	if exist !CurMainLogPath! (
	echo %CL_GREEN%!CurMainLogPath!%CL_WHITE% exists.%CL_WHITE%   
	echo.
	call :proceed_or_cancel

	
	) else (
	cls
	echo.
	echo.
	echo.
	echo.
	echo %CL_RED%'!CurMainLogPath!' doesn't exist. The proposed option is to proceed with creating one.%CL_WHITE% 
	echo.
	echo.
	echo.
	call :proceed_or_cancel
	mkdir !CurMainLogPath!
	
	)	
 
	 
 

	REM HERE THE QUOTATION MARK, IN THE FINAL PATH, ARE NEEDED TO AVOID ANY ISSUE WITH SPACES IN PATH NAMES
	set CurMainLogFile="!CurMainLogPath!!CurDate!-!CurTime!_robobackup.MAIN.LOG"
	set CurDetailedLogFile="!CurMainLogPath!^(!DESCRIPTION_FILENAME_DETAILS!^)!CurDate!-!CurTime!_robobackup.DETAILS.LOG"

	
	REM ALSO THE SOURCE NEEDS THE QUOTATION (PREVIOUSLY REMOVED AT THE MOMENT AS A STANDARD BEHAVIOR)
	set SOURCE="!SOURCE!"

	REM ALSO THE DESTINATION NEEDS THE QUOTATION (PREVIOUSLY REMOVED TO AVOID ANY ISSUE WITH SPACES IN PATH NAMES)
	set COMPLETE_PATH_DESTINATION="!COMPLETE_PATH_DESTINATION!"

 
	cls
 
 
	echo Below you can find the log files path for further analysis in case of any issue:

	echo - MAIN LOG FILE: %CL_BLUETTE%!CurMainLogFile!%CL_WHITE%
	echo - DETAILED LOG:  %CL_BLUETTE%!CurDetailedLogFile!%CL_WHITE%
	

	echo.
	
	echo And here you can find the data used for this backup task:
	
	echo - SOURCE:         %CL_BLUETTE%!SOURCE!%CL_WHITE%
	echo - SOURCE:         !SOURCE! >> !CurMainLogFile!
						 
						 
						 
	echo - DESTINATION:    %CL_BLUETTE%!COMPLETE_PATH_DESTINATION!%CL_WHITE%
	echo - DESTINATION:    !COMPLETE_PATH_DESTINATION!	>> !CurMainLogFile!
	echo - DESCRIPTION:    %CL_BLUETTE%!DESCRIPTION!%CL_WHITE%
	echo - DESCRIPTION:    !DESCRIPTION! >> !CurMainLogFile!



	echo - DESCR. DETAILS: %CL_BLUETTE%!DESCRIPTION_FILENAME_DETAILS!%CL_WHITE%
	echo - DESCR. DETAILS: !DESCRIPTION_FILENAME_DETAILS! >> !CurMainLogFile!
 

	
	echo. 
	echo. >> !CurMainLogFile!
	echo --------- PROCESS BEGINNING at %CL_BLUETTE%!CurDate!-!CurTime!%CL_WHITE% for the backup '%CL_BLUETTE%!DESCRIPTION!%CL_WHITE%' --------- 
	echo --------- PROCESS BEGINNING at !CurDate!-!CurTime! for the backup '!DESCRIPTION!' --------- >> !CurMainLogFile!
 	echo.
	
 	IF EXIST !SOURCE! (
	echo SOURCE: %CL_GREEN%found%CL_WHITE%^(!SOURCE!^)%CL_WHITE%
	echo SOURCE: !SOURCE!  has been found >> !CurMainLogFile!
	echo.
	) ELSE (
	echo Problems reaching %CL_RED%!SOURCE!%CL_WHITE%. Probably the process will be skipped. 
	echo It is up to you try to move on or not.
	echo If you're not completely aware about what you're doing, please cancel the operation.
	echo Problems reaching !SOURCE!. Probably the process will be skipped >> !CurMainLogFile!
	)


	call :proceed_or_cancel
	
	cls

	REM RELEVANT CHECK: IF THE DESTINATION ALREADY EXISTS IT COULD BE A PROBLEM
	IF EXIST !COMPLETE_PATH_DESTINATION! (
 
	echo %CL_CYAN%'       THE FOLDER %CL_RED%'!COMPLETE_PATH_DESTINATION!'%CL_CYAN% ALREADY EXISTS!%CL_WHITE%'
	echo.
	echo What does that mean? Maybe you have already launched the backup today.
	echo.
	echo Maybe you really need to launch again the Robobackup with such exact destination BUT
	echo this would be an aware action, and to be sure it is aware you're asked to launch 
	echo manually the robocopy command.
	echo.
	echo Please be sure you UNDERSTAND what does mean launching the following command before
	echo launching it.
	echo.
	echo %CL_RED% robocopy !SOURCE!  !COMPLETE_PATH_DESTINATION!  /Compress /Z /B /XO /fft /V /NP /R:3 /E /Z /W:5 /MT:32 /LOG+:!CurDetailedLogFile! %CL_CYAN%
	echo.
	echo.


	
	call :proceed_or_cancel
	 
	)
 
	
	echo !CurDate!-!CurTime! details will be written here: '!CurDetailedLogFile!'
	echo !CurDate!-!CurTime! details will be written here: '!CurDetailedLogFile!' >> !CurMainLogFile!


	call :proceed_or_cancel
	cls

 
	set timestamp=!date:~6,4!!date:~3,2!!date:~0,2! !time:~0,2!.!time:~3,2!.!time:~6,2!
	echo !timestamp! BEGINNING THE ROBOCOPY BETWEEN THE AFOREMENTIONED FOLDERS >> !CurMainLogFile!
	
	echo *** RUNNING THE FOLLOWING COMMAND:
	echo robocopy !SOURCE!  !COMPLETE_PATH_DESTINATION!  /Compress /Z /B /XO /fft /V /NP /R:3 /E /Z /W:5 /MT:32 /LOG+:!CurDetailedLogFile! >> !CurMainLogFile!
	echo
	robocopy !SOURCE!  !COMPLETE_PATH_DESTINATION!  /Compress /Z /B /XO /fft /V /NP /R:3 /E /Z /W:5 /MT:32 /LOG+:!CurDetailedLogFile!

	REM set robocopy_erorlevel=!ERRORLEVEL!
	set robocopy_erorlevel=ERRORLEVEL
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

GOTO:EOF 





:notworking_driveletter
echo Error reading %DRIVE%. Please check, then restart the app.
timeout /T %GENERAL_TIMEOUT%
GOTO:EOF


:proceed_or_cancel


REM if %NEXT_LABEL%==undefined (

	REM echo there's probably a development issue because the NEXT_LABEL variable has not been set properly.
	REM echo EXITING THE APP
	REM exit /b 1
	
REM )

echo %CL_BRIGHT%Would you want to proceed?%CL_WHITE%
echo.
echo %CL_BLUETTE%Y%CL_WHITE%=Yes, %CL_BLUETTE%C%CL_WHITE%=Cancel, default: Y (will be chosen in %GENERAL_TIMEOUT% seconds).
echo.
choice /C YC  /D Y /t %GENERAL_TIMEOUT%
REM if %ERRORLEVEL%==1 goto %NEXT_LABEL%
REM if /i erorlevel==2 goto main_menu
REM if /i erorlevel==1 GOTO:EOF

REM if %ERRORLEVEL%==2 GOTO:EOF
REM if %ERRORLEVEL%==1 goto main_menu

set curerrl=%ERRORLEVEL%
if %curerrl% EQU 2 goto main_menu
if %curerrl% EQU 1 GOTO:EOF

GOTO:EOF

 
 
:intro_help


REM in the picture remember to escape also the ^ and the +, other than the | and the > or <, (, ), !, ", comma, backthick, &, '

REM the % must be escaped with double %
cls


echo  .
echo                                       %CL_GREEN%        _____                   %CL_BRIGHT%    www.trincio.com          
echo                                       %CL_GREEN%      _¡g¶¶@@Ê^^^^^^¶¶gg¡_      %CL_BRIGHT%    www.gabrielemotta.com        
echo                                       %CL_GREEN%   _µP¶¯¯¯^^°ÑL   ¶@@@@¶¶¡_     %CL_BRIGHT%                                 
echo                                       %CL_GREEN% ¸¶Ê  ¨L     _   ÑÑ¶@@¶  ^^q_   %CL_BRIGHT%      Robobackup 1.0                        
echo                                       %CL_GREEN%p^^ Å_  ]     L  J   ¯Ñ¶   ¸¶ç  %CL_BRIGHT%      _                          
echo                %CL_BRIGHT%       _      ¡_     %CL_GREEN%_¶    )  ¨_    L  Í    ]¯  ,¶@¶§%CL_BRIGHT%g¡¡¡__¶`ç    ¡~q                  
echo                %CL_BRIGHT%      ¶^^¼____j¡^^¼æw=ª%CL_GREEN%°[     \  \    L  È    Ê  ,Õ¶@@@È%CL_BRIGHT%¯¯¯¯Ñ¯°^^^^°°°Ê,w¶mmæq_            
echo                %CL_BRIGHT%¸¡æ^*w¶¶~ Î^^¯¯¯ ^|0L  %CL_GREEN%  ¶ç     L J_   L J    j  y^^q¶@@¶L%CL_BRIGHT%    ¶ L     L]     [¶            
echo               _%CL_BRIGHT%¶¶       [     J L  %CL_RED% J@%CL_GREEN%¶§     L [   ^| ^|   ,^^ J¯_¶@@@^|[%CL_BRIGHT%     W      \]     [¶%CL_YELLOW%g¡_         
echo          _¡y¶ÑÑ%CL_BRIGHT%ÑÑ      ¿¶     ¨ý   %CL_RED% ¶¯Ê%CL_GREEN%¶¶_    ,"_  ^| È   ¶ /¯,¶@@¶Ñ¶%CL_RED%[%CL_BRIGHT%     `      ¨¶     [¶ÑÑÑ%CL_YELLOW%¶¶gg¡_   
echo      _¡y¶°¯    %CL_BRIGHT% Ër     ^^       ¯  %CL_RED%  J ¯Ñ@%CL_GREEN%¶ç    ,\  ¬ L  0 / g¶@@@¶Ñ%CL_RED%¶¶%CL_BRIGHT%                   [¶   %CL_YELLOW%  ¯^^ÑÑ¶g¿
echo   ¼g¶¶Ê_       %CL_BRIGHT% ¶[                 %CL_RED%  L  ¶¶%CL_GREEN%Ñ¶_   \L  J  ¸Ñ` g@¶ÅÑ@%CL_RED% MÑ[ %CL_BRIGHT%                  ÇÊ    %CL_YELLOW%    _¡ý¶
echo        ¯°ªw¡_  %CL_BRIGHT% ¯Ñ¶µ,_             %CL_RED%  ¶¡¡@¶%CL_GREEN% ¯Ñç   â  É  ý´¡¶@¶¯ _@%CL_RED%@g¶L %CL_BRIGHT%            _._Ær^^     %CL_YELLOW%_¡g¶¶°¯  
echo            ¯^^¶ç_   %CL_BRIGHT%^^ÞÃ~»,_       %CL_RED%    ¶¯°Ñ¶y_ %CL_GREEN%^^¶¡_ ______¶@¶¯ %CL_RED%_g¶Ñ^^0Õ¸  %CL_BRIGHT%       ¸.-¡æ~¯     %CL_YELLOW%_g¶@¶°¯     
echo               ¯Ñ¶¡   %CL_BRIGHT% ¯^^^*Ê¶v,_   %CL_RED%   M©^>,  ¯Ñ¶g¡%CL_GREEN%¶@¶@@@@@@@Ê¡%CL_RED%g¶Ñ¯  «$£¶   %CL_BRIGHT%  _.r_g¶¶¯  %CL_YELLOW%    _æ¶@¶¯        
echo                  Ñ¶¡      Ñ¶g¡°%CL_BRIGHT%»,_ %CL_RED%  L '`¬   ¯°Ñ¶¶¶¯¯¯°%CL_RED%Ñ¶¶Ñ¯  ¸z^>~%CL_BRIGHT% _¶ ,«³^^¡æ°%CL_YELLOW%@@¶¨      0¶@¶¯          
echo                   ¯¶¶¸     Ñ@@¶^*%CL_BRIGHT%«¯~«¡J¾¸ %CL_RED%`=Z^+¸_ %CL_CYAN%¶ ]¸¸_[ 0%CL_RED%¶ ¸«¢³¯ %CL_BRIGHT% p¶P^^_æ¶^^  %CL_YELLOW%¶@@Ê     _¶@@Å            
echo                     Ñ¶§     ¶@@§ ¯%CL_BLUETTE%°¶%CL_BRIGHT%¡Å¶¯4¡ %CL_RED% `=^^¬%CL_CYAN%¶c,   ¯N¶%CL_RED%ã^<è^^%CL_BRIGHT%  _p°_¶%CL_BLUETTE%g¶¯%CL_YELLOW%    _@@¶     _¶@@Ê             
echo   yggggggg¡_         0¶¶¡    ¶@@L %CL_BLUETTE% J@%CL_BRIGHT%@Ñ  ¯³,   ,%CL_CYAN%¨¨^^¨¨¨  ¨%CL_BRIGHT%¯   ¸æ´ ¸Ê¶%CL_BLUETTE%@¶  %CL_YELLOW%   ¶@@Ê     ¶@@Ê        ,«-~~°
echo   @@@@@@@¶¶@¶¶¡_      ^^@¶¡   ¨¶@¶%CL_BLUETTE%  ¯@@%CL_BRIGHT% `¡   °, ]          %CL_BRIGHT% µ°¯  gÊ%CL_BLUETTE%w¶@¶  %CL_YELLOW%  w@@¶     ¶@@Ê     ¸«"¯      
echo   @@@@@@@@@@@@@¶¶¡_    Ñ@@§   Ñ@@§%CL_BLUETTE%  ¶@[%CL_BRIGHT% ¯¼_  ¯ç]_¶~~~!¶¸M É   %CL_BRIGHT%_¶¯ %CL_BLUETTE%¶@@Ê   %CL_YELLOW% ¶@@È    _¶@¶    ¡¶^^       __
echo   ¯^^¯Ñ@@@¶°ÑÑ¶@@@@¶y    Ñ@@§   ¶@@ç %CL_BLUETTE%Ñ@¶ç%CL_BRIGHT%  Ñ¡  "g/      `MÏ   yÉ  %CL_BLUETTE%¶@@¶¨  %CL_YELLOW%  @@¶     ¶@@È  ¡¶@@¶_¡¡¶@°°^^^^
echo       Ñ¶@¶¶_  ¯Ñ@@@@¶¸   ¶@@L  ¯¶@¶  %CL_BLUETTE%¶@¶ç %CL_BRIGHT%¶¯°¡ ¯        `  ¡P¶  %CL_BLUETTE%¶@@¶¯    %CL_YELLOW%¶@@Ê     ¶¯¶  g¶@@@¶¶°ã¯     
echo      __ý@@@¶¶¶g¶@@@@[¯   0Ê¯¶   Ñ@@L %CL_BLUETTE%¯¶@@¶¶  %CL_BRIGHT% ³w_       ],¶¯ %CL_BLUETTE%J_¶@@¶^^    %CL_YELLOW% ¶@@¨     L ¶ g¶@@¶¯  p¯      
echo   gg¶@@@@@@@@@@@@@@¶¶     ¶ ¯L   ¶@¶_%CL_BLUETTE%  Ñ@@¶§¸  %CL_BRIGHT% ¯¯^^^^¶°^^^^¯ %CL_BLUETTE%   g@@¶Å¯  %CL_YELLOW%    Ñ¶¶      L ¶_¶@¶Ê¯w¶¡p=!~~==¬
echo   @@@@@@@@@@@@@@@@@@¶ç    ¶p ^^   J¶@[   %CL_BLUETTE%`¶¶@¶¶g_    ¶    _¡¶¶@¶Ñ¯       %CL_YELLOW% ¯¶Ê      [_¶¶@¶¯¡g¶@@¶       
echo   @@@@¶ÑÑ$ÅÑ¶°°Ñ¶ÑÑÑ¶¶    J§      ¶Ñ¶    %CL_BLUETTE% ¯Ñ¶@@¶¶g¡¡¶¡gg¶¶@¶¶Ê¯        %CL_YELLOW% ¶ ¶L      ¶@@¶¶¡¶¶ÑÑÑ°¶¶¶¶¶¶¶¶
echo   ¶¶Ê_y¶°¯    £¯     ¯¹    Ê      ¶  r   %CL_BLUETTE%    ¯°Ñ¶@@@@@@¶ÑÑ^^¯            %CL_YELLOW%  ¶       ¶¶àÑÕ¯¯¡¶Ñ¯¯    ¯4_ 
echo   _g¶^^        ¶                    L ì  %CL_BLUETTE%          Ñ@@@¶                 %CL_YELLOW%  ]      ¡¶^^  ¡æ°¯        _p¨ 
echo   Ñ¯          ¯!                   ª "   %CL_BLUETTE%          ÑÑÑF                  %CL_YELLOW% ´    -°¯   °¯          ª^^   
echo. 
choice /C P /D P /t 5
goto detailed_help

GOTO:EOF


:end
cls
	echo.
	echo.
	echo.
	echo.
	echo %CL_CYAN%       ROBOBACKUP HAS COMPLETED ITS ACTIVITIES    %CL_WHITE%
	echo %CL_CYAN%       ANY ERROR DETAIL COULD BE FOUND IN THE     %CL_WHITE%
	echo %CL_CYAN%              LOG FILES FOR FURTHER               %CL_WHITE%
	echo %CL_CYAN%                      ANALYSIS                    %CL_WHITE%
	echo.          
echo.	           
	echo %CL_CYAN%          IF YOU ARE A DEVELOPER OR A SYS         %CL_WHITE%
	echo %CL_CYAN%               ADMIN AND YOU SUSPECT              %CL_WHITE%
	echo %CL_CYAN%              A BUG, WE'D BE PLEASED              %CL_WHITE%	
	echo %CL_CYAN%             IF YOU REPORT A SOLUTION             %CL_WHITE%	
	echo %CL_CYAN%                 TO THE ROBOBACKUP                %CL_WHITE%	
	echo %CL_CYAN%                    GITHUB PAGE                   %CL_WHITE%	
	echo %CL_CYAN%      https://github.com/trincio/robobackup       %CL_WHITE%	
echo.	           
	echo %CL_CYAN%                               thank you.         %CL_WHITE%	
	echo.
	echo.
	echo.

rem Currently a GOTO:EOF returns to the caller subroutine, that currently produces errors
rem in case of less basic process flows. The workaround is the following. TODO: implement a better
rem flow handling.
 set /p "=Press any key to exit..."
exit
   