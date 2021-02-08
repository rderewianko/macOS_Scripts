#!/bin/zsh

########################################################################
#           Reset All Privacy Preferences Policy Control Data          #  
#################### Written by Phil Walker Feb 2021 ###################
########################################################################
# All services for root and logged in user reset

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# All TCC services. Excluding Location as you can't reset it using this method
tccServices=( "All" "AddressBook" "ContactsLimited" "ContactsFull" "Calendar" \
"Reminders" "Twitter" "Facebook" "SinaWeibo" "Liverpool" "Ubiquity" "TencentWeibo" \
"ShareKit" "Photos" "PhotosAdd" "Microphone" "Camera" "Willow" "MediaLibrary" \
"Siri" "Motion" "SpeechRecognition" "AppleEvents" "LinkedIn" "Accessibility" \
"PostEvent" "ListenEvent" "SystemPolicyAllFiles" "SystemPolicySysAdminFiles" \
"SystemPolicyDeveloperFiles" "SystemPolicyRemovableVolumes" "SystemPolicyNetworkVolumes" \
"SystemPolicyDesktopFolder" "SystemPolicyDownloadsFolder" "SystemPolicyDocumentsFolder" \
"ScreenCapture" "DeveloperTool" "FileProviderPresence" "FileProviderDomain" )

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

echo "Resetting all PPPC decisions for root"
# Reset all services for root
for srv in ${(f)tccServices}; do
   tccutil reset "$srv" >/dev/null 2>&1
done
echo "All PPPC decisions reset for root"

echo "Resetting all PPPC decisions for ${loggedInUser}"
# Reset all services for the logged in user
for srv in ${(f)tccServices}; do
   runAsUser tccutil reset "$srv" >/dev/null 2>&1
done
echo "All PPPC decisions reset for ${loggedInUser}"
