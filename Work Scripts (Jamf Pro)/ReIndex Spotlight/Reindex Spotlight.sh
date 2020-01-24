#!/bin/bash

# This script is designed to fix Spotlight indexing issues
# by removing the existing Spotlight index and forcing Spotlight
# to create a new search index.
# Edited by Phil Walker Jan 2020

########################################################################
#                            Variables                                 #
########################################################################

#Metadata server launch daemon PID
launchDPID1=$(launchctl list | grep "com.apple.metadata.mds" | grep -v "index\|scan\|spindump" | awk '{print $1}')

########################################################################
#                         Script starts here                           #
########################################################################

# Turn Spotlight indexing off

/usr/bin/mdutil -i off / >/dev/null 2>&1

# Display Spotlight status

/usr/bin/mdutil -s / | sed -n '2p' | xargs | tr -d '.'

# Delete the Spotlight folder on the root level of the boot volume

/bin/rm -rf /.Spotlight*

# Confirm Spotlight folder has been deleted

if [[ ! -d "/.Spotlight-V100" ]]; then
  echo "Spotlight folder deleted successfully"
else
  echo "Spotlight folder still present"
fi

# Turn Spotlight indexing on and erase the current local store

/usr/bin/mdutil -i on / >/dev/null 2>&1

# Erase the current local store

/usr/bin/mdutil -E / >/dev/null 2>&1

# Display Spotlight status

sleep 2

/usr/bin/mdutil -s / | sed -n '2p' | xargs | tr -d '.'

# Restart Spotlight service

launchctl kickstart -k system/com.apple.metadata.mds

launchDPID2=$(launchctl list | grep "com.apple.metadata.mds" | grep -v "index\|scan\|spindump" | awk '{print $1}')

#Wait for the spotlight service to be restarted before continuing
while [[ "$launchDPID1" -eq "$launchDPID2" ]]; do
  echo "Spotlight service being restarted..."
  sleep 1;
done
echo "Spotlight service restarted"

exit 0
