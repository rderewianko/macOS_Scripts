#!/bin/bash

########################################################################
#  Reset Camera/Microphone/Screen Recording Privacy Consent Decisions  #
#################### Written by Phil Walker Apr 2020 ###################
########################################################################

# Self Service script

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "" ]]; then
    echo "No user logged in, exiting..."
    exit 0
else
    # Close System Preferences
    killall "System Preferences" >/dev/null 2>&1
    # Reset privacy consent for Camera, Microphone and Screen Recording
    su -l "$loggedInUser" -c "tccutil reset Camera"
    su -l "$loggedInUser" -c "tccutil reset Microphone"
    su -l "$loggedInUser" -c "tccutil reset ScreenCapture"
fi

exit 0