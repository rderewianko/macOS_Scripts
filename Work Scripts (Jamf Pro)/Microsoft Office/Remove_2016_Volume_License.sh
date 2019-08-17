#!/bin/bash

########################################################################
#                 Remove Office 2016 Volume License                    #
################## Written by Phil Walker July 2019 ####################
########################################################################

if [[ -f "/Library/Preferences/com.microsoft.office.licensingV2.plist" ]]; then
  echo "Office 2016 volume license found"
  echo "Removing Office 2016 volume license..."
  rm -f "/Library/Preferences/com.microsoft.office.licensingV2.plist"
    if [[ ! -f "/Library/Preferences/com.microsoft.office.licensingV2.plist" ]]; then
      echo "Office 2016 volume license successfully removed"
    else
      echo "Office 2016 volume license removal FAILED"
      echo "Please delete /Library/Preferences/com.microsoft.office.licensingV2.plist manually"
    fi
else
  echo "Office 2016 volume license not found, nothing to do"
fi
