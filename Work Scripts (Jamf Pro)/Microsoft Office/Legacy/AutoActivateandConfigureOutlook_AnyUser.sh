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
loggedInUser=$(stat -f %Su /dev/console)
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
  echo "Office 2019/365 for Mac installed, auto activating Office and configuring Outlook..."

  su -l "$loggedInUser" -c "defaults write com.microsoft.office OfficeActivationEmailAddress -string "$userUPN""
  su -l "$loggedInUser" -c "defaults write com.microsoft.office OfficeAutoSignIn -bool TRUE"
  su -l "$loggedInUser" -c "defaults write com.microsoft.Outlook DefaultEmailAddressOrDomain -string "$userEmail""
  #Set the first run setup keys for all Office apps to false (required for auto activation/signin to work)
  su -l "$loggedInUser" -c "defaults write com.microsoft.Outlook kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
  su -l "$loggedInUser" -c "defaults write com.microsoft.Word kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
  su -l "$loggedInUser" -c "defaults write com.microsoft.Excel kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
  su -l "$loggedInUser" -c "defaults write com.microsoft.onenote.mac kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
  su -l "$loggedInUser" -c "defaults write com.microsoft.Powerpoint kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"

else
  echo "Office 2019/365 for Mac not installed, nothing to do"
  exit 0

fi

#Confirm the first run reset has been completed successfully
OutlookFirstRun=$(su -l "$loggedInUser" -c "defaults read com.microsoft.Outlook kSubUIAppCompletedFirstRunSetup1507")
  if [[ "$OutlookFirstRun" == "0" ]] || [[ "$OutlookFirstRun" == "false" ]]; then
    echo "First run status reset"
  else
    echo "First run completed, Office may need to be manually activated"
  fi

#Confirm the changes have been made successfully
#Office activation
  if [[ $(su -l "$loggedInUser" -c "defaults read com.microsoft.office OfficeActivationEmailAddress") == "$userUPN" ]]; then
    echo "Office activation email set to $userUPN"
  else
    echo "Office activation email not set"
  fi

#Office auto sign-in
officeAutoSignIn=$(su -l "$loggedInUser" -c "defaults read com.microsoft.office OfficeAutoSignIn")
  if [[ "$officeAutoSignIn" == "1" ]] || [[ "$officeAutoSignIn" == "true" ]]; then
    echo "Office auto sign in enabled"
  else
    echo "Office auto sign not enabled"
  fi

#Outlook default email address
  if [[ $(su -l "$loggedInUser" -c "defaults read com.microsoft.Outlook DefaultEmailAddressOrDomain -string "$userEmail"") == "$userEmail" ]]; then
    echo "Outlook default email address set to $userEmail"
  else
    echo "Outlook default email address not set"
  fi

exit 0
