#!/bin/zsh

########################################################################
#                  Installed Waves Plug-Ins Versions                   #
################### written by Phil Walker Jan 2021 ####################
########################################################################

wavesPlugins=$(find "/Library/Application Support/Avid/Audio/Plug-Ins" -iname "*WaveShell*" -type d -maxdepth 1)
for plugin in ${(f)wavesPlugins}; do
		pluginVersion=$(defaults read "${plugin}/Contents/Info.plist" CFBundleGetInfoString)
        echo "$pluginVersion"
done