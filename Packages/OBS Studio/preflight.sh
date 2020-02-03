#!/bin/bash

########################################################################
#                        OBS Studio - preinstall                       #
#################### Written by Phil Walker Jan 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#OBS Studio application
obsStudio="/Applications/OBS.app"
#SyphonInject application
syphonInject="/Applications/SyphonInject.app"
#OBS Studio Old Plugins
obsPlugins="/Library/Application Support/obs-studio"
#SASyphonInjector OSAX (Open Scripting Architecture Extension)
saSyphonInjector="/Library/ScriptingAdditions/SASyphonInjector.osax"

########################################################################
#                            Functions                                 #
########################################################################

function postCheck ()
{
#Confirm that all redundant content has been removed successfully
if [[ ! -d "$syphonInject" ]] && [[ ! -d "$obsPlugins" ]] && [[ ! -d "$saSyphonInjector" ]]; then
  echo "Previous version content removed successfully"
else
  echo "Previous version content removal FAILED!"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ ! -d "$obsStudio" ]]; then
  echo "Previous version of OBS Studio not found"
  echo "Starting install..."
else
  #Get the currently installed OBS Studio version. If 24.0.3 or previous, clean up of redundant additional content required
  obsVersionShort=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' /Applications/OBS.app/Contents/Info.plist | sed -e 's/\.//g' 2>/dev/null)
  obsVersionFull=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' /Applications/OBS.app/Contents/Info.plist 2>/dev/null)
    if [[ "$obsVersionShort" -le "2403" ]]; then
      echo "OBS Studio ${obsVersionFull} currently installed"
      echo "Removing previous version content"
      rm -rf "$obsStudio" 2>/dev/null
      rm -rf "$syphonInject" 2>/dev/null
      rm -rf "$obsPlugins" 2>/dev/null
      rm -rf "$saSyphonInjector" 2>/dev/null
      postCheck
      echo "Starting install..."
    else
      echo "OBS Studio ${obsVersionFull} currently installed"
      rm -rf "$obsStudio" 2>/dev/null
      echo "Starting install..."
    fi
fi

exit 0
