#!/bin/bash

############################################################
# Grant standard users access to Date and Time preferences #
############################################################

##########################
#   script starts here   #
##########################

# If the original files are already existing then apply the changes

	if [[ -d "/usr/local/DateTime_Prefs/" ]]; then

		security authorizationdb write system.preferences.datetime allow

else

# Copy the original DateTime preferences files to a root folder and then apply the changes

	if [[ ! -d "/usr/local/DateTime_Prefs/" ]]; then

		mkdir /usr/local/DateTime_Prefs

		security authorizationdb read system.preferences.datetime > /usr/local/DateTime_Prefs/system.preferences.datetime
		security authorizationdb write system.preferences.datetime allow

	fi

fi

# Check the changes have been applied

# populate variable to check the values set
USER_AUTH=$(/usr/libexec/PlistBuddy -c "print authenticate-user" /usr/local/DateTime_Prefs/system.preferences.datetime)

if [[ $USER_AUTH == "true" ]]; then

	echo "Standard user granted access to Date & Time preferences"

else

	echo "Setting access to Date & Time preferences failed"
	exit 1

fi

exit 0
