#!/bin/bash

########################################################################
#                   Set Terminal message of the day                    #
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get hostname
hostName=$(scutil --get HostName)
#Get Serial Number
serial=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
#Get OS version
OS=$(sw_vers -productVersion)
#Get OS build
build=$(sw_vers -buildVersion)
#Company name
companyName="Your Company"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -e /etc/motd ]]; then
        rm /etc/motd
fi
/usr/bin/touch /etc/motd
/bin/chmod 644 /etc/motd
/bin/echo "" >> /etc/motd
/bin/echo "***** This Apple Workstation ($hostName - $serial - $OS $build) belongs to $companyName *****" >> /etc/motd
/bin/echo "" >> /etc/motd

exit 0
