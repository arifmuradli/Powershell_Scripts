@echo off
::  Most intriguing point about this script is that it will check destination directory and subdirectories, if there is subdirectory with the same name, it will not create new, else, new sub directory will be added
:: It is similar to one way mirror, except, when old files are removed from source it remains in destination.
:: "/E": Copies subdirectories, including empty ones.
:: "/COPYALL": Copies all file information.
:: "/R:3": Specifies the number of retries on failed copies (in this case, 3 retries).
:: "/W:1": Specifies the wait time between retries (in this case, 1 second).
:: Here $SourcePath should be replaced with local directory, for example "D:\Call Record", And $DestinationPatch should be replaced with remote destination directory, for example "\\Backup-Server\Call Record"
robocopy "$SourcePath" "\\$DestinationPath" /E /COPYALL /R:3 /W:1 >> "%LogFile%"
:: Wait for 5 seconds, this helps to monitor visually if script has started or not
timeout /t 5 /nobreak > nul
:: This part is optional, pro is you can troubleshoot if breaks occur, con is too big log file can be created for larger directories
set LogFile=D:\RobocopytoveeamLog.txt
:: Close the script
exit
