#!/bin/bash

########################################################################
#          Amend power management settings to allow MacBooks to        #
#                       enter a full sleep state                       #
################## Written by Phil Walker June 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get Mac model and marketing name
macModel=$(sysctl -n hw.model)
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# Get OS Version
OSFull=$(sw_vers -productVersion)
# Get hibernate mode status
hibernateMode=$(pmset -g | grep "hibernatemode" | awk '{ print $2 }')
# Get standby mode status
standbyStatus=$(pmset -g | grep -v "standbydelayhigh\|standbydelaylow\|highstandbythreshold" | grep "standby" | awk '{ print $2 }')
# Get standbydelaylow status
standbydelaylowStatus=$(pmset -g | grep "standbydelaylow" | awk '{ print $2 }')
# Get standbydelayhigh status
standbydelayhighStatus=$(pmset -g | grep "standbydelayhigh" | awk '{ print $2 }')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$macModel" =~ "MacBook" ]]; then

  echo "Power Management Settings"
  echo "hibernatemode = $hibernateMode"
  echo "standby = $standbyStatus"
  echo "standbydelaylowStatus = $standbydelaylowStatus"
  echo "standbydelayhighStatus = $standbydelayhighStatus"
  echo ""

  echo "Checking if changes are required..."
    if [[ "$hibernateMode" -ne "25" ]];then
      echo "Changing hibernatemode to 25"
      pmset -a hibernatemode 25
    else
      echo "hibernatemode already set to 25, nothing to do"
    fi

    if [[ "$standbyStatus" -ne "1" ]];then
      echo "Changing standby to 1"
      pmset -a standby 1
    else
      echo "standby already set to 1, nothing to do"
    fi

    if [[ "$standbydelaylowStatus" -ne "600" ]];then
      echo "Changing standbydelaylow to 10 minutes"
      pmset -a standbydelaylow 600
    else
      echo "standbydelaylow already set to 10 minutes, nothing to do"
    fi

    if [[ "$standbydelayhighStatus" -ne "600" ]];then
      echo "Changing standbydelayhigh to 10 minutes"
      pmset -a standbydelayhigh 600
    else
      echo "standbydelayhigh already set to 10 minutes, nothing to do"
    fi

    # re-populate all variables
    hibernateMode=$(pmset -g | grep "hibernatemode" | awk '{ print $2 }')
    standbyStatus=$(pmset -g | grep -v "standbydelayhigh\|standbydelaylow\|highstandbythreshold" | grep "standby" | awk '{ print $2 }')
    standbydelaylowStatus=$(pmset -g | grep "standbydelaylow" | awk '{ print $2 }')
    standbydelayhighStatus=$(pmset -g | grep "standbydelayhigh" | awk '{ print $2 }')

    echo ""
    echo "Power Management Settings"
    echo "hibernatemode = $hibernateMode"
    echo "standby = $standbyStatus"
    echo "standbydelaylowStatus = $standbydelaylowStatus"
    echo "standbydelayhighStatus = $standbydelayhighStatus"

else

  echo "$macModelFull running $OSFull, power management settings have not been changed"
  echo "This policy will only amend the power settings for MacBooks"

fi

exit 0
