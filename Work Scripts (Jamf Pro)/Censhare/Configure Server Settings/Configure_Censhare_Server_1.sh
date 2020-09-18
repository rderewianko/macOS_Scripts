#!/bin/bash

########################################################################
#             Configure Censhare Server Settings - Server 1            #
#################### Written by Phil Walker Sept 2020 ##################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Censhare preference directory
prefDirectory="/Users/${loggedInUser}/Library/Preferences/censhare"

########################################################################
#                            Functions                                 #
########################################################################

function setServerSettings ()
{
read -r -d '' serverSettings <<"EOF"
<?xml version="1.0" encoding="UTF-8"?>
<root xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus" xmlns:new-fct="http://www.censhare.com/xml/3.0.0/new-fct" xmlns:new-val="http://www.censhare.com/xml/3.0.0/new-val">
  <hosts>
    <host name="censhare 1" databasename="bauerdb" authentication-method="" disable-trust-manager="true" compressionlevel="0" url="frmis://lxappcenprod01.bauer-uk.bauermedia.group:30546/corpus.RMIServerSSL">
      <censhare-vfs use="1"/>
      <proxy use="0"/>
    </host>
  </hosts>
</root>
EOF
su -l "$loggedInUser" -c "/bin/cat > ${prefDirectory}/hosts.xml<<<'$serverSettings'"
}

function checkServerSettings ()
{
serverSettings=$(cat < "${prefDirectory}"/hosts.xml | grep "lxappcenprod01")
if [[ "$serverSettings" != "" ]]; then
    echo "Censhare server settings set successfully"
    echo "Censhare 1 will be available in the client"
else
    echo "Failed to set Censhare server settings"
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
            setServerSettings
            checkServerSettings
        fi
    else
        setServerSettings
        checkServerSettings
    fi
fi
exit 0