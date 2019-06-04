#!/bin/bash

########################################################################
#          Revert to default power management sleep settings           #
################## Written by Phil Walker June 2019 ####################
########################################################################

# Get hibernate mode status
hibernateModeStatus=$(pmset -g | grep "hibernatemode" | awk '{ print $2 }')
# Get standby mode status
standbyStatus=$(pmset -g | grep -v "standbydelayhigh\|standbydelaylow\|highstandbythreshold" | grep "standby" | awk '{ print $2 }')
# Get standbydelaylow status
standbydelaylowStatus=$(pmset -g | grep "standbydelaylow" | awk '{ print $2 }')
# Get standbydelayhigh status
standbydelayhighStatus=$(pmset -g | grep "standbydelayhigh" | awk '{ print $2 }')

echo "Power Management Settings"
echo "hibernatemode = $hibernateModeStatus"
echo "standby = $standbyStatus"
echo "standbydelaylowStatus = $standbydelaylowStatus"
echo "standbydelayhighStatus = $standbydelayhighStatus"
echo ""

echo "Checking if changes are required..."
if [[ "$hibernateModeStatus" -ne "3" ]];then
  echo "Changing hibernatemode to 3"
  pmset -a hibernatemode 3
else
  echo "hibernatemode already set to 3, nothing to do"
fi

if [[ "$standbyStatus" -ne "1" ]];then
  echo "Changing standby to 1"
  pmset -a standby 1
else
  echo "standby already set to 1, nothing to do"
fi

if [[ "$standbydelaylowStatus" -ne "10800" ]];then
  echo "Changing standbydelaylow to 3 hours"
  pmset -a standbydelaylow 10800
else
  echo "standbydelaylow already set to 3 hours, nothing to do"
fi

if [[ "$standbydelayhighStatus" -ne "86400" ]];then
  echo "Changing standbydelayhigh to 24 hours"
  pmset -a standbydelayhigh 86400
else
  echo "standbydelayhigh already set to 24 hours, nothing to do"
fi

# re-populate all variables
hibernateModeStatus=$(pmset -g | grep "hibernatemode" | awk '{ print $2 }')
standbyStatus=$(pmset -g | grep -v "standbydelayhigh\|standbydelaylow\|highstandbythreshold" | grep "standby" | awk '{ print $2 }')
standbydelaylowStatus=$(pmset -g | grep "standbydelaylow" | awk '{ print $2 }')
standbydelayhighStatus=$(pmset -g | grep "standbydelayhigh" | awk '{ print $2 }')

echo ""
echo "Power Management Settings"
echo "hibernatemode = $hibernateModeStatus"
echo "standby = $standbyStatus"
echo "standbydelaylowStatus = $standbydelaylowStatus"
echo "standbydelayhighStatus = $standbydelayhighStatus"

exit 0
