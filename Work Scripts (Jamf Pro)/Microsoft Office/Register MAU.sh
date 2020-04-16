#!/bin/bash

########################################################################
#                   Register Microsoft AutoUpdate                      #
################## Written by Phil Walker Apr 2020 #####################
########################################################################

# Thanks to P Bowden for the info (https://github.com/pbowden-msft/RegMAU/blob/master/RegMAU)
# Registers the MAU application in the Launch Services database
# Must be run on a per user basis

########################################################################
#                            Variables                                 #
########################################################################

# Get the current logged in user
loggedInUser=$(stat -f %Su /dev/console)
# lsregister - command to query and manage the Launch Services database
lsRegister="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
# Microsoft AutoUpdate Application
mauApp="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"
# Microsoft AutoUpdate Assistant
mauAssistant="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft Update Assistant.app"

########################################################################
#                            Functions                                 #
########################################################################

postCheck ()
{
# Confirm MAU has been registered successfully
checkMAU=$(/usr/bin/sudo -u "$loggedInUser" "$lsRegister" -dump | grep "$mauApp" | grep -v "Contents")
checkMAUAssistant=$(/usr/bin/sudo -u "$loggedInUser" "$lsRegister" -dump | grep "$mauAssistant")
if [[ "$checkMAU" != "" ]] && [[ "$checkMAUAssistant" != "" ]]; then
     echo "Microsoft AutoUpdate registered successfully for $loggedInUser"
else
     echo "Failed to register Microsoft AutoUpdate for $loggedInUser"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

#Confirm that a user is logged in
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
     echo "No one is home, exiting..."
     exit 1
else
     if [[ -d "$mauApp" ]]; then
          /usr/bin/sudo -u "$loggedInUser" "$lsRegister" -R -f -trusted "$mauApp"
          /usr/bin/sudo -u "$loggedInUser" "$lsRegister" -R -f -trusted "$mauAssistant"
          postCheck
     else
          echo "Microsoft AutoUpdate not found"
          exit 1
     fi
fi

exit 0