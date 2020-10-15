#!/bin/bash

########################################################################
#              Configure Time Machine for Pro Tools Macs               #
################### Written by Phil Walker June 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the HostName
hostName=$(scutil --get HostName)
# Define paths for Time Machine
applicationsDir="/Applications"
libraryDir="/Library"
systemDir="/System/Volumes/Data/System"
networkDir="/System/Volumes/Data/Network"
adminUser="/Users/admin"
usrDir="/usr"
#swapFile="/var/vm"
tmBackupDisk="/Volumes/${hostName} Time Machine HDD"
# Recovery disk
recoveryDisk=$(diskutil list | grep -i "recovery" | awk '{print $7}')
# Jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper icon
jamfHelperProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
# Helper icon 
helperIcon="/System/Library/PreferencePanes/TimeMachine.prefPane/Contents/Resources/TimeMachine.icns"
# Helper title
helperTitle="Message from Bauer IT"
# Helper heading
helperHeading="Current Time Machine Configuration"
# Helper heading no disk
helperHeadingNoDisk="Time Machine Disk Not Found"

########################################################################
#                            Functions                                 #
########################################################################

# jamf Helper to advise that an external disk for Time Machine has not been found
function externalHDDHelper ()
{
"$jamfHelper" -windowType utility -icon "$jamfHelperProblem" -title "$helperTitle" \
-heading "$helperHeadingNoDisk" -description "In order to configure Time Machine, an external hard drive \
with the correct naming convention needs to be attached

The external drive should be formatted and named
${tmBackupDisk} " -timeout 30 -button1 "Ok" -defaultButton "1"
}

# jamf Helper to display config
function tmConfigHelper ()
{
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description \
"$(tmutil isexcluded "$applicationsDir")
$(tmutil isexcluded "$libraryDir")
$(tmutil isexcluded "$systemDir")
$(tmutil isexcluded "$networkDir")
$(tmutil isexcluded "$adminUser")
$(tmutil isexcluded "$usrDir")
$(/usr/bin/tmutil destinationinfo | grep -v "ID\|Kind")"  -alignDescription natural -timeout 30 -button1 "Ok" -defaultButton "1"
}

# Configure Time Machine
function configireTM ()
{
# Enable Time Machine
tmutil enable
# Set backup destination
tmutil setdestination "/Volumes/${hostName} Time Machine HDD"
# Set all exclusions possible
tmutil addexclusion -p "$applicationsDir"
tmutil addexclusion -p "$libraryDir"
tmutil addexclusion -p "$systemDir"
tmutil addexclusion -p "$networkDir"
tmutil addexclusion -p "$adminUser"
tmutil addexclusion -p "$usrDir"
#tmutil addexclusion -p "$swapFile"
# Mount the Recovery partition for manual exclusion
diskutil mount /dev/"$recoveryDisk"
# Add Time Machine to the menu bar
sudo -u "$loggedInUser" open '/System/Library/CoreServices/Menu Extras/TimeMachine.menu/'
# Unlock the Time Machine Preference Pane for all users
security authorizationdb write system.preferences allow
security authorizationdb write system.preferences.timemachine allow
}

function unlockTMPrefPane ()
{
# If the original files already exist then apply the changes
if [[ -d "/usr/local/TimeMachine_Prefs/" ]]; then
	echo "Original preferences already backed up, setting authorisation rights..."
	security authorizationdb write system.preferences allow
    security authorizationdb write system.preferences.timemachine allow
else
    # Copy the original Time Machine preferences files to a root folder and then apply the changes
	if [[ ! -d "/usr/local/TimeMachine_Prefs/" ]]; then
		echo "Backing up preferences..."
		mkdir "/usr/local/TimeMachine_Prefs"
		security authorizationdb read system.preferences > /usr/local/TimeMachine_Prefs/system.preferences
		security authorizationdb read system.preferences.timemachine > /usr/local/TimeMachine_Prefs/system.preferences.timemachine
		echo "Setting authorisation rights..."
		security authorizationdb write system.preferences allow
        security authorizationdb write system.preferences.timemachine allow
	fi
fi
}

function checkAuthRights ()
{
# Check the changes have been applied
# Create temporary verisons of the new preference files
security authorizationdb read system.preferences > /tmp/system.preferences.modified
security authorizationdb read system.preferences.timemachine > /tmp/system.preferences.timemachine.modified
# Populate variable to check the values set
userAuthSysPrefs=$(/usr/libexec/PlistBuddy -c "print rule" /tmp/system.preferences.modified | sed '2q;d' | sed 's/\ //g')
userAuthTimeMachine=$(/usr/libexec/PlistBuddy -c "print rule" /tmp/system.preferences.timemachine.modified | sed '2q;d' | sed 's/\ //g')
if [[ $userAuthSysPrefs == "allow" ]] && [[ $userAuthTimeMachine == "allow" ]]; then
	echo "Standard user granted access to Time Machine preferences"
else
	echo "Setting access to Time Machine preferences failed"
	exit 1
fi
# Delete temp files
rm -f "/tmp/system.preferences.modified"
rm -f "/tmp/system.preferences.timemachine.modified"
}

########################################################################
#                         Script starts here                           #
########################################################################

# Check if the HDD with the correct name is mounted
if mount | grep "on $tmBackupDisk" > /dev/null; then
    echo "Time Machine HDD is mounted"
    echo "Configuring Time Machine..."
    # Configure Time Machine
    configireTM
    # Unlock Time Machine Prefence Pane
    unlockTMPrefPane
    checkAuthRights
    # Show helper with config settings
    echo "Time Machine configuration completed and displayed in the helper window"
    tmConfigHelper
else
    echo "Time Machine HDD not mounted, exiting..."
    # Show helper to warn that no TM disk has been found
    externalHDDHelper
fi

exit 0