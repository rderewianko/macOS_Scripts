#!/bin/bash

########################################################################
#                      OneDrive Sync Folder Size                       #
################ written by Suleyman Twana & Phil Walker ###############
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
# Set the AD attribute number for key msExchRecipientDisplayType that correspond to where a mailbox is hosted
user365="-1073741818"
userOnPrem="1073741824"

########################################################################
#                            Functions                                 #
########################################################################

function oneDriveFolderPath()
{
#Return the OneDrive sync path

#OneDrive folder paths. Previous and latest path.
oldFolderPath="/Users/${loggedInUser}/OneDrive - Bauer Group"
newFolderPath="/Users/${loggedInUser}/OneDrive - Bauer Media Group"

if [[ -d "$oldFolderPath" ]] && [[ ! -d "$newFolderPath" ]]; then
    OneDrivePath=$oldFolderPath
else
    OneDrivePath=$newFolderPath
fi

}

# If nobody's home do nothing.
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
# Get the value of msExchRecipientDisplayType
  mailboxValue=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep "msExchRecipientDisplayType" | awk '{print$2}')
# Check the value from AD against the known values for mailbox location and echo back the result
  if [[ "$mailboxValue" == "$user365" ]]; then
    oneDriveFolderPath
# Get OneDrive folder size for the logged user
    FolderSize=$(du -hc "$OneDrivePath" | grep "total" | awk '{ print $1 }')
	echo "<result>$FolderSize</result>"
else
  if [[ "$mailboxValue" == "$userOnPrem" ]]; then
    echo "<result>On Premise Mailbox</result>"
	 fi
 fi
fi

exit 0
