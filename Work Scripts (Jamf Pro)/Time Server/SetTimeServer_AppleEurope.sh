#!/bin/sh

########################################################################
#                    Set Time Server to Apple Europe                   #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

appleEurope="time.euro.apple.com"
primaryTimeServer=$(cat /etc/ntp.conf | sed -n 1p | awk '{print $2}')

########################################################################
#                            Functions                                 #
########################################################################

function postCheck ()
{
# Check the top priority Time Server is now Apple Europe
local timeServer=$(cat /etc/ntp.conf | sed -n 1p | awk '{print $2}')
if [[ "$timeServer" == "$appleEurope" ]]; then
    echo "Time Server changed to $timeServer"
else
    echo "Time Server change FAILED!"
    echo "Time Server still set to $timeServer"
fi
}


########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$primaryTimeServer" != "$appleEurope" ]]; then
    echo "Settings Time Server to Apple Europe..."
    /usr/sbin/systemsetup -setnetworktimeserver time.euro.apple.com >/dev/null 2>&1
    /usr/sbin/systemsetup -setusingnetworktime on >/dev/null 2>&1
    postCheck
else
    echo "Time Server already set to $primaryTimeServer"
fi

exit 0
