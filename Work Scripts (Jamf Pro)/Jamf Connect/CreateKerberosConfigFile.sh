#!/bin/zsh

########################################################################
#               Set Kerberos Configuration Default Realm               #
#################### Written by Phil Walker Mar 2021 ###################
########################################################################

# Workaround for a bug in anything previous to macOS Big Sur
########################################################################
#                            Variables                                 #
########################################################################
############ Variables for Jamf Pro Parameters - Start #################
# Kerberos realm e.g. BAUER-UK.BAUERMEDIA.GROUP
defaultRealm="$4"
############ Variables for Jamf Pro Parameters - End ###################

# Kerberos config file
kerbConfig="/etc/krb5.conf"
# OS product version
osVersion=$(sw_vers -productVersion)
# Mac model
macModel=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# Big Sur major version
bigSurMajor="11"

########################################################################
#                         Script starts here                           #
########################################################################

# Load is-at-least
autoload is-at-least
if ! is-at-least "$bigSurMajor" "$osVersion"; then
    echo "${macModel} running ${osVersion}, creating Kerberos configuration file..." 
    # Check for an existing krb5 config file
    if [[ -e "$kerbConfig" ]]; then
        rm "$kerbConfig"
    fi
    echo "[libdefaults]" >> "$kerbConfig"
    echo "default_realm = ${defaultRealm}" >> "$kerbConfig"
    postCheck=$(cat "$kerbConfig")
    if [[ "$postCheck" =~ "$defaultRealm" ]]; then
        echo "Kerberos configuration file created successfully"
    else
        echo "Failed to create Kerberos configuration file!"
        exit 1
    fi
else
    echo "${macModel} running ${osVersion}, no requirement to create a Kerberos configuration file"
fi
exit 0