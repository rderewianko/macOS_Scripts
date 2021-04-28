#!/bin/zsh

########################################################################
#                 Uninstall NoMAD Login AD Auth Check                  #
################### Written by Phil Walker Apr 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# NoMAD Login AD auth check Launch Daemon
launchDaemon="/Library/LaunchDaemons/com.bauer.NoMADLoginAD.AuthCheck.plist"
# NoMAD Login AD auth check script
noLoADScript="/usr/local/bin/NoMADLoginAD_AuthCheck.sh"

########################################################################
#                            Functions                                 #
########################################################################

function launchDaemonStatus()
{
# Get the status of the Launch Daemon
checkLaunchD=$(launchctl list | grep "NoMADLoginAD.AuthCheck" | awk '{print $3}')
if [[ "$checkLaunchD" == "com.bauer.NoMADLoginAD.AuthCheck" ]]; then
    echo "NoMAD Login AD auth check Launch Daemon currently boostrapped"
    echo "Booting out the Launch Daemon..."
    launchctl bootout system "$launchDaemon"
    sleep 2
else
    echo "NoMAD Login AD auth check Launch Daemon not bootstrapped"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# If the Launch Daemon already exists, bootout and delete
if [[ -f "$launchDaemon" ]]; then
    launchDaemonStatus
    rm -f "$launchDaemon"
    if [[ ! -f "$launchDaemon" ]]; then
        echo "Launch Daemon booted out and deleted"
    else
        echo "Launch Daemon deletion FAILED!"
    fi
fi
# If the script used by the Launch Daemon already exists, delete it
if [[ -f "$noLoADScript" ]]; then
    rm -f "$noLoADScript"
    if [[ ! -f "$noLoADScript" ]]; then
        echo "NoMAD Login AD auth check script deleted successfully"
    else
        echo "NoMAD Login AD auth check script deletion FAILED!"
    fi
fi
exit 0