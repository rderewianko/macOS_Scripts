#!/bin/zsh

########################################################################
#             Turn Natural Mouse Scroll Direction Off                  #
##################### Written by Phil Walker ###########################
########################################################################
# If a change is made it does not apply until the next logon session

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

function preCheck ()
{
# Read the value set for com.apple.swipescrolldirection
scrollPref=$(/usr/libexec/PlistBuddy -c "print com.apple.swipescrolldirection" /Users/"$loggedInUser"/Library/Preferences/.GlobalPreferences.plist 2>/dev/null)
if [[ "$scrollPref" == "false" ]]; then
    echo "Natural Mouse scroll direction already turned off, nothing to do"
    exit 0
else
    echo "Mouse scroll direction currently set to Natural, turning setting off..."
fi
}

function postCheck ()
{
# Read the value set for com.apple.swipescrolldirection
scrollPref=$(/usr/libexec/PlistBuddy -c "print com.apple.swipescrolldirection" /Users/"$loggedInUser"/Library/Preferences/.GlobalPreferences.plist 2>/dev/null)
# Confirm that the value has been set successfully
if [[ "$scrollPref" == "false" ]]; then
    echo "Natural Mouse scroll direction successfully turned off"
else
    echo "Failed to change Mouse scroll direction!"
    echo "Mouse scroll direction set to Natural"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Confirm that a user is logged in
if [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    echo "No one is home, exiting..."
    exit 1
else
    # Check to see if a change needs to be made
    preCheck
    # Set Natural scroll direction to false
    runAsUser defaults write .GlobalPreferences com.apple.swipescrolldirection -bool false
    # Check the change has been implemented successfully
    postCheck
    # Kill System Preferences so that the change displays correctly
    pkill "System Preferences"
fi
exit 0