# robobackup
Supersimple script to handle a configfile-driven backup via Robocopy - [Frameworkless](https://github.com/frameworkless-movement/manifesto)

![image](https://user-images.githubusercontent.com/13221359/168588983-f46b5ac6-bfb4-4d64-a221-a43230c8ed44.png)

## Features in development
Simple incremental backup basing on the folder names
Task scheduling


# how does it work?
1. Define the origins and destinations as shown in the **origins_destinations.txt** example file
2. launch **robobackup.bat**  origins_destinations.txt
3. wait till it completes the tasks

Robocopy switches are well explained in the robocopy help itself.
The aim here was to be as much conservative as possible (only new source files or more recent source files pushed into the backup destination)

## details

You can launch robobackup passing some parameters like the configfile and let it working, or you can also launch robobackup without parameters. Anyhow, when it starts, you can press **M** to move into the manual mode, and get the main menu. 

In the menu you can:

- Set the destination Drive.
- List the backups stored in the destination.
- Open the Advanced menu.
- Load a setting File.
- Prints the current setting file content.
- Move on with the BACKUP using the current settings.
- Exit.
- Show the help.

The help shows as it follow:

``` tex
|                 Robackup Help                              | 
|                                                            | 
|  Robobackup works in a quite self-explanatory way.         | 
|  Basically the command asks for:                           | 
|  1. a destination drive letter                             | 
|  2. the path of a setting file                             | 
|                                                            | 
|  Robobackup then runs robocopy for each item in the set-   | 
|  ting file (the file MUST be ANSI, UTF not-allowed).       | 
|                                                            | 
|  Robobackup, if the destination and the setting file are   | 
|  passed correctly, runs automatically on these settings.   | 
|  Otherwise it lets the user choosing  manually  the set-   | 
|  tings.                                                    | 
|                                                            | 
|  Robobackup also works with the following syntax and pa-   | 
|  rameters:                                                 | 
|                                                            | 
|  Robobackup settingPath destinationDiskLetter timeout      | 
|                                                            | 
|  The Robocopy used parameters are:                         | 
|                                                            | 
|  /Compress /Z /B /XO /fft /V /NP /R:3 /E /Z /W:5 /MT:32    | 


```
