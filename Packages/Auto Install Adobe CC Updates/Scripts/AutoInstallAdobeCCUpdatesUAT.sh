#!/bin/sh

########################################################################
#    Automatically Install All Adobe CC Application Updates Silently   #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Path to Adobe Remote Update Manager
rumBinary=/usr/local/bin/RemoteUpdateManager
#Log file
rumLog=/var/tmp/AutoInstallAdobeCCUpdates.log
#UAT Log
rumLogUAT=/var/tmp/AutoInstallAdobeCCUpdates_UAT.log

########################################################################
#                            Functions                                 #
########################################################################

function checkConnectivity ()
{
#Check if the Mac has internet connectivity
ping -q -c 1 -W 1 www.apple.com >/dev/null 2>&1
if [[ $? == "0" ]]; then
    echo "Internet connectivity detected"
else
    echo "Internet connectivity not detected, exiting"
    exit 0
fi
}

function checkPower ()
{
##Check if the Mac is on ac power or has over 50% battery available
pwrAdapter=$(/usr/bin/pmset -g ps)
batteryPercentage=$(/usr/bin/pmset -g ps | grep -i "InternalBattery" | awk '{print $3}' | cut -c1-3 | sed 's/%//g')
if [[ ${pwrAdapter} =~ "AC Power" ]] || [[ ${batteryPercentage} -ge "50" ]]; then
	echo "Sufficient power detected"
else
	echo "AC power not detected, exiting"
    exit 0
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

#Confirm RUM is installed
if [[ ! -f "$rumBinary" ]]; then
    echo "Adobe Remote Update Manager not installed"
    exit 0
else
    #Check basic requirements for successful update installations
    checkConnectivity
    checkPower

    #Remove previous log
    if [[ -f $rumLog ]]; then
        rm -f $rumLog 2>/dev/null
        if [[ ! -f $rumLog ]]; then
            echo "Previous temp log file deleted successfully"
        fi
    else
        echo "Previous temp log file not found"
    fi

    #Create log file, check for available updates and output results to the log
    touch $rumLog
    $rumBinary --action=list > $rumLog

    #Check if any updates are required
    updatesCheck=$(cat $rumLog)
    if [[ "$updatesCheck" =~ "Following Updates are applicable" ]]; then
        echo "Updates available"
        echo "Installing all available updates..."
        #Install all available updates and output result to the log
        $rumBinary --action=install >> $rumLogUAT
        echo "Successful update installations detailed in the UAT log"
    else
        echo "No available updates found"
    fi
fi

exit 0