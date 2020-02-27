#!/bin/bash

########################################################################
#  Auto activate Office 2019/365 and auto configure Outlook 2019/365   #
################# Written by Phil Walker August 2019 ###################
########################################################################

##jamf Pro policy requirements##
#Create policy to run this script only, trigger=login Frequency=once per user per computer
#Can also be included in the policy to install Office 365 for Mac

########################################################################
#                            Variables                                 #
########################################################################

#Get the current logged in user
loggedInUser=$(stat -f %Su /dev/console)
#Logged in users home directory
userHomeDirectory=$(/usr/bin/dscl . -read /Users/"$loggedInUser" NFSHomeDirectory | awk '{print $2}')
#Get the Office version to confirm its 2019/365
officeVersion=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' /Applications/Microsoft\ Outlook.app/Contents/Info.plist | sed -e 's/\.//g' | cut -c1-4)
#Office 365 licensing files
o365Product="$userHomeDirectory/Library/Group Containers/UBF8T346G9.Office"
o365Submain="$o365Product/com.microsoft.Office365.plist"
o365Subbak1="$o365Product/com.microsoft.e0E2OUQxNUY1LTAxOUQtNDQwNS04QkJELTAxQTI5M0JBOTk4O.plist"
o365Subbak2="$o365Product/e0E2OUQxNUY1LTAxOUQtNDQwNS04QkJELTAxQTI5M0JBOTk4O" # hidden file
o365SubmainB="$o365Product/com.microsoft.Office365V2.plist"
o365Subbak1B="$o365Product/com.microsoft.O4kTOBJ0M5ITQxATLEJkQ40SNwQDNtQUOxATL1YUNxQUO2E0e.plist"
o365Subbak2B="$o365Product/O4kTOBJ0M5ITQxATLEJkQ40SNwQDNtQUOxATL1YUNxQUO2E0e"
#Get the mailbox location of the logged in user (On-Premises/O365)
mailboxValue=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep "msExchRecipientDisplayType" | awk '{print $2}')
#Get the logged in users email address
userEmail=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep EMailAddress: | awk '{print $2}')
#Get the logged in users UPN
userUPN=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep "userPrincipalName" | awk '{print $2}')
#Domain
theDomain="bauer-uk.bauermedia.group"

########################################################################
#                         Script starts here                           #
########################################################################

#Confirm that a user is logged in
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
  echo "No one is home, exiting..."
  exit 0
fi

#Check that we can get to AD (required for the email address and UPN values)
domainPing=$(ping -c1 -W5 -q bauer-uk.bauermedia.group 2>/dev/null | head -n1 | sed 's/.*(\(.*\))/\1/;s/:.*//')
  if [[ "$domainPing" == "" ]]; then
    echo "$theDomain is not reachable so auto config and activation cannot complete"
    exit 0
  else
    echo "$theDomain is reachable, continuing..."
  fi

#Confirm that Office 365 for Mac is installed before continuing
  if [[ "$officeVersion" -ge "1617" ]]; then
    echo "Office 2019/365 for Mac installed"
  else
    echo "Office 2019/365 for Mac not installed, exiting..."
    exit 0
  fi

#Check to see if an O365 subscription license file is present
  if [[ -f "$o365Submain" || -f "$o365Subbak1" || -f "$o365Subbak2" || -f "$o365SubmainB" || -f "$o365Subbak1B" || -f "$o365Subbak2B" ]]; then
    echo "Office 2019/365 for Mac already activated for ${loggedInUser}, exiting..."
    exit 0
  else
    echo "Office 2019/365 for Mac not yet activated for ${loggedInUser}"
  fi

#Confirm that the logged in user in an O365 user
  if [[ "$mailboxValue" == "-1073741818" ]] || [[ "$mailboxValue" == "-2147483642" ]]; then
    echo "$loggedInUser is an Office 365 user, auto activating Office and configuring Outlook..."
      #Set the activation email address, turn auto activate on and set the default email address
      su -l "$loggedInUser" -c "defaults write com.microsoft.office OfficeActivationEmailAddress -string "$userUPN""
      su -l "$loggedInUser" -c "defaults write com.microsoft.office OfficeAutoSignIn -bool TRUE"
      su -l "$loggedInUser" -c "defaults write com.microsoft.Outlook DefaultEmailAddressOrDomain -string "$userEmail""
      #Set the first run setup keys for all Office apps to false (required for auto activation/signin to work)
      su -l "$loggedInUser" -c "defaults write com.microsoft.Outlook kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
      su -l "$loggedInUser" -c "defaults write com.microsoft.Word kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
      su -l "$loggedInUser" -c "defaults write com.microsoft.Excel kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
      su -l "$loggedInUser" -c "defaults write com.microsoft.onenote.mac kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
      su -l "$loggedInUser" -c "defaults write com.microsoft.Powerpoint kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
  elif [[ "$mailboxValue" == "1073741824" ]]; then
    echo "$loggedInUser is an On-Premises user, exiting..."
    exit 0
  else
    echo "Mailbox details not found, exiting..."
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
