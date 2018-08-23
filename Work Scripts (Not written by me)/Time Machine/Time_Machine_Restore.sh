#!/bin/bash

################################################
#Setting up Time Machine to restore from backup#
################################################

################################################
#Variables
Shared="/Volumes/Macintosh HD/Users/Shared"
UserProfiles="/Volumes/Macintosh HD/Users"
Backup="/Volumes/Backup"
#For TimeMachine setup
Applications="/Applications"
Library="/Library"
System="/System"
usr="/usr"
AdminUser="/Users/admin"
################################################

################################################
#Functions
################################################

function VolumeBackupPresentCheck ()
{
BackupPartition=`diskutil list | grep "Backup" | awk '{ print $3 }' | head -n 1`

#Chek if Backup partition is present

if [[ "$BackupPartition" != Backup ]]; then
		echo "Backup partition could not be found, nothing to restore quitting..."
		exit 0
	else
		echo "Backup partition present, setup TimeMachine so we can use the Restore function"
		#Enable TM so we can then restore. Without enable TM first you cannot use the restore function.

				tmutil enable

		#Set Backup partition

				tmutil setdestination "$Backup"

		#Adding System, Library, Applications and Backup partition to TM exclusion list

				tmutil addexclusion -p "$Applications" && echo "$(tmutil isexcluded "$Applications")"
				tmutil addexclusion -p "$Library" && echo "$(tmutil isexcluded "$Library")"
				tmutil addexclusion -p "$System" && echo "$(tmutil isexcluded "$System")"
				tmutil addexclusion -p "$AdminUser" && echo "$(tmutil isexcluded "$AdminUser")"
				tmutil addexclusion -p "$usr" && echo "$(tmutil isexcluded "$usr")"
fi
}

#Check if backup partition is empty
function VolumeBackupEmptyCheck ()
{
BackupContent=$(ls -A /Volumes/Backup/ | grep "Backups.backupdb")

if [[ "$BackupPartition" == Backup && "$BackupContent" != Backups.backupdb ]]; then
        echo "No Backup DB found, nothing to restore quitting...."
        exit 0
else
        echo "Backup DB found"
fi
}

function TMBackupDateCheck ()
{
#Check the backup modification date

DATE=`date | awk '{print $2,$3,$6}'`
BackupDate=`ls -l /Volumes/Backup/Backups.backupdb/* | grep "Latest" | awk '{print $6,$7,$11}' | sed 's/-.*//'`

if [[ "$DATE" != "$BackupDate" ]]; then
		echo "Backup is not recent so cannot restore, quitting..."
		exit 0
else
		TMlatestBackup=$(tmutil latestbackup)
		TMrestoreSizeHuman=$(du -sh /$TMlatestBackup/Macintosh\ HD/Users/ | awk '{print $1}')
		echo "Backup is recent, lets restore $TMrestoreSizeHuman"
fi
}


function VolumeSharedDelete ()
{
#Remove the Shared folder created by the Casper rebuild process

if [[ ! -d "$Shared" ]]; then
			echo "Shared folder not found but will be restored from backup"
fi

if [[ -d "$Shared" ]]; then
		rm -r "$Shared"
		echo "Shared folder deleted and will be restored from backup"
fi
}

function TMRestoreProfiles ()
{
#Now Restore users profiles


Output=$(tmutil latestbackup)

if [[ "$BackupPartition" == Backup ]]; then
		if [[ `tmutil restore -v /$Output/Macintosh\ HD/Users/* "$UserProfiles" 2>/dev/null` ]]; then
			echo "Users profiles successfully restored"
		fi
fi
}

function VolumeSharedPermissionsFix ()
{
#Change files to correct permissions
chmod -R 777 "$Shared"
#Check file permissions changed correctly
sharedFolderperms=`ls -l /Users/ | grep "Shared" | cut -c 2-10`
if [[ $sharedFolderperms == "rwxrwxrwx" ]]; then
		echo "Shared folder permissions set to everyone"
else
		echo "Shared folder permissions are incorrect"
fi
}

echo "Checking if there are profiles to be restored"
VolumeBackupPresentCheck
VolumeBackupEmptyCheck
TMBackupDateCheck
echo "Passed all checks - Valid Backup found so we can restore"
VolumeSharedDelete
TMRestoreProfiles
VolumeSharedPermissionsFix
