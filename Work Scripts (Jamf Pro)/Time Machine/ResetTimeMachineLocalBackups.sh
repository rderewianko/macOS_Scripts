#!/bin/sh

#TimeMachine local backups get created when the specified backup disk is not available.
#This can cause local disks to get bloated with TM data.

LocalBackups=`ls -1 / | grep ".MobileBackups"`

if [[ $LocalBackups == ".MobileBackups" ]]; then
        echo "Local Time Machine backups exist, disabling local time machine"
else
        echo "No local Time Machine backups found"
        exit 0
fi

#Disable local backups - This removes the data that has been created automatically
tmutil disablelocal

echo "Cleaning up local Time Machine backups...."

#Enable local backups again
tmutil enablelocal

echo "Local Time Machine backup system reset and disk space recovered"

exit 0
