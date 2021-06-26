#!/bin/zsh

########################################################################
#   Remove .NET Core SDKs or Runtimes Superseded By Higher Patches     # 
################### Written by Phil Walker June 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Uninstaller binary
uninstallBinary="/usr/local/dotnetuninstall/dotnet-core-uninstall"

########################################################################
#                         Script starts here                           #
########################################################################

# Check for the unininstaller binary
if [[ -e "$uninstallBinary" ]]; then
    echo ".NET uninstaller binary found"
    echo "Removing all .NET Core SDKs or Runtimes that have been superseded by higher patches"
    "$uninstallBinary" remove --all-lower-patches --runtime --yes
    "$uninstallBinary" remove --all-lower-patches --sdk --yes
    sleep 2
    /usr/local/jamf/bin/jamf recon &>/dev/null
    echo "Inventory update sent to Jamf Pro"
else
    echo ".NET uninstaller binary NOT found!"
    # Call policy to install .NET uninstaller
    /usr/local/jamf/bin/jamf policy -event "dotnet_uninstaller_tool"
fi
exit 0