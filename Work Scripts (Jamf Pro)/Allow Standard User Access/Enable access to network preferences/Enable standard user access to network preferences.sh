#!/bin/bash

########################################################################
#        Grant standard users access to network preferences            #
##################### Written by Phil Walker ###########################
########################################################################

########################################################################
#                            Functions                                 #
########################################################################

function postChangeCheck() {
# Check the changes have been applied

# Create temporary verison of the new preference file
security authorizationdb read system.preferences.network > /tmp/system.preferences.network.modified
security authorizationdb read system.services.systemconfiguration.network > /tmp/system.services.systemconfiguration.network.modified

# populate variables to check the values set
userAuthSysPrefs=$(/usr/libexec/PlistBuddy -c "print rule" /tmp/system.preferences.network.modified | sed '2q;d' | sed 's/\ //g')
userAuthServ=$(/usr/libexec/PlistBuddy -c "print rule" /tmp/system.services.systemconfiguration.network.modified | sed '2q;d' | sed 's/\ //g')

if [[ "$userAuthSysPrefs" == "allow" ]] && [[ "$userAuthServ" == "allow" ]]; then

	echo "Standard user granted access to Network preferences"

else

	echo "Setting access to Network preferences failed"
	exit 1

fi

rm -f /tmp/system.preferences.network.modified
rm -f /tmp/system.services.systemconfiguration.network.modified

}

########################################################################
#                         Script starts here                           #
########################################################################

# If the original files already exist then apply the changes

	if [[ -d "/usr/local/Network_Prefs/" ]]; then

		echo "Original preferences already backed up, setting authorisation rights..."
		security authorizationdb write system.preferences.network allow
		security authorizationdb write system.services.systemconfiguration.network allow

else

# Copy the original network preferences files to a root folder and then apply the changes

	if [[ ! -d "/usr/local/Network_Prefs/" ]]; then

		echo "Backing up preferences..."
		mkdir /usr/local/Network_Prefs

		security authorizationdb read system.preferences.network > /usr/local/Network_Prefs/system.preferences.network
		security authorizationdb read system.services.systemconfiguration.network > /usr/local/Network_Prefs/system.services.systemconfiguration.network

		echo "Setting authorisation rights..."
		security authorizationdb write system.preferences.network allow
		security authorizationdb write system.services.systemconfiguration.network allow

	fi

fi

echo "Checking authorisation rights have been set successfully..."
postChangeCheck

exit 0
