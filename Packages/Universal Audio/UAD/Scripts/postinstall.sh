#!/bin/bash

########################################################################
#       Uninversal Audio Digital Software and Plugins Postinstall      #
########################################################################

#All of the below taken from UAD package.
#It has ben edited to remove elements not required and elements that are not designed for package deployment

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#####################################################################
#copy legacy PT Mode I/O presets for current Apollo configurations
#####################################################################


if [ -d "/Library/Application Support/Universal Audio/Apollo/IOPresets" ]; then
    if [ ! -d "/Users/${loggedInUser}/Documents/Universal Audio/IOPresets" ]; then
        su "${loggedInUser}" -c "mkdir -p \"/Users/${loggedInUser}/Documents/Universal Audio/IOPresets\""
    fi

    cd "/Library/Application Support/Universal Audio/Apollo/IOPresets"
    su "${loggedInUser}" -c "cp -Rf . \"/Users/${loggedInUser}/Documents/Universal Audio/IOPresets\""

    cd -

    rm -Rf "/Library/Application Support/Universal Audio/Apollo/IOPresets"
fi


#####################################################################
# set permissions for /Library/Application Support/UAFWAudio/UAFWAudioDaemon
# Apollo-only
#####################################################################

chmod +x "/Library/Application Support/UAFWAudio/UAFWAudioDaemon"

#####################################################################
# register console startup action
# Apollo-only
#####################################################################

# When we invoke the UAD Mixer Engine, it creates lock files in ~/Library/Caches/Juce/

su "${loggedInUser}" -c "/Library/Application\ Support/Universal\ Audio/Apollo/UA\ Mixer\ Engine.app/Contents/MacOS/UA\ Mixer\ Engine -addlogin"

# Disable Mavericks app nap for Console and mixer engine (CH-94, CH-99)
su "${loggedInUser}" -c "defaults write com.uaudio.console NSAppSleepDisabled -bool YES"
su "${loggedInUser}" -c "defaults write com.uaudio.ua_mixer_engine NSAppSleepDisabled -bool YES"

#####################################################################
# set permissions for Universal Audio directories
#####################################################################
chown -R "${loggedInUser}":staff "/Library/Audio/Plug-Ins/VST/Powered Plug-Ins"
chown "${loggedInUser}":staff "/Library/Audio/Plug-Ins/Components/"
chown -R "${loggedInUser}":staff "/Library/Audio/Plug-Ins/Components/UAD "*.component
chown -R "${loggedInUser}":staff "/Library/Audio/Plug-Ins/Components/Console Recall.component"
chown -R "${loggedInUser}":staff "/Library/Application Support/Digidesign/Plug-Ins/Universal Audio/"
chown -R "${loggedInUser}":staff "/Library/Application Support/Avid/Audio/Plug-Ins/Universal Audio/"
chown -R "${loggedInUser}":staff "/Applications/Universal Audio"
chown -R "${loggedInUser}":staff "/Library/Application Support/Universal Audio"

# set frameworks to be owned by the user
chown -R "${loggedInUser}":staff "/Library/Frameworks/UAD-2 GUI Support.framework"
chown -R "${loggedInUser}":staff "/Library/Frameworks/UAD-2 Plugin Support.framework"
chown -R "${loggedInUser}":staff "/Library/Frameworks/UAD-2 SDK Support.framework"

#######################################################################
# extract and install plug-in presets and console channel strip presets
#######################################################################
# Extract zip files
ditto -xk "/Library/Application Support/Universal Audio/Presets/VSTPresets.zip" "/Library/Application Support/Universal Audio/Presets/vst"
rm -f "/Library/Application Support/Universal Audio/Presets/VSTPresets.zip"
ditto -xk "/Library/Application Support/Universal Audio/Presets/MacAUPresets.zip" "/Library/Application Support/Universal Audio/Presets/au"
rm -f "/Library/Application Support/Universal Audio/Presets/MacAUPresets.zip"
ditto -xk "/Library/Application Support/Universal Audio/Presets/MacRTASPresets.zip" "/Library/Application Support/Universal Audio/Presets/rtas"
rm -f "/Library/Application Support/Universal Audio/Presets/MacRTASPresets.zip"
ditto -xk "/Library/Application Support/Universal Audio/Presets/Channel Strip.zip" "/Library/Application Support/Universal Audio/Presets/console"
rm -f "/Library/Application Support/Universal Audio/Presets/Channel Strip.zip"

# Create a directory for channel strip presets
mkdir -p "/Library/Application Support/Universal Audio/Presets/Channel Strip"

# Set preset ownership
chown -R "${loggedInUser}":staff "/Library/Application Support/Universal Audio/Presets"

# Install Console Channel Strip presets
cd "/Library/Application Support/Universal Audio/Presets/console/Channel Strip/"
find . -type f -exec chmod 444 '{}' \;
# Create preset directories
find . -type d -exec mkdir -m 775 -p "/Library/Application Support/Universal Audio/Presets/Channel Strip/{}" \;
# Copy preset files one-by-one
find . -type f -exec mv -fn "{}" "/Library/Application Support/Universal Audio/Presets/Channel Strip/{}" \;
cd -
rm -rf "/Library/Application Support/Universal Audio/Presets/console"

# Install VST presets
cd "/Library/Application Support/Universal Audio/Presets/vst/VST/"
# Make only the factory presets read-only before copying them to their final destination
find . -type f -exec chmod 444 {} \;
# Create preset directories
find . -type d -exec mkdir -m 775 -p "/Library/Application Support/Universal Audio/Presets/{}" \;
find . -type d -exec chown -R "${loggedInUser}":staff "/Library/Application Support/Universal Audio/Presets/{}" \;
# Copy preset files one-by-one
find . -type f -exec mv -fn "{}" "/Library/Application Support/Universal Audio/Presets/{}" \;
cd -
rm -rf "/Library/Application Support/Universal Audio/Presets/vst"

# Install AU presets
 ##############################
 # First check and create
 # AU folder if missing
 ##############################
 if [ ! -d "/Library/Audio/Presets" ]; then
  cd "/Library/Audio"
  mkdir "Presets"
  chown "${loggedInUser}":staff Presets
  chmod 775 Presets
 fi

 if [ ! -d "/Library/Audio/Presets/Universal Audio" ]; then
  cd "/Library/Audio/Presets"
  mkdir "Universal Audio"
  chown "${loggedInUser}":staff "Universal Audio"
  chmod 775 "Universal Audio"
 fi

mv -fn "/Library/Application Support/Universal Audio/Presets/au/AU/Audio/Presets/"* "/Library/Audio/Presets/Universal Audio"
rm -rf "/Library/Application Support/Universal Audio/Presets/au"

# Install AAX and RTAS presets
AAX_PRESET_DIR="/Users/${loggedInUser}/Documents/Pro Tools/Plug-In Settings"
RTAS_PRESET_DIR="/Library/Application Support/Digidesign/Plug-In Settings"

# AAX
if [ ! -d "${AAX_PRESET_DIR}" ]; then
  mkdir -p "${AAX_PRESET_DIR}"
  chown "${loggedInUser}":staff "${AAX_PRESET_DIR}"
fi
cd "/Library/Application Support/Universal Audio/Presets/rtas/Digidesign/Plug-In Settings/"
# Create AAX preset directories
find . -type d -exec mkdir -m 775 -p "${AAX_PRESET_DIR}/{}" \;
find . -type d -exec chown -R "${loggedInUser}":staff "${AAX_PRESET_DIR}/{}" \;
# Copy AAX presets one-by-one
find . -type f -exec cp -prfn "{}" "${AAX_PRESET_DIR}/{}" \;
cd -

# RTAS
if [ ! -d "${RTAS_PRESET_DIR}" ]; then
  mkdir -p "${RTAS_PRESET_DIR}"
  chown "${loggedInUser}":staff "${RTAS_PRESET_DIR}"
fi
cd "/Library/Application Support/Universal Audio/Presets/rtas/Digidesign/Plug-In Settings/"
# Create RTAS preset directories
find . -type d -exec mkdir -m 775 -p "${RTAS_PRESET_DIR}/{}" \;
find . -type d -exec chown -R "${loggedInUser}":staff "${RTAS_PRESET_DIR}/{}" \;
# Copy RTAS presets one-by-one
find . -type f -exec mv -fn "{}" "${RTAS_PRESET_DIR}/{}" \;
cd -
rm -rf "/Library/Application Support/Universal Audio/Presets/rtas"

#####################################################################
# Update firmware
#####################################################################

# Run Meter passing firmware check command line switch.
# This command must be run as the user, not as root, or else it will
# leave a Juce lock file in ~/Library/Caches/Juce that will prevent
# non-root users from launching the meter
su "${loggedInUser}" -c '"/Applications/Universal Audio/UAD Meter & Control Panel.app/Contents/MacOS/UAD Meter & Control Panel" -fw'

# Disable Mavericks app nap for UAD Meter (CH-94, CH-99)
# Probably not strictly necessary for UAD Meter, but we'll do it anyway
su "${loggedInUser}" -c "defaults write com.uaudio.uad_meter NSAppSleepDisabled -bool YES"


#####################################################################
# Delete Juce Cache Files
#####################################################################

rm -f "$HOME/Library/Caches/Juce/juceAppLock_Console"
rm -f "$HOME/Library/Caches/Juce/juceAppLock_UAD Meter"
rm -f "$HOME/Library/Caches/Juce/juceAppLock_Console Shell"

rm -f "/Users/$loggedInUser/Library/Caches/Juce/juceAppLock_Console"
rm -f "/Users/$loggedInUser/Library/Caches/Juce/juceAppLock_UAD Meter"
rm -f "/Users/$loggedInUser/Library/Caches/Juce/juceAppLock_Console Shell"

#####################################################################
# Move the drivers into place
#####################################################################
DRIVERS_DIR="/Library/Application Support/Universal Audio/Drivers/"
# Install signed driver on Mavericks (Darwin major version 13) or later
DRIVERS_SOURCE="${DRIVERS_DIR}/Signed/"
if [ `sysctl -n kern.osrelease | cut -d . -f 1` -lt 13 ]; then
	#echo "Mountain Lion or earlier"
	DRIVERS_SOURCE="${DRIVERS_DIR}/Unsigned/"
fi
# Install drivers to /Library/Extensions on Catalina (Darwin major version 19) or later
DRIVERS_DEST="/Library/Extensions"
if [ `sysctl -n kern.osrelease | cut -d . -f 1` -lt 19 ]; then
	#echo "Mojave or earlier"
	DRIVERS_DEST="/System/Library/Extensions"
fi
chown -R root:wheel "${DRIVERS_SOURCE}"*
mv "${DRIVERS_SOURCE}"* "${DRIVERS_DEST}"
rm -rf "${DRIVERS_DIR}"


#####################################################################
# touch extensions
#####################################################################

# Max number of retries while waiting for kextcache
MAX_RETRIES=30

# Seconds to wait on each iteration when waiting for kextcache
SECS_TO_WAIT=2


#----------------------------------------------------------------------------------------
# kextcache_is_running
#
# Checks if kextcache is currently running
#----------------------------------------------------------------------------------------

kextcache_is_running()
{
	# This will return 0 if kextcache is currently running
	ps aux | grep -v grep | grep kextcache > /dev/null

	# Flip sense of result since 0 means true in shell script
	if [ $? -eq 1 ]; then
		rc=0
		#echo "Kextcache is not running"
	else
		rc=1
		#echo "Kextcache is running"
	fi

	return $rc
}

#----------------------------------------------------------------------------------------
# wait_for_kextcache
#
# Waits for kextcache to either start or stop running.  Param is 1 to wait for kextcache
# to STOP running, 0 to wait for kextcache to START running.  Result is 1 if wait loop
# timed out, 0 on success.
#----------------------------------------------------------------------------------------

wait_for_kextcache()
{
	retries=$MAX_RETRIES
	while [ $retries -gt 0 ]
		do
			kextcache_is_running
			if [ $? -eq $1 ]; then
				#echo "Waiting $SECS_TO_WAIT secs for kextcache"
				sleep $SECS_TO_WAIT
				((retries--))
    			#echo "$retries retries left"
			else
				#echo "Done waiting for kextcache"
				break
			fi
	done

	# Check for timeout
	if [ $retries -eq 0 ]; then
		echo "Timed out waiting for kextcache!"
		return 1
	fi

	# If we got here, the wait succeeded
	return 0
}

#----------------------------------------------------------------------------------------
# safe_touch_SLE
#
# Safely touches /System/Library/Extensions in the following way:
# - Waits for kextcache to stop if it's currently running
# - Touches SLE
# (We used to also then do this step, but it appears to be unnecessary)
# - Waits for kextcache to start and stop after the touch
#----------------------------------------------------------------------------------------
safe_touch_SLE()
{
	# First make sure that kextcache is NOT running (in case it was already triggered)
	echo "-> Checking for kextcache already running"
	wait_for_kextcache 1
	if [ $? -eq 1 ]; then
		echo "Failed waiting for kextcache to stop running!  Touching SLE anyway..."
		touch "${DRIVERS_DEST}"
		return 1
	fi

	# If we got here, kextcache is done running, so now touch SLE
	echo "-> Touching SLE"
	touch "${DRIVERS_DEST}"

	return 0
}


#----------------------------------------------------------------------------------------
# Main routine
#----------------------------------------------------------------------------------------

safe_touch_SLE > /tmp/uad_driver_install.log

#####################################################################
# unix "delete meter cache"
#####################################################################

rm -Rf ~/Library/Caches/UAD\ Meter\ \&\ Control\ Panel/
rm -Rf /Users/$loggedInUser/Library/Caches/UAD\ Meter\ \&\ Control\ Panel/
