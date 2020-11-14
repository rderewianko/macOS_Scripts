#!/bin/zsh

########################################################################
#                   Copy Universal Audio User Content                  #
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
# Path to UAD Plugins
uadPlugins="/usr/local/ProAudioUserContent/Universal Audio/Documents/Pro Tools/Plug-In Settings"
# Path to UAD Presets
uadPresets="/usr/local/ProAudioUserContent/Universal Audio/Documents/Universal Audio"
# Path to UAD Preferences
uadPrefs="/usr/local/ProAudioUserContent/Universal Audio/Library/Preferences/Universal Audio"
# Logfile
logFile="/Library/Logs/Bauer/Outset/UniversalAudio_UserContentCopy_${loggedInUser}.log"

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
if [[ -d "/usr/local/ProAudioUserContent/Universal Audio" ]]; then
    echo "------------------------------------------------------------"
    echo "Copying all Universal Audio user content for ${loggedInUser}..."
    # Copy all user plugins
    rsync -ruz --progress "$uadPlugins" "${loggedInUserHome}/Documents/Pro Tools"
    chown -R "$loggedInUser":"$loggedInUserGroup" "${loggedInUserHome}/Documents/Pro Tools"
    echo "Permissions for ${loggedInUserHome}/Documents/Pro Tools set to ${loggedInUser}:${loggedInUserGroup}"
    # Copy all user presets
    rsync -ruz --progress "$uadPresets" "${loggedInUserHome}/Documents/Universal Audio"
    chown -R "$loggedInUser":"$loggedInUserGroup" "${loggedInUserHome}/Documents/Universal Audio"
    echo "Permissions for ${loggedInUserHome}/Documents/Universal Audio set to ${loggedInUser}:${loggedInUserGroup}"
    # Copy all user preferences
    rsync -ruz --progress "$uadPrefs" "${loggedInUserHome}/Library/Preferences"
    chown -R "$loggedInUser":"$loggedInUserGroup" "${loggedInUserHome}/Library/Preferences/Universal Audio"
    echo "Permissions for ${loggedInUserHome}/Library/Preferences/Universal Audio set to ${loggedInUser}:${loggedInUserGroup}"
    echo "All Universal Audio user content copied for ${loggedInUser}"
    echo "------------------------------------------------------------"
else
    echo "Universal Audio user content not found, unable to complete copy"
    echo "Reinstall UAD Software, Firmware and Plugins"
fi
echo "Script completed at: $(date +"%Y-%m-%d_%H-%M-%S")"
exit 0