#!/bin/bash

########################################################################
#    Find Jamf Pro Super User/Admin Accounts - Extension Attribute     #
################# Written by Phil Walker August 2019 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#List all members of the jamf pro super users AD security group
casperSuperUsers=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read "/Groups/rol-adm-uk-casper_superusers" member | awk -F 'CN=|,' '{print $2}' | tail -n +2)
#List all members of the jamf pro admin users AD security group
casperAdmins=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read "/Groups/rol-adm-uk-casper_admins" member | awk -F 'CN=|,' '{print $2}' | tail -n +2)
#List all user accounts
allUsers=$(dscl . -list /Users | grep -v "^_\|casadmin\|daemon\|nobody\|root")
#Check domain is accessible
domainPing=$(ping -c1 -W5 -q bauer-uk.bauermedia.group 2>/dev/null | head -n1 | sed 's/.*(\(.*\))/\1/;s/:.*//')

########################################################################
#                         Script starts here                           #
########################################################################

#If the domain is not accessible return nothing
if [[ "$domainPing" == "" ]]; then
  echo "<result></result>"
  exit 0

else
#Check if any local user is a member of either Jamf Pro admin user security groups
  for user in $allUsers
    do
      userRealName=$(dscl . -read /Users/$user | grep -A1 "RealName:" | sed -n '2p' | awk '{print $1, $2, $3}' | sed -e s/,// -e 's/ *$//')
      if [[ "$userRealName" =~ "Admin" ]]; then
        if [[ "$casperSuperUsers" =~ "$userRealName" ]]; then
          echo "$userRealName" >> /var/tmp/ITAdminAccounts.txt
        elif [[ "$casperAdmins" =~ "$userRealName" ]]; then
          echo "$userRealName" >> /var/tmp/ITAdminAccounts.txt
        fi
      fi
  done
  echo "<result>$(cat /var/tmp/ITAdminAccounts.txt)</result>"
fi

rm -f /var/tmp/ITAdminAccounts.txt 2>/dev/null

exit 0
