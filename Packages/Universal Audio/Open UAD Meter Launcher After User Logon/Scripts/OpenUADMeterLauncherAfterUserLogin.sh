#!/bin/bash

########################################################################
#              Open UAD Meter Launcher after user login                #
################## Written by Phil Walker Jan 2020 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

appBundle="/Library/Application Support/Universal Audio/UAD Meter Launcher.app"

########################################################################
#                         Script starts here                           #
########################################################################

# Check if the UAD Meter Launcher application is installed
if [[ -d "$appBundle" ]]; then
# If found, launch the app
		echo "UAD Meter Launcher app found"
		open -F "$appBundle"
		sleep 2
# Confirm that the app was launched successfully
			if [[ $(ps -A | grep "UAD Meter & Control Panel" | grep -v grep) != "" ]]; then
				echo "UAD Meter Launcher launched successfully"
			else
				echo "Failed to launch UAD Meter Launcher"
				exit 1
			fi
else
# If not found, do nothing
		echo "UAD Meter Launcher app not found, nothing to do"
fi

exit 0
