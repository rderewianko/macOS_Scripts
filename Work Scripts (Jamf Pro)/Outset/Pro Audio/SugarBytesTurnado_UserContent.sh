#!/bin/zsh

########################################################################
#                Copy Sugar Bytes Turnado User Content                 #
#################### Written by Phil Walker Nov 2020 ###################
########################################################################
# Edit Mar 2021
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
# Logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Logged in users home directory
loggedInUserHome=$(/usr/bin/dscl . -read /Users/"$loggedInUser" NFSHomeDirectory | awk '{print $2}')
# Path to Sugar Bytes Turnado settings
turnadoSettings="/usr/local/ProAudioUserContent/Sugar Bytes/Documents/Sugar Bytes/Turnado"
# Logfile
logFile="/Library/Logs/Bauer/Outset/SugarBytesTurnado_UserContentCopy_${loggedInUser}.log"

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

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
echo "Script started at: $(date +"%d-%m-%Y %H-%M-%S")"
# Copy all user settings
if [[ -d "$turnadoSettings" ]]; then
    echo "------------------------------------------------------------"
    echo "Copying all Sugar Bytes Turnado user content for ${loggedInUser}..."
    rsync -ruz --progress "$turnadoSettings" "${loggedInUserHome}/Documents/Sugar Bytes"
    chown -R "$loggedInUser":"$loggedInUserGroup" "${loggedInUserHome}/Documents/Sugar Bytes"
    echo "Permissions for ${loggedInUserHome}/Documents/Sugar Bytes set to ${loggedInUser}:${loggedInUserGroup}"
    echo "All Sugar Bytes Turnado user content copied for ${loggedInUser}"
    echo "------------------------------------------------------------"
else
    echo "Sugar Bytes Turnado user content not found, unable to complete copy"
    echo "Reinstall Sugar Bytes Turnado"
fi
# Set default user preferences
echo "Setting default user preferences for ${loggedInUser}..."
# Set the content path
runAsUser defaults write com.sugar-bytes.Turnado contentpath "${loggedInUserHome}/Documents/Sugar Bytes/Turnado/"
contentPath=$(runAsUser defaults read com.sugar-bytes.Turnado contentpath)
if [[ "$contentPath" == "${loggedInUserHome}/Documents/Sugar Bytes/Turnado/" ]]; then
    echo "Content path set to: ${contentPath}"
fi
# Set the install path
runAsUser defaults write com.sugar-bytes.Turnado installpath "/Applications/Sugar Bytes/Turnado/"
installPath=$(runAsUser defaults read com.sugar-bytes.Turnado installpath)
if [[ "$installPath" == "/Applications/Sugar Bytes/Turnado/" ]]; then
    echo "Install path set to: ${installPath}"
fi
# Set additional default prefs
runAsUser defaults write com.sugar-bytes.Turnado firstuse "0"
runAsUser defaults write com.sugar-bytes.Turnado isDemo -int "0"
runAsUser defaults write com.sugar-bytes.Turnado openPlayerOnStartup -int "1"
runAsUser defaults write com.sugar-bytes.Turnado sampleCalcTempo -int "1"
runAsUser defaults write com.sugar-bytes.Turnado sampleLooped -int "1"
echo "------------------------------------------------------------"
echo "Script completed at: $(date +"%d-%m-%Y %H-%M-%S")"
exit 0