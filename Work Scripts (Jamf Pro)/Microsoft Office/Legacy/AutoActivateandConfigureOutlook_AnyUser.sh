#!/bin/bash

########################################################################
#  Auto activate Office 2019/365 and auto configure Outlook 2019/365   #
################# Written by Phil Walker August 2019 ###################
########################################################################

#Designed to be included in the same policy as the Office 2019 package
#No mailbox location check included

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Get the Office version to confirm its 2019
officeVersion=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' /Applications/Microsoft\ Outlook.app/Contents/Info.plist | sed -e 's/\.//g' | cut -c1-4)
#Get the logged in users email address
userEmail=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep EMailAddress: | awk '{print $2}')
#Get the logged in users UPN
userUPN=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep "userPrincipalName" | awk '{print $2}')
#Office plist
officePlist="/Users/$loggedInUser/Library/Preferences/com.microsoft.office.plist"
#Outlook plist
outlookPlist="/Users/$loggedInUser/Library/Preferences/com.microsoft.Outlook.plist"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
  echo "No logged in user, exiting..."
  exit 0
fi

#If there is a logged in user, confirm that Office 2019 is installed before continuing
if [[ "$officeVersion" -ge "1617" ]]; then
  echo "Office 2019 installed, auto activating Office and configuring Outlook..."

    su -l "$loggedInUser" -c "defaults write "$officePlist" OfficeActivationEmailAddress -string "$userUPN""
    su -l "$loggedInUser" -c "defaults write "$officePlist" OfficeAutoSignIn -bool TRUE"
    su -l "$loggedInUser" -c "defaults write "$outlookPlist" DefaultEmailAddressOrDomain -string "$userEmail""

else
  echo "Office 2019 not installed, nothing to do"
  exit 0

fi

#Confirm the changes have been made successfully
if [[ $(su -l "$loggedInUser" -c "defaults read "$officePlist" OfficeActivationEmailAddress") == "$userUPN" ]]; then
  echo "Office activation email set to $userUPN"
else
  echo "Office activation email not set"
fi

officeAutoSignIn=$(su -l "$loggedInUser" -c "defaults read "$officePlist" OfficeAutoSignIn")
if [[ "$officeAutoSignIn" -eq "1" ]] || [[ "$officeAutoSignIn" == "true" ]]; then
  echo "Office auto sign in enabled"
else
  echo "Office auto sign not enabled"
fi

if [[ $(su -l "$loggedInUser" -c "defaults read "$outlookPlist" DefaultEmailAddressOrDomain -string "$userEmail"") == "$userEmail" ]]; then
  echo "Outlook default email address set to $userEmail"
else
  echo "Outlook default email address not set"
fi

exit 0
