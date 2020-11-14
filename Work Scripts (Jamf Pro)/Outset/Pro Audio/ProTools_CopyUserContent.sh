#!/bin/zsh

########################################################################
#                      Copy Pro Tools User Content                     #
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
# Path to Pro Tools settings
ptSettings="/usr/local/ProAudioUserContent/Pro Tools/Documents/Pro Tools"
# Path to FB360 Spatial Workstation
ptFBSpatial="/usr/local/ProAudioUserContent/Pro Tools/Library/Application Support/FB360 Spatial Workstation"
# Logfile
logFile="/Library/Logs/Bauer/Outset/ProTools_UserContentCopy_${loggedInUser}.log"

########################################################################
#                         Script starts here                           #
########################################################################

# Create the log directory if required
if [[ ! -d "/Library/Logs/Bauer/Outset/" ]]; then
    mkdir -p "/Library/Logs/Bauer/Outset/"
fi
# Create the log file if required
if [[ ! -e "$logFile" ]]; then
    touch "$logFile"
fi
# redirect both standard output and standard error to the log
exec >> "$logFile" 2>&1
echo "Script started at: $(date +"%Y-%m-%d_%H-%M-%S")"
# Copy all user settings
if [[ -d "/usr/local/ProAudioUserContent/Pro Tools" ]]; then
    echo "------------------------------------------------------------"
    echo "Copying all Pro Tools user content for ${loggedInUser}..."
    rsync -ruz --progress "$ptSettings" "${loggedInUserHome}/Documents"
    chown -R "$loggedInUser":"$loggedInUserGroup" "${loggedInUserHome}/Documents/Pro Tools"
    echo "Permissions for ${loggedInUserHome}/Documents/Pro Tools set to ${loggedInUser}:${loggedInUserGroup}"
    # Copy all user FB360 Spatial Workstation settings
    rsync -ruz --progress "$ptFBSpatial" "${loggedInUserHome}/Library/Application Support"
    chown -R "$loggedInUser":"$loggedInUserGroup" "${loggedInUserHome}/Library/Application Support/FB360 Spatial Workstation"
    echo "Permissions for ${loggedInUserHome}/Library/Application Support/FB360 Spatial Workstation set to ${loggedInUser}:${loggedInUserGroup}"
    echo "All Pro Tools user content copied for ${loggedInUser}"
    echo "------------------------------------------------------------"
else
    echo "Pro Tools user content not found, unable to complete copy"
    echo "Reinstall the Pro Tools Bundle"
fi
echo "Script completed at: $(date +"%Y-%m-%d_%H-%M-%S")"
exit 0