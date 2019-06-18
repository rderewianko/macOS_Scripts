#!/bin/bash

########################################################################
#                Remove admin accounts from FileVault                  #
################## Written by Phil Walker June 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
# Get the OS version
OSShort=$(sw_vers -productVersion | awk -F. '{print $2}')
OSFull=$(sw_vers -productVersion)
# FileVault status
fileVaultStatus=$(/usr/bin/fdesetup status | grep "FileVault" | head -n 1)
# Count FileVault users
fvUserCount=$(/usr/bin/fdesetup list | wc -l)

########################################################################
#                         Script starts here                           #
########################################################################

# Check FileVault is on
if [[ "$fileVaultStatus" != "FileVault is On." ]]; then
	echo "FileVault disabled, exiting..."
  exit 0
else
  echo "FileVault enabled"
fi

# Check there is more than one FileVault enabled user
if [[ "$fvUserCount" -le "1" ]]; then
  echo "Only one FileVault enabled user found, exiting..."
  exit 0
else
  echo "More than one FileVault enabled user found"
fi

fvUsersList=$(/usr/bin/fdesetup list | sed 's/,.*//g')
# List all FileVault users
echo ""
echo "FileVault users"
echo "---------------"
echo "$fvUsersList"
echo ""

# Check if any FileVault enabled user has admin in their username
if [[ "$fvUsersList" =~ "admin" ]]; then
  echo "FileVault enabled admin user found"
  echo "Removing all FileVault enabled admin users..."
  echo ""
else
  echo "No FileVault enabled admin users found, nothing to do"
  exit 0
fi

# Loop through FileVault users and remove any that have admin in the username
for fvuser in $fvUsersList
	do
    if [[ "$fvuser" = *"admin"* ]]; then
        fdesetup remove -user "$fvuser"
        	if [[ $? -eq "0" ]]; then
						echo "Removed $fvuser from FileVault"
					fi
      fi
done

# List all FileVault users again
fvUsersList=$(/usr/bin/fdesetup list | sed 's/,.*//g')
echo ""
echo "FileVault users"
echo "---------------"
echo "$fvUsersList"

# Update preBoot if required
if [[ "$OSShort" -ge "13" ]]; then
  echo ""
  echo "Mac running macOS ${OSFull}, updating preBoot..."
  	sleep 5
  	diskutil quiet apfs updatepreBoot /
  echo "preBoot updated"
fi

exit 0
