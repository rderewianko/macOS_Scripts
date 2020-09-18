#!/bin/bash

########################################################################
#                   Configure Censhare Server Settings                 #
#################### Written by Phil Walker Sept 2020 ##################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Server Host Name
hostName="$4"
# Server URL
serverURL="$5"
# Additional Server Host Name
addHostName="$6"
# Additional Server URL
addServerURL="$7"
# Server Name/Names
serverName="$8"
############ Variables for Jamf Pro Parameters - End ###################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# censhare preference directory
prefDirectory="/Users/${loggedInUser}/Library/Preferences/censhare"
# jamfHelper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Helper Icon
if [[ -d "/Applications/censhare Client.app" ]]; then
    # Helper Icon Censhare
    helperIcon="/Applications/censhare Client.app/Contents/Resources/censhare Client.icns"
else
    # helper Icon SS
    helperIcon="/Library/Application Support/JAMF/bin/Management Action.app/Contents/Resources/Self Service.icns"
fi
# Helper Icon Problem
helperIconProblem="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
# Helper Title
helperTitle="Message from Bauer IT"
# Helper heading
helperHeading="        Censhare Server Settings        "

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperSuccess ()
{
# check for updates available helper
"$jamfHelper" -windowType utility -icon "$helperIcon" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "Censhare server settings set successfully ✅

${serverName} will be available in the client" -alignDescription natural -timeout 10 -button1 "Ok" -defaultButton "1"
}

function jamfHelperFailed ()
{
# check for updates available helper
"$jamfHelper" -windowType utility -icon "$helperIconProblem" \
-title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "⚠️ Failed to set Censhare server settings ⚠️

Please contact the IT Service Desk for assistance" -alignDescription natural -timeout 20 -button1 "Ok" -defaultButton "1"
}

function setSingularServer ()
{
read -r -d '' serverSettings <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<root xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus" xmlns:new-fct="http://www.censhare.com/xml/3.0.0/new-fct" xmlns:new-val="http://www.censhare.com/xml/3.0.0/new-val">
  <hosts>
    <host name="${hostName}" databasename="bauerdb" authentication-method="" disable-trust-manager="true" compressionlevel="0" url="frmis://${serverURL}.bauer-uk.bauermedia.group:30546/corpus.RMIServerSSL">
      <censhare-vfs use="1"/>
      <proxy use="0"/>
    </host>
  </hosts>
</root>
EOF
su -l "$loggedInUser" -c "/bin/cat > ${prefDirectory}/hosts.xml<<<'$serverSettings'"
}

function setMultipleServers ()
{
read -r -d '' serverSettings <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<root xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus" xmlns:new-fct="http://www.censhare.com/xml/3.0.0/new-fct" xmlns:new-val="http://www.censhare.com/xml/3.0.0/new-val">
  <hosts>
    <host name="${hostName}" databasename="bauerdb" authentication-method="" disable-trust-manager="true" compressionlevel="0" url="frmis://${serverURL}.bauer-uk.bauermedia.group:30546/corpus.RMIServerSSL">
      <censhare-vfs use="1"/>
      <proxy use="0"/>
    </host>
    <host name="${addHostName}" databasename="bauerdb" authentication-method="" disable-trust-manager="true" compressionlevel="0" url="frmis://${addServerURL}.bauer-uk.bauermedia.group:30546/corpus.RMIServerSSL">
      <censhare-vfs use="1"/>
      <proxy use="0"/>
    </host>
  </hosts>
</root>
EOF
su -l "$loggedInUser" -c "/bin/cat > ${prefDirectory}/hosts.xml<<<'$serverSettings'"
}

function checkSingular ()
{
serverSettings=$(cat < "${prefDirectory}"/hosts.xml | grep "$serverURL")
if [[ "$serverSettings" != "" ]]; then
    jamfHelperSuccess
    echo "Censhare server settings set successfully"
    echo "${serverName} will be available in the client"
    exit 0
else
    echo "Failed to set Censhare server settings"
    jamfHelperFailed
    exit 1
fi
}

function checkMultiple ()
{
serverSettings=$(cat < "${prefDirectory}"/hosts.xml | grep -c "$serverURL\|$addServerURL")
if [[ "$serverSettings" -eq "2" ]]; then
    jamfHelperSuccess
    echo "Censhare server settings set successfully"
    echo "${serverName} will be available in the client"
    exit 0
else
    echo "Failed to set Censhare server settings"
    jamfHelperFailed
    exit 1
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
	echo "No user currently logged in, exiting..."
    exit 0
else
    if [[ ! -d "$prefDirectory" ]]; then
        sudo -u "$loggedInUser" mkdir "$prefDirectory"
        if [[ -d "$prefDirectory" ]]; then
            echo "Censhare preference directory created for ${loggedInUser}"
            echo "Settings Censhare server settings..."
            if [[ "$addHostName" == "" ]]; then
                setSingularServer
                checkSingular
            else
                setMultipleServers
                checkMultiple
            fi
        fi
    else
        if [[ "$addHostName" == "" ]]; then
            setSingularServer
            checkSingular
        else
            setMultipleServers
            checkMultiple
        fi
    fi
fi