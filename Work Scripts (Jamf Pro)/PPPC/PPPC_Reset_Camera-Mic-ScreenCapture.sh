#!/bin/zsh

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
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

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
    runAsUser tccutil reset Camera
    runAsUser tccutil reset Microphone
    runAsUser tccutil reset ScreenCapture
fi

exit 0