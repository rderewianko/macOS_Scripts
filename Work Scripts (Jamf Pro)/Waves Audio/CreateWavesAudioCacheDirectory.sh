#!/bin/bash

########################################################################
#          Waves Central - Create Waves Audio Cache Directory          #
#################### Written by Phil Walker May 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Waves Audio cache directory
wavesAudioCache="/Users/$loggedInUser/Library/Caches/Waves Audio"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
	echo "No user currently logged in, exiting..."
else
    if [[ ! -d "$wavesAudioCache" ]]; then
        sudo -u "$loggedInUser" mkdir "$wavesAudioCache"
        if [[ -d "$wavesAudioCache" ]]; then
            echo "Waves Audio cache directory created for ${loggedInUser}"
        else
            echo "Failed to create Waves Audio cache directory, Waves Central will prompt for admin on first launch"
        fi
    else
        echo "Waves Audio cache directory for ${loggedInUser} found, nothing to do"
        exit 0
    fi
fi

exit 0
