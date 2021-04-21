# robobackup
Supersimple script to handle a configfile-driven backup via Robocopy


# how does it work?
1. Define the origins and destinations as shown in the origins_destinations.txt example file
2. launch robobackup.bat  origins_destinations.txt
3. wait till it complete the tasks

Robocopy switches are well explained in the robocopy help itself.
The aim here was to be as much conservative as possible (only new source files or more recent source files pushed into the backup destination)
