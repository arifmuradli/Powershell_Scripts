# Created by arifmuradli, please give credit to my github account when you copy.
This is a task about backing up files that can be in large amount in terms of quantity and size. For example, logs and call records.
Usually, When there is large amount of data it is difficult to analyse and manage disk spaces.
First batch script (robocopy_all_with_log.bat) will copy all files to backup directory. Including newer files which are not older than 6 months.
Second powershell script (delete_six_month_old_filesWithLOGS.ps1) will delete old files in source directory.
You can manage this process with Task Scheduler. First bat script must run (usually takes few minutes if scheduled for everyday, because, it will skip files that are already located in destination directory). Second PS script must run after the first on finishes. You can schedule it automatically after 2-3 hours just to be safe.
Even if subsequent process breaks, and second script runs first, during 6 month, there will be no data loss.
