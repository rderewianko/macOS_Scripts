#!/bin/zsh

########################################################################
#                       Set Keyboard to British                        #
################### Written by Phil Walker Jan 2021 ####################
########################################################################

# Before any variables are defined or any actions are taken, complete a few checks
echo "Checking all requirements are met..."
# Check a normal user is logged in
loggedInUser=$(stat -f %Su /dev/console)
if [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    while [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; do
        sleep 2
        loggedInUser=$(stat -f %Su /dev/console)
    done
fi
# Check Finder is running
finderProcess=$(pgrep -x "Finder")
until [[ "$finderProcess" != "" ]]; do
    sleep 2
    finderProcess=$(pgrep -x "Finder")
done
# Check the Dock is running
dockProcess=$(pgrep -x "Dock")
until [[ "$dockProcess" != "" ]]; do
    sleep 2
    dockProcess=$(pgrep -x "Dock")
done
echo "All requirements met"

########################################################################
#                            Variables                                 #
########################################################################

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
exit 0