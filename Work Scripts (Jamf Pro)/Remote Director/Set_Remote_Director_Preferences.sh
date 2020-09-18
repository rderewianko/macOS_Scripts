#!/bin/bash

########################################################################
#              Remote Director - Create User Preferences               #
#################### Written by Phil Walker July 2020 ##################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Remote Director directory
rdDirectory="/Users/$loggedInUser/RD Desktop"

########################################################################
#                            Functions                                 #
########################################################################

function createPrefs ()
{
su -l "$loggedInUser" -c "/bin/cat > /Users/$loggedInUser/RD\ Desktop/last_position.txt <<<'0 0 241 1400 816'"
su -l "$loggedInUser" -c "/bin/cat > /Users/$loggedInUser/RD\ Desktop/startup_verify.txt <<<'http://msapprd04.bauer-uk.bauermedia.group'"
su -l "$loggedInUser" -c "/bin/cat > /Users/$loggedInUser/RD\ Desktop/startup.txt <<<'http://msapprd04.bauer-uk.bauermedia.group'"
}

function checkPrefs ()
{
lastPosPref=$(/bin/cat < "${rdDirectory}/last_position.txt" | grep "0 0 241 1400 816")
startVerifyPref=$(/bin/cat < "${rdDirectory}/startup_verify.txt" | grep "http://msapprd04.bauer-uk.bauermedia.group")
startupPref=$(/bin/cat < "${rdDirectory}/startup.txt" | grep "http://msapprd04.bauer-uk.bauermedia.group")
if [[ "$lastPosPref" != "" ]] && [[ "$startVerifyPref" != "" ]] && [[ "$startupPref" != "" ]]; then
    echo "Remote Director preferences for ${loggedInUser} all found"
else
    echo "Creating Remote Director user preferences..."
    createPrefs
    # re-populate variables
    lastPosPref=$(/bin/cat < "${rdDirectory}/last_position.txt" | grep "0 0 241 1400 816")
    startVerifyPref=$(/bin/cat < "${rdDirectory}/startup_verify.txt" | grep "http://msapprd04.bauer-uk.bauermedia.group")
    startupPref=$(/bin/cat < "${rdDirectory}/startup.txt" | grep "http://msapprd04.bauer-uk.bauermedia.group")
    if [[ "$lastPosPref" != "" ]] && [[ "$startVerifyPref" != "" ]] && [[ "$startupPref" != "" ]]; then
        echo "Remote Director preferences for ${loggedInUser} all found"
    else
        echo "Failed to create Remote Director user preferences"
        exit 1
    fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
	echo "No user currently logged in, exiting..."
else
    if [[ ! -d "$rdDirectory" ]]; then
        sudo -u "$loggedInUser" mkdir "$rdDirectory"
        if [[ -d "$rdDirectory" ]]; then
            echo "RD Desktop directory created for ${loggedInUser}"
            echo "Creating Remote Director user preferences..."
            createPrefs
            checkPrefs
        else
            echo "Failed to create RD Desktop directory directory"
            echo "Unable to create standard user preferences for Remote Director"
            exit 1
        fi
    else
        echo "RD Desktop directory for ${loggedInUser} found"
        checkPrefs
    fi
fi
exit 0