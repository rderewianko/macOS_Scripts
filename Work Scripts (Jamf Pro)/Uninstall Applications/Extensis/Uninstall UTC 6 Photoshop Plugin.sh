#!/bin/bash

########################################################################
#          Universal Type Client Photoshop CS6 plugin removal          #
#################### Written by Phil Walker Nov 2019 ###################
########################################################################

#UTC Photoshop CS6 plugin
utcPSCS6Plugin="/Applications/Adobe Photoshop CS6/Plug-ins/Automate/ExtensisFontManagementPSCS6.plugin"
utcPSCS6PluginLeftOver="/Applications/Adobe Photoshop CS6/Plug-ins/Automate/Contents"

if [[ -e "$utcPSCS6Plugin" ]] || [[ -e "$utcPSCS6PluginLeftOver" ]]; then
  echo "UTC Photoshop CS6 plugin found, removing..."
  rm -rf "$utcPSCS6Plugin" > /dev/null 2>&1
  rm -rf "$utcPSCS6PluginLeftOver" > /dev/null 2>&1
  #re-populate variables
  utcPSCS6Plugin="/Applications/Adobe Photoshop CS6/Plug-ins/Automate/ExtensisFontManagementPSCS6.plugin"
  utcPSCS6PluginLeftOver="/Applications/Adobe Photoshop CS6/Plug-ins/Automate/Contents"
    if [[ ! -e "$utcPSCS6Plugin" ]] || [[ ! -e "$utcPSCS6PluginLeftOver" ]]; then
      echo "UTC Photoshop CS6 plugin removed"
    else
      echo "UTC Photoshop CS6 plugin still installed, please delete the UTC Photoshop CS6 plugin manually"
      echo "If this is not deleted, an error message will appear on ever launch of Photoshop CS6"
      exit 1
    fi
else
  echo "UTC Photoshop CS6 plugin not found, nothing to do"
fi

exit 0
