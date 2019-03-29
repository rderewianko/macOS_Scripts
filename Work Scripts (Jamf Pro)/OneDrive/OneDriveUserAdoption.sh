#!/bin/bash

#######################################################################
#                OneDrive for Business User Adoption                  #
############## written by Suleyman Twana & Phil Walker ################
#######################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Screensaver
ScreenSaverStatus=$(ps ax | grep [S]creenSaverEngine)
#Lock screen
LockScreenStatus=$(python -c 'import sys,Quartz; d=Quartz.CGSessionCopyCurrentDictionary(); print d' | grep -i "locked" | head -n1 | awk '{print $3}' | sed 's/;//g')
#OneDrive sync location
ODFolderPath="/Users/"${LoggedInUser}"/OneDrive - Bauer Group/"

########################################################################
#                            Functions                                 #
########################################################################

function checkLoginStatus ()
{
# Check if mac is at login window
	if [[ "${LoggedInUser}" == "root" ]]; then
		echo "No user logged in"
exit 0
else
		echo "${LoggedInUser} is logged in"
fi
}

function checkScreensaver ()
{
# Check if the screensaver is running
	if [[ "${ScreenSaverStatus}" != "" ]]; then
		echo "Screensaver is running"
exit 0
else
		echo "Screensaver is not running"
fi
}

function checkLockScreen ()
{
# Check if the Mac is locked
	if [[ "${LockScreenStatus}" == 1 ]]; then
		echo "Screen is locked"
exit 0
else
		echo "Screen is unlocked"
fi
}

function setupOneDrive ()
{

HELPER=$(/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Applications/OneDrive.app/Contents/Resources/OneDrive.icns -title "Microsoft OneDrive" -heading "Have you heard about OneDrive?" -description "Did you know that as an Office 365 user you have
1000 GB of cloud storage available!

Using the new OneDrive sync client you can easily sync all of your important local data to the cloud.

Giving you the flexibility to access your documents on your Mac, smartphone/tablet or browser." -button1 "Get Started" -defaultButton 1)

	if [[ "${HELPER}" == "0" ]]; then
		echo "Opening OneDrive"
	su -l "$LoggedInUser" -c "open -F /Applications/OneDrive.app"

	if [[ -d "${ODFolderPath}" ]]; then
	open "${ODFolderPath}"
else
		echo "OneDrive folder has not been created yet"
	fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

checkLoginStatus
checkScreensaver
checkLockScreen
setupOneDrive

exit 0
