#!/bin/bash

########################################################################
#                Create Missing User Profile Directories               #
################### Written by Phil Walker Sep 2020 ####################
########################################################################
# Required to fix user profiles affected by NoLoAD bug 161
# https://gitlab.com/orchardandgrove-oss/NoMADLogin-AD/-/issues/161

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
#Get the current user's home directory
UserHomeDirectory=$(/usr/bin/dscl . -read /Users/"$loggedInUser" NFSHomeDirectory | awk '{print $2}')
# Potential Missing Directories
homeDirectories=( "${UserHomeDirectory}/Desktop" "${UserHomeDirectory}/Movies" \
"${UserHomeDirectory}/Music" "${UserHomeDirectory}/Pictures" )
homePublic="${UserHomeDirectory}/Public"

########################################################################
#                         Script starts here                           #
########################################################################

# Loop through the array and create and missing folders
for dir in "${homeDirectories[@]}"; do
    if [[ ! -d "$dir" ]]; then
        sudo -u "$loggedInUser" /bin/mkdir "$dir"
        /bin/chmod 700 "$dir"
        if [[ -d "$dir" ]]; then
            echo "Created ${dir}"
        fi
    fi
done
# Create the public directory if required
if [[ ! -d "$homePublic" ]]; then
    sudo -u "$loggedInUser" /bin/mkdir "$homePublic"
    /bin/chmod 755 "$homePublic"
    if [[ -d "$homePublic" ]]; then
        echo "Created ${homePublic}"
    fi
fi
exit 0