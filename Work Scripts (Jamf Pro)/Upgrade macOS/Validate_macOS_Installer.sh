#!/bin/zsh

########################################################################
#                      Validate macOS Installer                        #
################## Written by Phil Walker Nov 2020 #####################
########################################################################
# To be used post macOS Installer install

########################################################################
#                         Jamf Variables                               #
########################################################################

# The path the to macOS installer is pulled in from the policy for flexability e.g /Applications/Install macOS Big Sur.app SPACES ARE PRESERVED
osInstallerLocation="$4"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -e "$osInstallerLocation" ]]; then
    "$osInstallerLocation"/Contents/Resources/startosinstall --usage &>/dev/null
fi