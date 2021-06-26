#!/bin/bash

########################################################################
#                  Add Recon to the Jamf startup script                #
##################### Written by Phil Walker Nov 2019 ##################
########################################################################

# To be used along with update policies that require a reboot

# Check if recon has already been added to the startup script - the startup script gets overwirtten during a jamf manage.
jamfRecon=$(grep "/usr/local/jamf/bin/jamf recon" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
if [[ -n "$jamfRecon" ]]; then
    echo "Recon already entered in startup script"
    exit 0
else
    # Add recon to the startup script
    echo "Recon not found in startup script, adding..."
    # Remove the exit from the file
    sed -i '' "/$exit 0/d" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh"
    # Add in additional recon line with an exit in
    /bin/echo "## Run Recon" >> "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh"
    /bin/echo "/usr/local/jamf/bin/jamf recon" >> "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh"
    /bin/echo "exit 0" >> "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh"
    # Re-populate variable
    jamfRecon=$(grep "/usr/local/jamf/bin/jamf recon" "/Library/Application Support/JAMF/ManagementFrameworkScripts/StartupScript.sh")
    if [[ -n "$jamfRecon" ]]; then
        echo "Recon added to the startup script successfully"
    else
        echo "Recon NOT added to the startup script"
    fi
fi
exit 0