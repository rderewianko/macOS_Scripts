#!/bin/zsh

########################################################################
#             Turn Natural Mouse Scroll Direction Off                  #
##################### Written by Phil Walker ###########################
########################################################################
# If a change is made it does not apply until the next logon session

# Before any variables are defined or any actions are taken, complete a few checks
echo "Checking all requirements are met..."
# Check a normal user is logged in
loggedInUser=$(stat -f %Su /dev/console)
if [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    while [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; do
        sleep 2
        loggedInUser=$(stat -f %Su /dev/console)
    done
fi
# Check Finder is running
finderProcess=$(pgrep -x "Finder")
until [[ "$finderProcess" != "" ]]; do
    sleep 2
    finderProcess=$(pgrep -x "Finder")
done
# Check the Dock is running
dockProcess=$(pgrep -x "Dock")
until [[ "$dockProcess" != "" ]]; do
    sleep 2
    dockProcess=$(pgrep -x "Dock")
done
echo "All requirements met"

########################################################################
#                            Variables                                 #
########################################################################

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

# Check to see if a change needs to be made
preCheck
# Set Natural scroll direction to false
runAsUser defaults write .GlobalPreferences com.apple.swipescrolldirection -bool false
# Check the change has been implemented successfully
postCheck
# Kill System Preferences so that the change displays correctly
pkill "System Preferences"
exit 0