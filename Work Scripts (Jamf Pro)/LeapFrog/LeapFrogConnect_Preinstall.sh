#!/bin/zsh

########################################################################
#               LeapFrog Connect for LeapStart - Preinstall            #
################## Written by Phil Walker Apr 2021 #####################
########################################################################
# Package includes a version check and will error if it's the same version rather than existing as successful
# To avoid errors when no changes need to be made, remove existing content before running the installer

########################################################################
#                            Variables                                 #
########################################################################

# LeapFrog Content (App, kext etc)
leapfrogContent=( "/Applications/LeapFrog\ Connect\ for\ LeapStart\ Interactive\ Learning\ System.app" \
"/Library/Application\ Support/LeapFrog" "/Library/Extensions/LfConnectDriver.kext" )

########################################################################
#                         Script starts here                           #
########################################################################

echo "Removing all previous LeapFrog Connect content..."
# Remove all existing content to allow reinstallation
for content in ${(Q)${(z)leapfrogContent}}; do
    rm -rf "$content" 2>/dev/null
    echo "Removed ${content}"
done
echo "All previous LeapFrog Connect content removed"
exit 0