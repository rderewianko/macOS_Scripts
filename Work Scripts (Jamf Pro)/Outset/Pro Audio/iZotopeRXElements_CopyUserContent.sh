#!/bin/zsh

########################################################################
#                Copy iZotope RX 7 Elements User Content               #
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
# Logged in user unique ID
loggedInUserUID=$(dscl . -read /Users/"$loggedInUser" UniqueID | awk '{print $2}')
# Logged in user ouset once plist
outsetOncePlist="/usr/local/outset/share/com.github.outset.once.${loggedInUserUID}.plist"
# Logged in users home directory
loggedInUserHome=$(/usr/bin/dscl . -read /Users/"$loggedInUser" NFSHomeDirectory | awk '{print $2}')
# Path to iZotope RX 7 Elements settings
izotopeRXSettings="/usr/local/ProAudioUserContent/iZotope/Documents/iZotope"
# Logfile
logFile="/Library/Logs/Bauer/Outset/iZotopeRXElements_UserContentCopy_${loggedInUser}.log"

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
# Delete any previous outset once plist for the logged in user
if [[ -f "$outsetOncePlist" ]]; then
    rm -f "$outsetOncePlist"
fi
# redirect both standard output and standard error to the log
exec >> "$logFile" 2>&1
echo "Script started at: $(date +"%Y-%m-%d_%H-%M-%S")"
# Copy all user settings
if [[ -d "/usr/local/ProAudioUserContent/iZotope" ]]; then
    echo "------------------------------------------------------------"
    echo "Copying all iZotope RX 7 Elements user content for ${loggedInUser}..."
    rsync -ruz --progress "$izotopeRXSettings" "${loggedInUserHome}/Documents"
    chown -R "$loggedInUser":"$loggedInUserGroup" "${loggedInUserHome}/Documents/iZotope"
    echo "Permissions for ${loggedInUserHome}/Documents/iZotope set to ${loggedInUser}:${loggedInUserGroup}"
    echo "All iZotope RX 7 Elements user content copied for ${loggedInUser}"
    echo "------------------------------------------------------------"
else
    echo "iZotope RX 7 Elements user content not found, unable to complete copy"
    echo "Reinstall iZotope RX 7 Elements"
fi
echo "Script completed at: $(date +"%Y-%m-%d_%H-%M-%S")"
exit 0