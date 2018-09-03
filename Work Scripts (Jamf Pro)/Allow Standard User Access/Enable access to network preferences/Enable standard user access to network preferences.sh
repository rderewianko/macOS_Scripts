#!/bin/bash

######################################################
# Grant standard users access to network preferences #
######################################################

# If the original files are already existing then apply the changes

	if [[ -d "/usr/local/Network_Prefs/" ]]; then

		security authorizationdb write system.preferences.network allow
		security authorizationdb write system.services.systemconfiguration.network allow

else

# Copy the original network preferences files to a root folder and then apply the changes

	if [[ ! -d "/usr/local/Network_Prefs/" ]]; then

		mkdir /usr/local/Network_Prefs

		security authorizationdb read system.preferences.network > /usr/local/Network_Prefs/system.preferences.network
		security authorizationdb read system.services.systemconfiguration.network > /usr/local/Network_Prefs/system.services.systemconfiguration.network

		security authorizationdb write system.preferences.network allow
		security authorizationdb write system.services.systemconfiguration.network allow

	fi

fi

# Check the changes have been applied

# populate variables to check the values set
USER_AUTH_PREF=$(/usr/libexec/PlistBuddy -c "print authenticate-user" /usr/local/Network_Prefs/system.preferences.network)
USER_AUTH_SERV=$(/usr/libexec/PlistBuddy -c "print authenticate-user" /usr/local/Network_Prefs/system.services.systemconfiguration.network)

if [[ $USER_AUTH_PREF == "true" ]] && [[ $USER_AUTH_SERV == "true" ]]; then

	echo "Standard user granted access to Network preferences"

else

	echo "Setting access to Network preferences failed"
	exit 1

fi

exit 0
