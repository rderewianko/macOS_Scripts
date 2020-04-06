#!/bin/sh

########################################################################
#           Reset All Privacy Preferences Policy Control Data          #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

# Self Service script

# Kill System Preferences
killall "System Preferences" >/dev/null 2>&1

# Reset all privacy consent decisions
tccutil reset All
echo "All Privacy Preferences Policy Control Data Reset"

# Reboot to apply all changes
/usr/local/jamf/bin/jamf policy -event "immediate_restart"
echo "Rebooting to complete the process"

exit 0