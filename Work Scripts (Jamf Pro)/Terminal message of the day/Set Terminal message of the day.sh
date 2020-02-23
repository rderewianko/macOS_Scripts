#!/bin/sh

########################################################################
#                   Set Terminal message of the day                    #
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get hostname
hostName=$(scutil --get HostName)
#Get Serial Number
serialNumber=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
#Get OS version
osVersion=$(sw_vers -productVersion)
#Get OS build
osBuild=$(sw_vers -buildVersion)
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
/bin/echo "***** This Apple Workstation ($hostName - $serialNumber - $osVersion $osBuild) belongs to $companyName *****" >> /etc/motd
/bin/echo "" >> /etc/motd

if [[ $(cat /etc/motd | grep "Bauer") != "" ]]; then
        echo "Terminal message of the day set"
else
        echo "Failed to set the Terminal message of the day!"
        exit 1
fi

exit 0
