#!/bin/sh

#TimeMachine local backups get created when the specified backup disk is not available.
#This can cause local disks to get bloated with TM data.

LocalBackups=$(ls -1 / | grep ".MobileBackups")

if [[ "$LocalBackups" == ".MobileBackups" ]]; then
    echo "Local Time Machine backups exist, cleaning up....."
#Disable local backups - This removes the data that has been created automatically
    tmutil disablelocal

#Enable local backups again
    tmutil enablelocal
    echo "Local Time Machine backup system reset and disk space recovered"
else
    echo "No local Time Machine backups found, nothing to do"
    exit 0
fi

exit 0
