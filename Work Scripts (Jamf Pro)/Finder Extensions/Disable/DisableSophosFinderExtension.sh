#!/bin/bash

########################################################################
#                  Disable Sophos Finder Extension                     #
################## Written by Phil Walker June 2020 ####################
########################################################################

# Method below was just a POC. Method used in production was a Config Profile

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Sophos Application
sophosEndpoint="/Applications/Sophos Endpoint.app"
# Sophos Finder Extension status
currentExtStatus=$(sudo -u "$loggedInUser" /usr/bin/pluginkit -m -i "com.sophos.endpoint.uiserver.FinderScan")

########################################################################
#                            Functions                                 #
########################################################################

function addSophosExtension ()
{
# Add the extension
sudo -u "$loggedInUser" /usr/bin/pluginkit -a "/Library/Sophos Anti-Virus/Sophos Endpoint UIServer.app/Contents/PlugIns/FinderScan.appex"
# Check its been added
checkExtAdded=$(sudo -u "$loggedInUser" /usr/bin/pluginkit -m -i "com.sophos.endpoint.uiserver.FinderScan")
if [[ "$checkExtAdded" != "" ]]; then
    echo "Sophos Finder Extension added successfully"
else
    echo "Failed to add Sophos Finder Extension"
    echo "Only method to disable is manually via the GUI"
    exit 1
fi
}

function disableSophosExtension ()
{
echo "Disabling Sophos Finder Extension for ${loggedInUser}..."
sudo -u "$loggedInUser" /usr/bin/pluginkit -e ignore -i "com.sophos.endpoint.uiserver.FinderScan"
sleep 2
#re-populate variable
checkExtDisabled=$(sudo -u "$loggedInUser" /usr/bin/pluginkit -m -i "com.sophos.endpoint.uiserver.FinderScan")
if [[ "$checkExtDisabled" =~ "-" ]]; then
    echo "Sophos Finder Extension Disabled"
else
    echo "Failed to disable Sophos Finder Extension"
    exit 1
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in"
    echo "Policy must run on login to disable the extension as the logged in user"
    exit 1
else
    if [[ -d "$sophosEndpoint" ]]; then
        echo "Sophos Endpoint installed"
        if [[ "$currentExtStatus" =~ "-" ]]; then
            echo "Sophos Finder Extension already disabled"
            # Make sure the OneDrive Finder Extension is enabled
            echo "Enabling OneDrive Finder Extension..."
            sudo -u "$loggedInUser" /usr/bin/pluginkit -e use -i "com.microsoft.OneDrive.FinderSync"
            echo "OneDrive Finder Extension Enabled"
        elif [[ "$currentExtStatus" == "" ]]; then
            echo "Sophos Finder Extension not found in the plug-in database"
            echo "Adding Sophos Finder Extension to enable the ability to manage it"
            addSophosExtension
            disableSophosExtension
            echo "Enabling OneDrive Finder Extension..."
            # Make sure the OneDrive Finder Extension is enabled
            sudo -u "$loggedInUser" /usr/bin/pluginkit -e use -i "com.microsoft.OneDrive.FinderSync"
            echo "OneDrive Finder Extension Enabled"
        elif [[ "$currentExtStatus" =~ "-" ]]; then
            echo "Sophos Finder Extension already disabled"
        else
            disableSophosExtension
            echo "Enabling OneDrive Finder Extension..."
            # Make sure the OneDrive Finder Extension is enabled
            sudo -u "$loggedInUser" /usr/bin/pluginkit -e use -i "com.microsoft.OneDrive.FinderSync"
            echo "OneDrive Finder Extension Enabled"
        fi
    else
        echo "Sophos Endpoint not installed"
        exit 1
    fi
fi

exit 0