#!/bin/sh

########################################################################
#           Current Jamf Pro Server URL - Extension Attribute          #
################## Written by Phil Walker Mar 2020 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#JSS URL
jamfProURL="Your Jamf Pro URL"
#Get the current JSS url from the Jamf plist
currentURL=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ $jamfProURL =~ "$currentURL" ]]; then 
    echo "<result>URL Correct</result>"
else
    echo "<result>$currentURL</result>"
fi

exit 0
