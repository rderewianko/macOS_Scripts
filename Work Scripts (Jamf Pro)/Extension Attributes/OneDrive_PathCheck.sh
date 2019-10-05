#!/bin/bash

########################################################################
#                      OneDrive Sync Folder Path                       #
################### written by Phil Walker May 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#AD attribute number for key msExchRecipientDisplayType that correspond to where a mailbox is hosted
user365="-1073741818"
userOnPrem="1073741824"
#OneDrive folder paths. Previous and latest path.
oldFolderPath="/Users/"${loggedInUser}"/OneDrive - Bauer Group"
newFolderPath="/Users/"${loggedInUser}"/OneDrive - Bauer Media Group"

########################################################################
#                            Functions                                 #
########################################################################

function oneDriveFolderPath()
{
#Return the OneDrive sync path/paths
if [[ -d "$oldFolderPath" ]] && [[ ! -d "$newFolderPath" ]]; then
  echo "<result>Bauer Group</result>"
    elif [[ ! -d "$oldFolderPath" ]] && [[ -d "$newFolderPath" ]]; then
      echo "<result>Bauer Media Group</result>"
    elif [[ -d "$oldFolderPath" ]] && [[ -d "$newFolderPath" ]]; then
      echo "<result>Bauer Group and Bauer Media Group</result>"
else
    echo "<result>OneDrive not configured</result>"
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

#Check if a user is logged in, if not do nothing
if [ "$loggedInUser" == "" ]; then
  echo "<result>No logged in user</result>"
  exit 0
else
  #User logged in carry on but check if we can get to AD first
  domainPing=$(ping -c1 -W5 -q bauer-uk.bauermedia.group 2>/dev/null | head -n1 | sed 's/.*(\(.*\))/\1/;s/:.*//')
  if [[ "$domainPing" == "" ]]; then
    echo "<result>Domain not reachable</result>"
    exit 0
  fi
#Get the value of msExchRecipientDisplayType
mailboxValue=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep "msExchRecipientDisplayType" | awk '{print$2}')
  if [[ "$mailboxValue" == "$userOnPrem" ]]; then
    echo "<result>On Premise Mailbox</result>"
  else
    oneDriveFolderPath
  fi
fi

exit 0
