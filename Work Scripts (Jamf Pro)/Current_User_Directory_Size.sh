#!/bin/sh
##########################################################
############# Current User Directory Size ################
############### written by Phil Walker ###################
##########################################################


# Locating the last logged in user.
#lastUser=`defaults read /Library/Preferences/com.apple.loginwindow lastUserName`

LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

# Calculating last Logged in user's Home Folder Size.
userHomeFolderSize=$(du -sk /Users/$LoggedInUser/ | awk '{ print $1 }')

# Calculating last logged in user's Outlook Database Size
OutlookProfile=$(du -sk /Users/$LoggedInUser/Library/Group\ Containers/UBF8T346G9.Office/Outlook/Outlook\ 15\ Profiles | awk '{ print $1 }')

# Subtracting out Outlook Profile Size
totalSize=$(($userHomeFolderSize - $OutlookProfile))

# Converting from Kilobytes to Gigabytes
GIGABYTES=$(echo "scale=2;${totalSize}/1024/1024"|bc)

echo "<result>"${GIGABYTES}"</result>"
