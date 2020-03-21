#!/bin/sh

########################################################################
#    Automatically Install All Adobe CC Application Updates Package    #
#                         preinstall script                            #                        
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Launch Agent
launchAgent=/Library/LaunchAgents/com.bauer.AdobeRUM.LoginWindow.plist
#Launch Daemon
LaunchDaemon=/Library/LaunchDaemons/com.bauer.AdobeRUM.plist
#Auto update script
updateScript=/usr/local/bin/AutoInstallAdobeCCUpdates.sh

########################################################################
#                         Script starts here                           #
########################################################################

#Stop and unload the Launch Daemon
launchctl stop "$LaunchDaemon" 2>/dev/null
launchctl unload "$LaunchDaemon" 2>/dev/null
#Stop and unload the Launch Agent
launchctl stop "$launchAgent" 2>/dev/null
launchctl unload "$launchAgent" 2>/dev/null

if [[ -e "$launchAgent" || -e "$LaunchDaemon" || -e "$updateScript" ]]; then
    echo "Previous content found"
    echo "Removing previous launch agent, daemon and script"
    rm -f "$launchAgent" 2>/dev/null
    rm -f "$LaunchDaemon" 2>/dev/null
    rm -f "$updateScript" 2>/dev/null
        if [[ ! -e "$launchAgent" && ! -e "$LaunchDaemon" && ! -e "$updateScript" ]]; then
            echo "Previous content deleted successfully"
        else
            echo "clean up FAILED!"
        fi
else
    echo "Previous content not found"
    echo "Nothing to do"
fi

exit 0