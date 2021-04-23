#!/bin/zsh

########################################################################
#                       Set Keyboard to British                        #
################### Written by Phil Walker Jan 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# plist to modify keys in
plistLoc="/Users/${loggedInUser}/Library/Preferences/com.apple.HIToolbox.plist"
# PlistBuddy binary
plbuddyBinary="/usr/libexec/PlistBuddy"
# Keyboard name
keyboardName="British"
# Keyboard code
keyboardCode="2"

########################################################################
#                         Script starts here                           #
########################################################################

# Confirm that a user is logged in
if [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    echo "No one is home, exiting..."
    exit 1
else
    # Delete the current key layout settings
    "$plbuddyBinary" -c "Delete :AppleCurrentKeyboardLayoutInputSourceID" "${plistLoc}" &>/dev/null
    # Set the key layout to British
    "$plbuddyBinary" -c "Add :AppleCurrentKeyboardLayoutInputSourceID string com.apple.keylayout.${keyboardName}" "${plistLoc}"
    # Delete the below keys and add them again set to British
    for key in AppleCurrentInputSource AppleEnabledInputSources AppleSelectedInputSources; do
        "$plbuddyBinary" -c "Delete :${key}" "${plistLoc}" &>/dev/null
        "$plbuddyBinary" -c "Add :${key} array" "${plistLoc}"
        "$plbuddyBinary" -c "Add :${key}:0 dict" "${plistLoc}"
        "$plbuddyBinary" -c "Add :${key}:0:InputSourceKind string 'Keyboard Layout'" "${plistLoc}"
        "$plbuddyBinary" -c "Add :${key}:0:KeyboardLayout\ ID integer ${keyboardCode}" "${plistLoc}"
        "$plbuddyBinary" -c "Add :${key}:0:KeyboardLayout\ Name string '${keyboardName}'" "${plistLoc}"
    done
    # Confirm the changes
    keyboardLanguage=$("$plbuddyBinary" -c "print :AppleEnabledInputSources:0:KeyboardLayout\ Name" "/Users/${loggedInUser}/Library/Preferences/com.apple.HIToolbox.plist")
    if [[ "$keyboardLanguage" == "British" ]]; then
        echo "Keyboard input source now set to British"
    else
        echo "Keyboard input source set to ${keyboardLanguage}"
    fi
fi
exit 0