#!/bin/bash

########################################################################
#  Auto activate Office 2019/365 and auto configure Outlook 2019/365   #
################# Written by Phil Walker August 2019 ###################
########################################################################

#Designed to be used on a login trigger running once per user per computer

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Get the mailbox location (On-Premises/O365)
mailboxValue=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep "msExchRecipientDisplayType" | awk '{print$2}')
#Get the Office version to confirm its 2019
officeVersion=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' /Applications/Microsoft\ Outlook.app/Contents/Info.plist | sed -e 's/\.//g' | cut -c1-4)
#Get the logged in users email address
userEmail=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep EMailAddress: | awk '{print $2}')
#Get the logged in users UPN
userUPN=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep "userPrincipalName" | awk '{print $2}')
#Domain
theDomain="bauer-uk.bauermedia.group"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
  echo "No one is home, exiting..."
  exit 0
fi

#First check if we can get to AD
domainPing=$(ping -c1 -W5 -q bauer-uk.bauermedia.group 2>/dev/null | head -n1 | sed 's/.*(\(.*\))/\1/;s/:.*//')
if [[ "$domainPing" == "" ]]; then
  echo "$theDomain is not reachable so auto config and activation cannot complete"
  exit 0
else
  echo "$theDomain is reachable, continuing..."
fi

#If there is a logged in user, confirm that Office 2019 is installed before continuing
if [[ "$officeVersion" -ge "1617" ]]; then
  echo "Office 2019 installed, checking if $loggedInUser is an Office 365 user..."
      if [[ "$mailboxValue" == "-1073741818" ]]; then
        echo "$loggedInUser is an Office 365 user, auto activating Office and configuring Outlook..."

          su -l "$loggedInUser" -c "defaults write com.microsoft.office OfficeActivationEmailAddress -string "$userUPN""
          su -l "$loggedInUser" -c "defaults write com.microsoft.office OfficeAutoSignIn -bool TRUE"
          su -l "$loggedInUser" -c "defaults write com.microsoft.Outlook DefaultEmailAddressOrDomain -string "$userEmail""
          su -l "$loggedInUser" -c "defaults write com.microsoft.Outlook kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
          su -l "$loggedInUser" -c "defaults write com.microsoft.Word kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
          su -l "$loggedInUser" -c "defaults write com.microsoft.Excel kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
          su -l "$loggedInUser" -c "defaults write com.microsoft.onenote.mac kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"
          su -l "$loggedInUser" -c "defaults write com.microsoft.Powerpoint kSubUIAppCompletedFirstRunSetup1507 -bool FALSE"

      else
        echo "$loggedInUser is an On-Premises user, nothing to do"
        exit 0

      fi
fi

#Confirm the first run reset has been completed successfully
OutlookFirstRun=$(su -l "$loggedInUser" -c "defaults read com.microsoft.Outlook kSubUIAppCompletedFirstRunSetup1507")
if [[ "$OutlookFirstRun" == "0" ]] || [[ "$OutlookFirstRun" == "false" ]]; then
  echo "First run status reset"
else
  echo "First run completed, Office may need to be manually activated"
fi

#Confirm the changes have been made successfully
if [[ $(su -l "$loggedInUser" -c "defaults read com.microsoft.office OfficeActivationEmailAddress") == "$userUPN" ]]; then
  echo "Office activation email set to $userUPN"
else
  echo "Office activation email not set"
fi

officeAutoSignIn=$(su -l "$loggedInUser" -c "defaults read com.microsoft.office OfficeAutoSignIn")
if [[ "$officeAutoSignIn" == "1" ]] || [[ "$officeAutoSignIn" == "true" ]]; then
  echo "Office auto sign in enabled"
else
  echo "Office auto sign not enabled"
fi

if [[ $(su -l "$loggedInUser" -c "defaults read com.microsoft.Outlook DefaultEmailAddressOrDomain -string "$userEmail"") == "$userEmail" ]]; then
  echo "Outlook default email address set to $userEmail"
else
  echo "Outlook default email address not set"
fi

exit 0
