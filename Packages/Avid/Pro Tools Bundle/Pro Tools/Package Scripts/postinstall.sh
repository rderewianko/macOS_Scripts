#!/bin/bash

########################################################################
#                   Postinstall - Install Pro Tools 2019               #
##################### Written by Phil Walker Mar 2020 ##################
########################################################################

#Pro Tools DMG is copied to local machine via Package
#DMG provided by Avid contains several packages

########################################################################
#                         Script starts here                           #
########################################################################

#Mount the the DMG silently
hdiutil mount -noverify -nobrowse /usr/local/Pro\ Tools/Pro\ Tools/Pro_Tools_2019.12.0_Mac.dmg

#Install all packages/apps in correct order
#ProTools 2019.12
installer -pkg /Volumes/Pro\ Tools/Install\ Pro\ Tools\ 2019.12.0.pkg -target /
#CodecsLE
installer -pkg /Volumes/Pro\ Tools/Codec\ Installers/Install\ Avid\ Codecs\ LE.pkg -target /
#HD Driver
installer -pkg /Volumes/Pro\ Tools/Driver\ Installers/Install\ Avid\ HD\ Driver.pkg -target /
#AvidLink Update
installer -pkg /usr/local/Pro\ Tools/Pro\ Tools/UK_Avid_AvidLink_20.3.0.pkg -target /

#Unmount the DMG
hdiutil unmount -force /Volumes/Pro\ Tools/
#Remove Install DMG's and packages
rm -rf /usr/local/Pro\ Tools/

if [[ ! -d "/usr/local/Pro\ Tools/" ]]; then
  echo "Clean up has been successful"
else
  echo "Clean up FAILED, please delete the folder /usr/local/Pro\ Tools/ manually"
fi

exit 0
