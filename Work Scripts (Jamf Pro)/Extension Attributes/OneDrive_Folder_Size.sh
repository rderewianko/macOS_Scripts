#!/bin/bash

# Set the AD attribute number for key msExchRecipientDisplayType that correspond to where a mailbox is hosted

user365="-1073741818"
userOnPrem="1073741824"

# Get the logged in user

LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

function oneDriveFolderPath()
{
#Return the OneDrive sync path

#OneDrive folder paths. Previous and latest path.
OldFolderPath="/Users/${LoggedInUser}/OneDrive - Bauer Group"
NewFolderPath="/Users/${LoggedInUser}/OneDrive - Bauer Media Group"

if [[ -d "$OldFolderPath" ]] && [[ ! -d "$NewFolderPath" ]]; then

    OneDrivePath=$OldFolderPath

else

    OneDrivePath=$NewFolderPath

fi

}

# If nobody's home do nothing.

	if [ "$LoggedInUser" == "" ]; then

  	echo "<result>No logged in user</result>"

exit 0

else

# Get the value of msExchRecipientDisplayType

  mailboxValue=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$LoggedInUser | grep "msExchRecipientDisplayType" | awk '{print$2}')

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
