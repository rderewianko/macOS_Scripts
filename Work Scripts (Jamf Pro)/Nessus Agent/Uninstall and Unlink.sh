#!/bin/bash

########################################################################
#          Uninstall and Unlink the Nessus Agent (Radar Services)      #
################### Written by Phil Walker May 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

nessusCLI="/Library/NessusAgent/run/sbin/nessuscli"
computerName=$(scutil --get HostName)
domain="YourDomain"
group="GroupName"
key="Key"
host="ServerHostName"
port="Port"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "/Library/NessusAgent" ]]; then
    echo "Nessus agent is installed"
    # Unlink the agent from the server
    "$nessusCLI" agent unlink --key=$key --name=$computerName.$domain --groups=$group --host=$host.$domain --port=$port >/dev/null 2>&1
    # Check if the unlink command was successful
    commandResult=$(echo "$?")
    if [[ "$commandResult" -eq "0" ]]; then
        echo "$computerName has been successfully unlinked"
    elif [[ "$commandResult" -eq "2" ]]; then
        echo "No host information found, unlink not required"
    else
        echo "Failed to unlink $computerName"
        exit 1
    fi
    # Stop all Nessus processes before removing the binary files
    if [[ $(ps aux | grep -v grep | grep "nessus-service") != "" ]]; then
        pkill HUP nessus-service
        sleep 2
        if [[ $(ps aux | grep -v grep | grep "nessus-service") == "" ]]; then
            echo "Nessus service stopped"
        else
            echo "Failed to stop Nessus service"
            exit 1
        fi
    else
        echo "Nessus service not found"
    fi
    # Remove Nessus agent binaries and associated files from the Mac
    rm -rf "/Library/NessusAgent" 2>/dev/null
    rm -rf "/Library/PreferencePanes/Nessus Agent Preferences.prefPane" 2>/dev/null
    rm -rf "/Library/LaunchDaemons/com.tenablesecurity.nessusagent.plist" 2>/dev/null
    rm -rf "/private/etc/tenable_tag" 2>/dev/null
    rm -rf "/private/var/db/receipts/com.tenablesecurity.*" 2>/dev/null
    echo "All Nessus binaries and associated files have been removed"
    echo "This Mac is no longer reporting to RIC"
else
    echo "Nessus agent is not installed"
fi

exit 0