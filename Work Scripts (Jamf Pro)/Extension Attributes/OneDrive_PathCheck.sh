#!/bin/bash

########################################################################
#                     OneDrive Sync Directory Path                     #
################### written by Phil Walker May 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#AD attribute number for key msExchRecipientDisplayType that correspond to where a mailbox is hosted
user365="-1073741818"
userOnPrem="1073741824"
#OneDrive folder paths. Previous and latest path.
OldFolderPath="/Users/"${LoggedInUser}"/OneDrive - Bauer Group"
NewFolderPath="/Users/"${LoggedInUser}"/OneDrive - Bauer Media Group"

########################################################################
#                            Functions                                 #
########################################################################

function oneDriveFolderPath()
{
#Return the OneDrive sync path/paths
if [[ -d "$OldFolderPath" ]] && [[ ! -d "$NewFolderPath" ]]; then

  echo "<result>Bauer Group</result>"

    elif [[ ! -d "$OldFolderPath" ]] && [[ -d "$NewFolderPath" ]]; then

      echo "<result>Bauer Media Group</result>"

    elif [[ -d "$OldFolderPath" ]] && [[ -d "$NewFolderPath" ]]; then

      echo "<result>Bauer Group and Bauer Media Group</result>"

else

    echo "<result>OneDrive not configured</result>"

fi

}

########################################################################
#                         Script starts here                           #
########################################################################

#Check if a user is logged in, if not do nothing

if [ "$LoggedInUser" == "" ]; then

  echo "<result>No logged in user</result>"

  exit 0

else

#Get the value of msExchRecipientDisplayType
mailboxValue=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$LoggedInUser | grep "msExchRecipientDisplayType" | awk '{print$2}')
  if [[ "$mailboxValue" == "$userOnPrem" ]]; then
    echo "<result>On Premise Mailbox</result>"
  else
    oneDriveFolderPath
  fi
fi

exit 0
