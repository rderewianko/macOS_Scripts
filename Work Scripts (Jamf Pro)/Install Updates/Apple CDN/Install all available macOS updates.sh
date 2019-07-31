#!/bin/bash

########################################################################
#             Install all available macOS updates (Apple CDN)          #
########### Written by Phil Walker and Suleyman Twana July 2019 ########
########################################################################

#This script is designed to be used with JamfPro
#A check for updates policy will call this script via a custom trigger

macOSUpdate=$(softwareupdate -l | grep -i "macOS" | sed -n 1p | sed -e 's/*//g' -e 's/^[ \t]*//')
macOSUpdateShort=$(echo $macOSUpdate | sed 's/.$//')

# Check Apple CDN for latest macOS updates and download them
	softwareupdate --download "$macOSUpdate"

# Confirm download was successful
DownloadPath=$(find /Library/Updates -type f -name "*macOS*" | grep -i ".pkg" | wc -l)

if [[ "$DownloadPath" -ge "1" ]]; then
	echo "Updates downloaded successfully, starting install of ${macOSUpdateShort}..."

	softwareupdate --install "$macOSUpdate"

fi

exit 0
