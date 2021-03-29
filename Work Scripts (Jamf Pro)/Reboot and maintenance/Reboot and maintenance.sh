#!/bin/zsh

########################################################################
#                     Reboot and System Maintenance                    #
################ Written by Suleyman Twana Mar 19/05/2017  #############
########################################################################
# Edit Phil Walker March 2021

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Jamf helper timeout (seconds)
helperTimeout="$4"
############ Variables for Jamf Pro Parameters - End ###################

# Check Mac uptime
upTime=$(uptime 2>/dev/null | awk '{print $3, $4}' | grep "days" | sed 's/days/ /;s/,/ /g' | xargs)
# OS Version
osVersion=$(sw_vers -productVersion)
# macOS Catalina version number
catalinaOS="10.15"
# Font Server status
fontServerstatus=$(atsutil server -ping)
#Fontd status
fontdStatus=$(pgrep "fontd")
# Jamf helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Jamf helper Icon
helperIcon="/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns"
# Jamf Helper heading
helperHeading="          Reboot Required          "
# Helper Title
helperTitle="Message from Bauer Technology"
# load is-at-least
autoload is-at-least

########################################################################
#                            Functions                                 #
########################################################################

function loggedInUserStatus ()
{
# Check if a user is logged in
loggedInUserCheck=$(stat -f %Su /dev/console)
if [[ "$loggedInUserCheck" == "" ]] || [[ "$loggedInUserCheck" == "root" ]]; then
	loggedInUser=""
	echo "No user is currently logged in"
else
	loggedInUser="$loggedInUserCheck"
fi
}

function jamfHelperMaintenance ()
{
# Helper window for process running 
"$jamfHelper" -windowType utility -icon "$helperIcon" \
-title "$helperTitle" -heading "System Maintenance" -alignHeading natural \
-description "Running system optimisation tasks...

Your Mac will automatically restart to complete the process"  -alignDescription natural &
}

function runMaintenanceTasks ()
{
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
    echo "No user logged in. Running Jamf flush System Cache only and fixByHostFiles commands..."
	/usr/local/jamf/bin/jamf flushCaches -flushSystem
	/usr/local/jamf/bin/jamf fixByHostFiles -target "/Volumes/Macintosh HD"
else
    echo "${loggedInUser} logged in. Running Jamf flushCaches (System and User) and fixByHostFiles commands..."
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
}

########################################################################
#                         Script starts here                           #
########################################################################

# Get the logged in user status
loggedInUserStatus
# If the uptime is less than a day 
if [[ "$upTime" -eq "" ]]; then    
    echo "Reboot not required"
	exit 0
else
	# If no user is logged in, reboot the Mac immediately if required
	if [[ "$loggedInUser" == "" ]] && [[ "$upTime" -ge "6" ]]; then
		echo "No user logged in and Mac has not been rebooted for more than 6 Days"
		echo "Running maintenance tasks..."
        # Run all maintenance tasks
		runMaintenanceTasks
		shutdown -r +1 >/dev/null 2>&1
	fi
fi
# If a user is logged in, display a message and allow one deferral
if [[ "$loggedInUser" != "" ]] && [[ "$upTime" -ge "6" ]]; then
	# Create a reboot timer file for the deferral
	if [[ ! -f "/Users/Shared/.rebootTimer.txt" ]]; then
		echo "1" > "/Users/Shared/.rebootTimer.txt"
		rebootTimer=$(cat "/Users/Shared/.rebootTimer.txt")
		if [[ "$upTime" -ge "6" ]] && [[ "$rebootTimer" -gt "0" ]]; then
			echo "Current uptime: ${upTime} days"
			echo "Reboot required!"
			# Jamf helper with a timeout and countdown included
helperDeferral=$(sudo -u "$loggedInUser" "$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" -heading "$helperHeading" -alignHeading natural -description "This Mac has not been rebooted for more than 6 days.

An urgent reboot is required to maintain the device security.

Please ensure all of your work is saved before clicking the Reboot button.

If you select Reboot Later, your next reminder will be tomorrow and the only option available will be Reboot." -timeout "$helperTimeout" -countdown -alignCountdown center -button1 "Reboot" -button2 "Reboot Later" -cancelButton "2" -defaultButton "1")
			if [[ "$helperDeferral" == "0" ]]; then
				echo "${loggedInUser} selected Reboot or message timeout reached"
				# display a helper window
				jamfHelperMaintenance
				echo "Running maintenance tasks..."
				# Run all maintenance tasks
				runMaintenanceTasks
				# Delete reboot timer temp file
				rm "/Users/Shared/.rebootTimer.txt"
				echo "Rebooting to complete system maintenance..." 
				shutdown -r +1 >/dev/null 2>&1
			else
				currentTimer=$((rebootTimer-1))
    			echo "$currentTimer" > "/Users/Shared/.rebootTimer.txt"
				echo "${loggedInUser} deferred the reboot"
				exit 0
			fi
		fi
	else
		# If the policy has already been deferred, only offer a reboot
		if [[ "$upTime" -ge "6" ]] && [[ "$rebootTimer" -eq "0" ]]; then
			echo "Current uptime: ${upTime} days"
			echo "Reboot required!"
			# Jamf helper with a timeout and countdown included
helperRebootOnly=$(sudo -u "$loggedInUser" "$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" -heading "$helperHeading" -alignHeading natural -description "This Mac has not been rebooted for more than 6 days.

An urgent reboot is required to maintain the device security.

Please ensure all of your work is saved before clicking the Reboot button.
																		" -timeout "$helperTimeout" -countdown -alignCountdown center -button1 "Reboot" -defaultButton "1")
			if [[ "$helperRebootOnly" == "0" ]]; then
				echo "${loggedInUser} selected Reboot or message timeout reached"
				# display a helper window
				jamfHelperMaintenance
				echo "Running maintenance tasks..."
				# Run all maintenance tasks
				runMaintenanceTasks
				# Delete reboot timer temp file
				rm "/Users/Shared/.rebootTimer.txt"
				echo "Rebooting to complete system maintenance..."	
    			shutdown -r +1 >/dev/null 2>&1
			fi
		fi
	fi
else
	echo "Current uptime: ${upTime} days"
	echo "Reboot not required"
fi
exit 0