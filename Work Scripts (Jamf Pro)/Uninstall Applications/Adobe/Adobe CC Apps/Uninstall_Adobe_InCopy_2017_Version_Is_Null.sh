#!/bin/zsh

########################################################################
#          Remove Adobe InCopy 2017 when the version is null           #
################### Written by Phil Walker Oct 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Adobe InCopy 2017 app bundle
adobeInCopy="/Applications/Adobe InCopy CC 2017/Adobe InCopy CC 2017.app"
# InCopy Version
incopyVersion=$(mdls -name kMDItemVersion "$adobeInCopy" | awk '{print $3}' | sed 's/[()]//g')
# Hidden folder for corrupt apps
hiddenFolder="/private/var/tmp/Corrupt Apps"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$incopyVersion" == "null" ]]; then
    echo "InCopy version reported as ${incopyVersion}, removing app bundle"
    rm -rf "/Applications/Adobe InCopy CC 2017"
    if [[ ! -d "/Applications/Adobe InCopy CC 2017" ]]; then
        echo "Successfully removed Adobe InCopy 2017"
    else
        echo "Failed to delete the app directory, moving to a hidden location as the app bundle is corrupt and cannot be deleted"
        if [[ ! -d "$hiddenFolder" ]]; then
            # Create the folder
            mkdir "$hiddenFolder"
            # Hide the folder
            chflags hidden "$hiddenFolder"
            # Move the corrupt app bundle
            mv "/Applications/Adobe InCopy CC 2017" "$hiddenFolder"
        else
            # Make sure the directory is hidden
            chflags hidden "$hiddenFolder"
            # Move the corrupt app bundle
            mv "/Applications/Adobe InCopy CC 2017" "$hiddenFolder"
        fi
        if [[ ! -d "/Applications/Adobe InCopy CC 2017" ]]; then
            echo "Successfully removed Adobe InCopy 2017"
        else
            echo "Failed to remove Adobe InCopy 2017!"
            exit 1
        fi
    fi
else
    echo "Adobe InCopy 2017 is version ${incopyVersion} so will not be removed"
fi
exit 0