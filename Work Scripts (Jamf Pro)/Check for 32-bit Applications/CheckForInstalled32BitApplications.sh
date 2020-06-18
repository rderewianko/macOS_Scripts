#!/bin/bash

########################################################################
#          Display Installed 32-bit Applications - Self Service        #
################### Written by Phil Walker June 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# OS version - short
osShort=$(sw_vers -productVersion | awk -F. '{print $2}')
# Check for 32-bit Applications
# If running macOS Mojave or previous, exclude the system app InkServer.app and the system framework QuickLook which includes quicklookd32.app (both are 32-bit)
if [[ "$osShort" -le "14" ]]; then
    thirtyTwoBitApps=$(/usr/bin/mdfind "kMDItemExecutableArchitectures == 'i386' && kMDItemExecutableArchitectures != 'x86_64' && \
kMDItemKind == 'Application'" | grep -v "/System/Library/Input Methods/InkServer.app" | grep -v "/System/Library/Frameworks/QuickLook.framework/Versions/A/Resources/quicklookd32.app")
else
    thirtyTwoBitApps=$(/usr/bin/mdfind "kMDItemExecutableArchitectures == 'i386' && kMDItemExecutableArchitectures != 'x86_64' && kMDItemKind == 'Application'")
fi
# Jamf Helper details
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
helperIconFound="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Unsupported.icns"
helperIconNotFound="/System/Library/CoreServices/Installer.app/Contents/PlugIns/Summary.bundle/Contents/Resources/Success.pdf"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "${thirtyTwoBitApps}" != "" ]]; then
    echo "32-bit Applications installed"
    su -l "$loggedInUser" -c "echo '${thirtyTwoBitApps}' > /Users/$loggedInUser/Desktop/32-bitAppsInstalled.txt"
    echo "Results saved to Users/$loggedInUser/Desktop/32-bitAppsInstalled.txt"
    "$jamfHelper" -windowType utility -icon "$helperIconFound" \
-title "32-bit Applications Found" -heading "Applications not compatible with macOS Catalina" -description "*A copy of the incompatible apps has been saved to your desktop*
${thirtyTwoBitApps}" -timeout 30 -button1 "OK" -defaultButton "1"
else
    echo "No 32-bit Applications installed"
    "$jamfHelper" -windowType utility -icon "$helperIconNotFound" \
-title "Message from Bauer IT" -heading "No 32-bit Applications Found" -description "Your Mac can be upgraded to macOS Catalina" -timeout 30 -button1 "OK" -defaultButton "1"
    # Run recon
    /usr/local/jamf/bin/jamf recon
fi

exit 0