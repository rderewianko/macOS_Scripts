#!/bin/bash

########################################################################
#        Enable Location Services and set Time Zone to auto detect     #
#################### Written by Phil Walker Nov 2019 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Location Services status
locationServicesStatus=$(defaults read /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled 2>/dev/null)
#Auto Time Zone status
autoTimeZoneStatus=$(defaults read /Library/Preferences/com.apple.timezone.auto Active 2>/dev/null)
#locationd service PID
locationdServicePID=$(/bin/launchctl list | grep "locationd" | awk '{print $1}')
#cfprefsd service PID
cfprefsdServicePID=$(/bin/launchctl list | grep "cfprefsd" | awk '{print $1}')

########################################################################
#                            Functions                                 #
########################################################################

function restartLocationServices ()
{
#Kill locationd service
/usr/bin/killall -9 locationd
#Restart the service
/bin/launchctl kickstart -k system/com.apple.locationd
#Wait for the locationd service to be restarted before continuing
while [[ $(/bin/launchctl list | grep "locationd" | awk '{print $1}') == "$locationdServicePID" ]]; do
  echo "locationd service being restarted..."
  sleep 1;
done
echo "locationd service restarted"
}

function restartPreferencesService ()
{
#Kill cfprefsd service
/usr/bin/killall -9 cfprefsd
#Restart the service
/bin/launchctl kickstart -k system/com.apple.cfprefsd.xpc.daemon
#Wait for the cfprefsd service to be restarted before continuing
while [[ $(/bin/launchctl list | grep "cfprefsd" | awk '{print $1}') == "$cfprefsdServicePID" ]]; do
  echo "cfprefsd service being restarted..."
  sleep 1;
done
echo "cfprefsd service restarted"
}

function enableLocationAndTimeSettings ()
{
#Enable Location Services
echo "Updating ByHost preferences to enable Location Services..."
/usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 1
/usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd.notbackedup LocationServicesEnabled -int 1

#Set Time Zone automatically based on location
echo "Setting Time Zone to detect automatically..."
/usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true
/usr/bin/defaults write /private/var/db/timed/Library/Preferences/com.apple.timed.plist TMAutomaticTimeOnlyEnabled -bool true
/usr/bin/defaults write /private/var/db/timed/Library/Preferences/com.apple.timed.plist TMAutomaticTimeZoneEnabled -bool true

/usr/sbin/systemsetup -setusingnetworktime on

#Restart services (locationd and cfprefsd)
echo "Restarting Services..."
restartLocationServices
restartPreferencesService

#Confirm changes have been made successfully
locationServicesStatus=$(defaults read /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled)
autoTimeZoneStatus=$(defaults read /Library/Preferences/com.apple.timezone.auto Active)
if [[ "$locationServicesStatus" == "1" ]] && [[ "$autoTimeZoneStatus" == "1" ]] ; then
  echo "Location Services and Auto Time Zone enabled"
  echo "Restart required before settings are applied"
else
  echo "Location Services and Auto Time Zone not set"
  exit 1
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$locationServicesStatus" != "1" || "$autoTimeZoneStatus" != "1" ]]; then
  echo "Location Services and Auto Time Zone not set, settings them both now..."
  enableLocationAndTimeSettings
else
  echo "Location Services and Auto Time Zone settings already applied"
  exit 0
fi

exit 0
