#!/bin/zsh

########################################################################
#                      Remove Legacy VPN config                        #
################### written by Phil Walker Dec 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Cisco AnyConnect legacy config
legacyConfig="/opt/cisco/anyconnect/profile/new_Legacy.xml"

########################################################################
#                         Script starts here                           #
########################################################################

# Remove the legacy config xml file
if [[ -f "$legacyConfig" ]]; then
    echo "Cisco AnyConnect legacy config found"
    rm -f "$legacyConfig"
    if [[ ! -f "$legacyConfig" ]]; then
        echo "Cisco AnyConnect legacy config removed"
    else
        echo "Failed to remove Cisco AnyConnect legacy config!"
        exit 1
    fi
    # Remove the Cisco AnyConnect user preferences
    userList=$(dscl . -list /Users | grep -v "^_\|daemon\|nobody\|root")
    for user in ${(f)userList}; do
        if [[ -e "/Users/"${user}"/.anyconnect" ]]; then
            rm /Users/"${user}"/.anyconnect
            echo "Cisco AnyConnect user preferences removed for ${user}"
        fi
    done
else
    echo "Cisco AnyConnect legacy config not found, nothing to do"
fi
exit 0