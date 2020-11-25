#!/bin/zsh

########################################################################
#                   Remove Previous macOS Installer  	               #
################### Written by Phil Walker Aug 2020 ####################
########################################################################

########################################################################
#                         Jamf Variables                               #
########################################################################

# The path the to macOS installer is pulled in from the policy for flexability e.g /Applications/Install macOS Big Sur.app SPACES ARE PRESERVED
osInstallerLocation="$4"
# OS name e.g Big Sur
osName="$5"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -e "$osInstallerLocation" ]]; then
    echo "Previous macOS ${osName} Installer found"
    rm -rf "$osInstallerLocation"
    sleep 2
    if [[ ! -e "$osInstallerLocation" ]]; then
        echo "Previous macOS ${osName} Installer deleted successfully"
    else
        echo "Failed to delete previous versions of macOS ${osName} Installer"
        echo "If disk space is already low this may cause the package to fail"
    fi
fi
# Submit inventory to avoid the upgrade policy running if with no installer available if the package fails
/usr/local/jamf/bin/jamf recon
exit 0