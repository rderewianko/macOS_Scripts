#!/bin/bash

##########################################################################
#This Extension Attribute finds if the logged in user in 365 or on premise
##########################################################################

#Set the AD attribute number for key msExchRecipientDisplayType that correspond to where a mailbox is hosted.
user365="-1073741818"
userOnPRem="1073741824"

#Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

# If nobody's home do nothing.
if [ "$LoggedInUser" == "" ]; then
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
  mailboxValue=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$LoggedInUser | grep "msExchRecipientDisplayType" | awk '{print$2}')

  #Check the value from AD against the known values for mailbox location and echo back the result
  if [[ "$mailboxValue" == "$user365" ]]; then
    echo "<result>365 Mailbox</result>"
  elif [[ "$mailboxValue" == "$userOnPRem" ]]; then
    echo "<result>On Premise Mailbox</result>"
  else
    echo "<result>Mailbox details not found</result>"
  fi
fi
