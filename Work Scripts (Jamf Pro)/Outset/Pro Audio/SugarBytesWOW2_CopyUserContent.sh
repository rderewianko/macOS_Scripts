#!/bin/zsh

########################################################################
#                  Copy Sugar Bytes WOW2 User Content                  #
#################### Written by Phil Walker Nov 2020 ###################
########################################################################
# To avoid using the User Template use outset to copy content for new users

# Requirements
# Outset (https://github.com/chilcote/outset)
# macOS 10.15+
# python 3.7+ (https://github.com/macadmins/python)

########################################################################
#                            Variables                                 #
########################################################################

# Logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Logged in users group
loggedInUserGroup=$(stat -f %Sg /dev/console)
# Logged in users home directory
loggedInUserHome=$(/usr/bin/dscl . -read /Users/"$loggedInUser" NFSHomeDirectory | awk '{print $2}')
# Path to Sugar Bytes WOW2 settings
wowSettings="/usr/local/ProAudioUserContent/Sugar Bytes/Documents/Sugar Bytes/WOW2"
# Logfile
logFile="/Library/Logs/Bauer/Outset/SugarBytesWOW2_UserContentCopy_${loggedInUser}.log"

########################################################################
#                         Script starts here                           #
########################################################################

# Create the log directory if required
if [[ ! -d "/Library/Logs/Bauer/Outset" ]]; then
    mkdir -p "/Library/Logs/Bauer/Outset"
fi
# Create the log file if required
if [[ ! -e "$logFile" ]]; then
    touch "$logFile"
fi
# redirect both standard output and standard error to the log
exec >> "$logFile" 2>&1
echo "Script started at: $(date +"%Y-%m-%d_%H-%M-%S")"
# Copy all user settings
if [[ -d "$wowSettings" ]]; then
    echo "------------------------------------------------------------"
    echo "Copying all Sugar Bytes WOW2 user content for ${loggedInUser}..."
    rsync -ruz --progress "$wowSettings" "${loggedInUserHome}/Documents/Sugar Bytes"
    chown -R "$loggedInUser":"$loggedInUserGroup" "${loggedInUserHome}/Documents/Sugar Bytes"
    echo "Permissions for ${loggedInUserHome}/Documents/Sugar Bytes set to ${loggedInUser}:${loggedInUserGroup}"
    echo "All Sugar Bytes WOW2 user content copied for ${loggedInUser}"
    echo "------------------------------------------------------------"
else
    echo "Sugar Bytes WOW2 user content not found, unable to complete copy"
    echo "Reinstall Sugar Bytes WOW2"
fi
echo "Script started at: $(date +"%Y-%m-%d_%H-%M-%S")"
exit 0