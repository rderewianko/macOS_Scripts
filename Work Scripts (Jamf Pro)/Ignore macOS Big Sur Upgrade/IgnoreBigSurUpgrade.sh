#!/bin/zsh

########################################################################
#           Ignore macOS Big Sur Upgrade via Software Update           #
################### Written by Phil Walker Nov 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# OS Version
osVersion=$(sw_vers -productVersion)
# macOS Big Sur base version
bigSur="11"

########################################################################
#                            Functions                                 #
########################################################################

function preCheck ()
{
# check ignored updates for Big Sur
if [[ "$(softwareupdate --ignore | grep -v "Ignored updates:")" =~ "macOS Big Sur" ]]; then
    echo "Big Sur upgrade already set as ignored, nothing to do"
    exit 0
else
    echo "macOS Big Sur upgrade not listed as an ignored update"
fi
}

function postCheck ()
{
# check the Big Sur upgrade has been ignored successfully
if [[ "$(softwareupdate --ignore | grep -v "Ignored updates:")" =~ "macOS Big Sur" ]]; then
    echo "Big Sur upgrade set as ignored"
else
    echo "macOS Big Sur upgrade not available to be set as ignored yet"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Confirm OS version is Catalina or earlier
autoload is-at-least
if ! is-at-least "$bigSur" "$osVersion"; then
    echo "Mac running ${osVersion}, checking if Big Sur is listed as an ignored update..."
    preCheck
    echo "Settings the Big Sur upgrade to ignored..."
        softwareupdate --ignore "macOS Big Sur" >/dev/null 2>&1
        # Check the upgrade is now set to ignore
        postCheck
else
    echo "Mac running ${osVersion}, no changes required"
fi
exit 0