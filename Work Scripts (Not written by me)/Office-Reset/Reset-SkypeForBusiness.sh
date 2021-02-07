#!/bin/zsh

# Script written by Paul Bowden (Software Engineer/Office for Mac at Microsoft) and available from https://office-reset.com/

autoload is-at-least
########################################################################
#                            Functions                                 #
########################################################################

GetLoggedInUser() {
	LOGGEDIN=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/&&!/loginwindow/{print $3}')
	if [ "$LOGGEDIN" = "" ]; then
		echo "$USER"
	else
		echo "$LOGGEDIN"
	fi
}

SetHomeFolder() {
	HOME=$(dscl . read /Users/"$1" NFSHomeDirectory | cut -d ':' -f2 | cut -d ' ' -f2)
	if [ "$HOME" = "" ]; then
		if [ -d "/Users/$1" ]; then
			HOME="/Users/$1"
		else
			HOME=$(eval echo "~$1")
		fi
	fi
}
########################################################################
#                         Script starts here                           #
########################################################################

echo "Office-Reset: Starting Reset-SkypeForBusiness"
LoggedInUser=$(GetLoggedInUser)
SetHomeFolder "$LoggedInUser"
echo "Office-Reset: Running as: $LoggedInUser; Home Folder: $HOME"
# Close Skype for Business
/usr/bin/pkill -9 'Skype for Business'
echo "Office-Reset: Skype For Business closed"
# Config data removal
echo "Office-Reset: Removing configuration data for Skype For Business"
/bin/rm -rf "$HOME/Library/Application Scripts/com.microsoft.SkypeForBusiness"
/bin/rm -rf "$HOME/Library/Containers/com.microsoft.SkypeForBusiness"
/bin/rm -rf "$HOME/Library/Saved Application State/com.microsoft.SkypeForBusiness.savedState"
/bin/rm -rf "$HOME/Library/Internet Plug-Ins/MeetingJoinPlugin.plugin"
/bin/rm -f "$HOME/Library/Preferences/com.microsoft.OutlookSkypeIntegration.plist"
/bin/rm -f "$HOME/Library/Preferences/com.microsoft.skypeforbusiness.plugin.plist"
/bin/rm -f "/Library/Preferences/com.microsoft.SkypeForBusiness.plist"
/bin/rm -f "/Library/Managed Preferences/com.microsoft.SkypeForBusiness.plist"
/bin/rm -f "$HOME/Library/Preferences/com.microsoft.SkypeForBusiness.plist"
echo "Office-Reset: Configuration data for Skype For Business removed"
# Remove items from keychain
echo "Office-Reset: Removing keychain items for Skype For Business"
KeychainHasLogin=$(/usr/bin/security list-keychains | grep 'login.keychain')
if [ "$KeychainHasLogin" = "" ]; then
	echo "Office-Reset: Adding user login keychain to list"
	/usr/bin/security list-keychains -s "$HOME/Library/Keychains/login.keychain-db"
fi
/usr/bin/security delete-generic-password -l 'com.microsoft.SkypeForBusiness.HockeySDK'
/usr/bin/security delete-generic-password -l 'Skype for Business'
echo "Office-Reset: Keychain items for Skype for Business removed"
echo "Office-Reset: Finished Reset-SkypeForBusiness"
exit 0