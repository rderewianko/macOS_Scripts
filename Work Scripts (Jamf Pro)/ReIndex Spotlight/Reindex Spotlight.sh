#!/bin/zsh

########################################################################
#                         Reindex Spotlight                            #
################## Written by Phil Walker Jan 2020 #####################
########################################################################

# This script is designed to fix Spotlight indexing issues
# by removing the existing Spotlight index and forcing Spotlight
# to create a new search index.
# Edited by Phil Walker June 2021 for macOS Catalina or later only

########################################################################
#                            Variables                                 #
########################################################################

# Metadata server launch daemon process ID
launchDPID1=$(launchctl list | grep "com.apple.metadata.mds" | grep -v "index\|scan\|spindump" | awk '{print $1}')
# Spotlight database
spotlightDB="/System/Volumes/Data/.Spotlight-V100"

########################################################################
#                         Script starts here                           #
########################################################################

# Turn Spotlight indexing off
echo "Disabling indexing..."
mdutil -i off / &>/dev/null
# Display Spotlight status
mdutil -s / | sed -n '2p' | xargs | tr -d '.'
# Delete the Spotlight database on the root level of the boot volume
echo "Deleting the current Spotlight database..."
if [[ -d "$spotlightDB" ]]; then
    rm -rf "$spotlightDB"
    # Confirm Spotlight database has been deleted
    if [[ ! -d "$spotlightDB" ]]; then
        echo "Spotlight database deleted"
    else
        echo "Spotlight database still present!"
    fi
else
    echo "Spotlight database not found!"
fi
# Turn Spotlight indexing on and erase the current local store
echo "Enabling indexing..."
mdutil -i on / &>/dev/null
mdutil -E / &>/dev/null
sleep 2
# Display Spotlight status
mdutil -s / | sed -n '2p' | xargs | tr -d '.'
# Restart Spotlight service
launchctl kickstart -k system/com.apple.metadata.mds
launchDPID2=$(launchctl list | grep "com.apple.metadata.mds" | grep -v "index\|scan\|spindump" | awk '{print $1}')
# Wait for the spotlight service to be restarted before continuing
while [[ "$launchDPID1" -eq "$launchDPID2" ]]; do
    echo "Spotlight service being restarted..."
    sleep 1;
done
echo "Spotlight service restarted"
exit 0