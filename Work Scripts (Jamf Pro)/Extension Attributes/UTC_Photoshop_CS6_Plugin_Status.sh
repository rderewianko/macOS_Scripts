#!/bin/bash

########################################################################
#          Universal Type Client Photoshop CS6 Plugin status           #
################## Written by Phil Walker Nov 2019 #####################
########################################################################

#UTC Photoshop CS6 plugin
utcPSCS6Plugin="/Applications/Adobe Photoshop CS6/Plug-ins/Automate/ExtensisFontManagementPSCS6.plugin"
utcPSCS6PluginLeftOver="/Applications/Adobe Photoshop CS6/Plug-ins/Automate/Contents"

if [[ -e "$utcPSCS6Plugin" ]] || [[ -e "$utcPSCS6PluginLeftOver" ]]; then
  echo "<result>Found</result>"
else
  echo "<result>Not Found</result>"
fi

exit 0
