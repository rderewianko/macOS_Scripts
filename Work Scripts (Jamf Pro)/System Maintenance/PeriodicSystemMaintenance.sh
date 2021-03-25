#!/bin/zsh

########################################################################
#                       Periodic System Maintenance                    #
##################### Written by Phil Walker Mar 2021 ##################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# OS Version
osVersion=$(sw_vers -productVersion)
# macOS Catalina version number
catalinaOS="10.15"
# Font Server status
fontServerstatus=$(atsutil server -ping)
# Fontd status
fontdStatus=$(pgrep "fontd")
# Jamf helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Jamf helper icon
helperIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarCustomizeIcon.icns"
# Helper Title
helperTitle="Message from Bauer IT"
# Helper heading
helperHeading="Optimise Mac"

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperOptimise ()
{
# Helper window for process running 
"$jamfHelper" -windowType utility -icon "$helperIcon" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "Running system optimisation tasks...

Your Mac will restart automatically to complete the process"  -alignDescription natural &
}

########################################################################
#                         Script starts here                           #
########################################################################

# load is-at-least
autoload is-at-least
# Show a helper window
jamfHelperOptimise
# Flush DNS cache
echo "Flushing DNS cache..."
if is-at-least "$catalinaOS" "$osVersion"; then
    # macOS Catalina or later
    dscacheutil -flushcache
    killall -HUP mDNSResponder
else
    # macOS Sierra to Mojave
    killall -HUP mDNSResponder
fi
echo "DNS cache flushed"
# Clear CUPS folder
cupsdProcs=$(ps aux | grep "cupsd" | awk '{print $3}')
currentActivity="0.0"
for proc in ${(f)cupsdProcs}; do
    if [[ "$proc" != "0.0" ]]; then
        currentActivity="$proc"
        break
    fi
done
noActivity="0.0"
printStatus=$(lpstat -l -o | grep "job-printing" | awk '{print $2}')
if [[ "$printStatus" == "job-printing" ]]; then
    wait
else
	if [[ "$currentActivity" > "$noActivity" ]]; then
        wait
	elif [[ "$currentActivity" == "$noActivity" ]]; then
        echo "Flushing CUPS folder..."
		chflags -Rf nouchg /var/spool/cups/*
		rm -rf /var/spool/cups/*
		killall -HUP cupsd		
	    echo "CUPS folder has been emptied"
	fi
fi
# Run periodic system maintenance script
echo "Running periodic maintenance commands..."
periodic daily
periodic weekly
periodic monthly
echo "Periodic maintenance commands completed"
# Run Jamf maintenance commands
if [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
	# Flush system cache only
    echo "Running Jamf flushCaches (System Only) and fixByHostFiles commands..."
	/usr/local/jamf/bin/jamf flushCaches -flushSystem
	/usr/local/jamf/bin/jamf fixByHostFiles -target "/Volumes/Macintosh HD"
else
	# Flush system and user cache
    echo "Running Jamf flushCaches (System and User) and fixByHostFiles commands..."
	/usr/local/jamf/bin/jamf flushCaches -flushSystem
	/usr/local/jamf/bin/jamf flushCaches -flushUsers
	/usr/local/jamf/bin/jamf fixByHostFiles -target "/Volumes/Macintosh HD"
fi
# Flush disk cache
echo "Purging disk cache..."
purge
echo "Disk cache purged"
# Clean Font Registration Database
echo "Cleaning Font Registration Database..."
# Check if system's font server is running
if [[ "$fontServerstatus" =~ "running" ]]; then
    # Now shutdown system's font server 
	atsutil server -shutdown >/dev/null 2>&1
    # Remove font registration databases for root and current user 		
	atsutil databases -remove >/dev/null 2>&1
    # Now wait for system's font server to restart automatically
    while [[ ! "$fontServerstatus" =~ "running" ]]; do
        sleep 1
        # Font Server status
        fontServerstatus=$(atsutil server -ping)
    done
    # Now check if fontd process is running
    if [[ "$fontdStatus" != "" ]]; then
        # Now kill fontd process
	    killall -9 "fontd"
        # Now wait for fontd process to restart automatically
        while [[ "$fontdStatus" == "" ]]; do
            sleep 1
            # Fontd status
            fontdStatus=$(pgrep "fontd")
        done
	fi
fi
echo "Font Registration Database cleaned"
# Close Self Service
pkill "Self Service"
# Restart to complete the process
echo "Restarting the Mac to complete optimisation..."
shutdown -r +1 >/dev/null 2>&1
exit 0