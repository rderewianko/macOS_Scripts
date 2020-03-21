#!/bin/sh

#preinstall

/usr/local/jamf/bin/jamf checkJSSconnection -retry 0 >/dev/null 2>&1

if [[ $? == "0" ]]; then
    echo "Jamf Pro server reachable"
    exit 0
else
    echo "Jamf Pro server currently unreachable"
    exit 1
fi
