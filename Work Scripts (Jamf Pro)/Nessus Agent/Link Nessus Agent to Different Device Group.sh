#!/bin/bash

########################################################################
#            Link Nessus Agent to Different Device Group               #
################## Written by Phil Walker June 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

nessusCLI="/Library/NessusAgent/run/sbin/nessuscli"
computerName=$(scutil --get HostName)
domain="Your Domain"
group="Device Group"
key="The Key"
host="The Host"
port="The Port"

########################################################################
#                         Script starts here                           #
########################################################################

# First unlink the agent
if [[ -e "$nessusCLI" ]]; then
    "$nessusCLI" agent unlink >/dev/null 2>&1
    # Check if the unlink command was successful (0=success/2=no host info found)
    unlinkResult="$?"
    if [[ "$unlinkResult" -eq "0" ]]; then
        echo "$computerName has been successfully unlinked"
    elif [[ "$unlinkResult" -eq "2" ]]; then
        echo "No host information found, unlink not required"
    else
        echo "Failed to unlink $computerName"
        exit 1
    fi
fi

# Link the agent to the correct group
"$nessusCLI" agent link --key="$key" --name="$computerName"."$domain" --groups="$group" --host="$host"."$domain" --port="$port" >/dev/null 2>&1
linkResult="$?"
# Check if the computer is now successfully linked
if [[ "$linkResult" -eq "0" ]]; then
    echo "$computerName has been successfully linked to $host.$domain"
    echo "Device Group: $group"
else
    echo "Failed to link $computerName to $host.$domain"
    exit 1
fi
exit 0
