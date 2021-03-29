#!/bin/zsh

########################################################################
#                   Register Microsoft AutoUpdate                      #
################## Written by Phil Walker Apr 2020 #####################
########################################################################

# Thanks to P Bowden for the info (https://github.com/pbowden-msft/RegMAU/blob/master/RegMAU)
# Registers the MAU application in the Launch Services database
# Must be run on a per user basis

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
# lsregister - command to query and manage the Launch Services database
lsRegister="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
# Microsoft AutoUpdate Application
mauApp="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"
# Microsoft AutoUpdate Assistant
mauAssistant="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft Update Assistant.app"

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

function postCheck ()
{
# Confirm MAU has been registered successfully
checkMAU=$(runAsUser "$lsRegister" -dump | grep "$mauApp" | grep -v "Contents")
checkMAUAssistant=$(runAsUser "$lsRegister" -dump | grep "$mauAssistant")
if [[ "$checkMAU" != "" ]] && [[ "$checkMAUAssistant" != "" ]]; then
     echo "Microsoft AutoUpdate registered successfully for $loggedInUser"
else
     echo "Failed to register Microsoft AutoUpdate for $loggedInUser"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Confirm Microsoft AutoUpdate is installed
if [[ -d "$mauApp" ]]; then
     echo "Registering Microsoft AutoUpdate for $loggedInUser..."
     runAsUser "$lsRegister" -R -f -trusted "$mauApp"
     runAsUser "$lsRegister" -R -f -trusted "$mauAssistant"
     postCheck
else
     echo "Microsoft AutoUpdate not found"
     echo "Please install Microsoft Office for Mac and run this again"
fi
exit 0