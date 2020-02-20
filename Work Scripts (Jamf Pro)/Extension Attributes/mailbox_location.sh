#!/bin/bash

##########################################################################
#This Extension Attribute finds if the logged in user in 365 or on premise
##########################################################################

#Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)

# If nobody's home do nothing.
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
  echo "<result>No logged in user</result>"
  exit 0
else
  #User logged in carry on but check if we can get to AD
  domainPing=$(ping -c1 -W5 -q bauer-uk.bauermedia.group 2>/dev/null | head -n1 | sed 's/.*(\(.*\))/\1/;s/:.*//')
  if [[ "$domainPing" == "" ]]; then
    echo "<result>Domain not reachable</result>"
    exit 0
  fi
  #Get the value of msExchRecipientDisplayType
  mailboxValue=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$loggedInUser | grep "msExchRecipientDisplayType" | awk '{print$2}')

  #Check the value from AD against the known values for mailbox location and echo back the result
  if [[ "$mailboxValue" == "-1073741818" ]] || [[ "$mailboxValue" == "-2147483642" ]]; then
    echo "<result>365 Mailbox</result>"
  elif [[ "$mailboxValue" == "1073741824" ]]; then
    echo "<result>On Premise Mailbox</result>"
  else
    echo "<result>Mailbox details not found</result>"
  fi
fi
