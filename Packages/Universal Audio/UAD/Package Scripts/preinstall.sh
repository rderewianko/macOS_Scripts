#!/bin/bash

########################################################################
#       Uninversal Audio Digital Software and Plugins Preinstall       #
########################################################################

#All of the below taken from UAD package.
#It has ben edited to remove elements not required and elements that are not designed for package deployment

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#####################################################################
# unix uninstall apollo
#####################################################################

# Shut down UAD Meter
osascript -e 'tell application id "com.uaudio.uad_meter" to quit'

# Shut down the Console Shell App
# Normally, the Mixer Server shuts this down when it exits. But we shipped with a bug
# that causes that not to happen. So, we need to shut down the Console Shell App from the
# installer, in case the user is installing over the version with the bug.
osascript -e 'tell application id "com.uaudio.console" to quit'

# Shut down the mixer server
osascript -e 'tell application id "com.uaudio.ua_mixer_engine" to quit'

# Shut down the Realtime Rack
osascript -e 'tell application id "com.uaudio.ua_realtime_rack" to quit'

# Remove the UAD Mixer Engine login item
# When we invoke the UAD Mixer Engine, it creates lock files in ~/Library/Caches/Juce/
# VISE scripts run with EUID=0 to provide root privileges, but we don't want the lock files created as user root, so we call the mixer engine in a new bash instance to reset the EUID
if [ -d /Library/Application\ Support/Universal\ Audio/Apollo/UA\ Mixer\ Engine.app ]; then
  su "$loggedInUser" -c "/Library/Application\ Support/Universal\ Audio/Apollo/UA\ Mixer\ Engine.app/Contents/MacOS/UA\ Mixer\ Engine -removelogin"
fi

# remove the pre-release startup item if present
if [ -d /Library/Application\ Support/Universal\ Audio/Apollo/UAD\ Mixer\ Engine.app ]; then
  su "$loggedInUser" -c "/Library/Application\ Support/Universal\ Audio/Apollo/UAD\ Mixer\ Engine.app/Contents/MacOS/UAD\ Mixer\ Engine -removelogin"
fi

# Uninstall all plugin.zip's
if [ -d /Library/Application\ Support/Universal\ Audio/UAD\ Updater.app ]; then
  su "$loggedInUser" -c "/Library/Application\ Support/Universal\ Audio/UAD\ Updater.app/Contents/MacOS/UAD\ Updater -n"
fi

# Remove Meter Launcher
rm -rf /Library/Application\ Support/Universal\ Audio/UAD\ Meter\ Launcher.app

# Remove the contents of the Apollo directory
rm -rf /Library/Application\ Support/Universal\ Audio/Apollo/UA\ CoreAudio\ Control\ Panel.app
rm -rf /Library/Application\ Support/Universal\ Audio/Apollo/UAD\ CoreAudio\ Control\ Panel.app #pre-release name
rm -rf /Library/Application\ Support/Universal\ Audio/Apollo/UA\ Mixer\ Engine.app
rm -rf /Library/Application\ Support/Universal\ Audio/Apollo/UAD\ Mixer\ Engine.app #pre-release name

# Remove UA Media Engine
rm -rf /Applications/Universal\ Audio/UA\ Media\ Engine.app

# Remove Realtime Rack
rm -rf /Applications/Universal\ Audio/Realtime\ Rack.app
rm -rf /Applications/Universal\ Audio/Live\ Rack.app
rm -rf /Library/Application\ Support/Universal\ Audio/Plug-In\ Icons

# Remove the console
rm -rf /Applications/Universal\ Audio/Console.app
rm -rf /Applications/Powered\ Plug-Ins\ Tools/Console.app # pre-7.4 path
rm -rf /Applications/Powered\ Plug-Ins\ Tools/UAD\ Console.app # pre-release name

# Remove VST, AU and RTAS Console Recall plugins
rm -Rf /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/Console\ Recall.vst
rm -Rf /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/UAD\ Console\ Recall.vst # pre-release name

rm -Rf /Library/Audio/Plug-Ins/Components/Console\ Recall.component
rm -Rf /Library/Audio/Plug-Ins/Components/UAD\ Console\ Recall.component # pre-release name

rm -rf /Library/Application\ Support/Digidesign/Plug-Ins/Universal\ Audio/Console\ Recall.dpm
rm -rf /Library/Application\ Support/Digidesign/Plug-Ins/Universal\ Audio/UAD\ Console\ Recall.dpm # pre-release name

# Remove any JUCE lock files that may have been created
rm -f $HOME/Library/Caches/Juce/juceAppLock_UA*
rm -f $HOME/Library/Caches/Juce/juceAppLock_Console*
rm -f $HOME/Library/Caches/Juce/MixerServerControlLock

rm -f /Users/$loggedInUser/Library/Caches/Juce/juceAppLock_UA*
rm -f /Users/$loggedInUser/Library/Caches/Juce/juceAppLock_Console*
rm -f /Users/$loggedInUser/Library/Caches/Juce/MixerServerControlLock

# Remove the Apollo plug-in directory, if it exists
rm -rf /Library/Application\ Support/Universal\ Audio/Apollo/Plugins

# Remove TCAT components only installed by the TCAT installer, not ours
# Use sudo because they are owned by root
rm -rf /Library/Audio/MIDI\ Drivers/UAFWAudioMIDIDriver
rm -rf /Library/Audio/MIDI\ Drivers/UAFWAudio.bundle
rm -rf /Library/Audio/MIDI\ Drivers/UAFWAudio.plugin
rm -rf /System/Library/PreferencePanes/UAFWAudio.prefPane
rm -rf /bin/UAFWAudio
rm -rf /Library/StartupItems/UAFWAudio
rm -rf /Library/Application\ Support/UAFWAudio/UAFWAudio


# Remove TCAT components installed by our installer, except kext
# (this is removed on uninstall via 'Unix Delete kexts' script action)
rm -rf /Library/LaunchDaemons/com.uaudio.UAFWAudio.plist
rm -rf /Library/Application\ Support/UAFWAudio

# Always remove older-named versions of drivers, but not the current version
# since that will either be written over on install, or removed on uninstall via
# 'Unix Delete kexts' script action
rm -Rf /System/Library/Extensions/UADDriver.kext
rm -Rf /System/Library/Extensions/UAD2Pcie.kext
#rm -Rf /System/Library/Extensions/UAD2System.kext

rm -Rf /Library/Frameworks/UAD\ GUI\ Library.framework
rm -Rf /Library/Frameworks/UAD-2\ GUI\ Support.framework
rm -Rf /Library/Frameworks/UAD-2\ Plugin\ Support.framework
rm -Rf /Library/Frameworks/UAD-2\ SDK\ Support.framework
rm -Rf /Library/Frameworks/UA\ Juce*
rm -Rf /Library/Frameworks/UADHelper.app
rm -f /Library/CFMSupport/UAD\ GUI\ Library\ X
rm -f /Library/CFMSupport/UADHelper
rm -Rf /Library/StartupItems/UADDriverLoader

# do not remove directory if there are unexpected contents
if [ -d /Library/Application\ Support/Universal\ Audio ]; then
  rm -Rf /Library/Application\ Support/Universal\ Audio/UAD-1\ Powered\ Plug-Ins/UAD*.vst
  rm -f /Library/Application\ Support/Universal\ Audio/UAD-1\ Powered\ Plug-Ins/.DS_Store
  rm -f /Library/Application\ Support/Universal\ Audio/UAD-1\ Powered\ Plug-Ins/Icon?
  if [ -d /Library/Application\ Support/Universal\ Audio/UAD-1\ Powered\ Plug-Ins ]; then
    rmdir /Library/Application\ Support/Universal\ Audio/UAD-1\ Powered\ Plug-Ins
  fi

#do not remove directory if there are unexpected contents
  rm -Rf /Library/Application\ Support/Universal\ Audio/UAD-2\ Powered\ Plug-Ins/UAD*.vst
  rm -f /Library/Application\ Support/Universal\ Audio/UAD-2\ Powered\ Plug-Ins/.DS_Store
  rm -f /Library/Application\ Support/Universal\ Audio/UAD-2\ Powered\ Plug-Ins/Icon?
  if [ -d /Library/Application\ Support/Universal\ Audio/UAD-2\ Powered\ Plug-Ins ]; then
  rmdir /Library/Application\ Support/Universal\ Audio/UAD-2\ Powered\ Plug-Ins
  fi

#do not remove directory if there are unexpected contents
  if [ -d /Library/Application\ Support/Universal\ Audio/Apollo ]; then
    rmdir /Library/Application\ Support/Universal\ Audio/Apollo
  fi

  rm -Rf /Library/Application\ Support/Universal\ Audio/Firmware/UAD-2/FirmwareUpdate*
  rm -f /Library/Application\ Support/Universal\ Audio/Firmware/UAD-2/.DS_Store
  if [ -d /Library/Application\ Support/Universal\ Audio/Firmware/UAD-2 ]; then
    rmdir /Library/Application\ Support/Universal\ Audio/Firmware/UAD-2
  fi
  rm -f /Library/Application\ Support/Universal\ Audio/Firmware/.DS_Store
  if [ -d /Library/Application\ Support/Universal\ Audio/Firmware ]; then
    rmdir /Library/Application\ Support/Universal\ Audio/Firmware
  fi
  rm -f /Library/Application\ Support/Universal\ Audio/Icon?
  rm -f /Library/Application\ Support/Universal\ Audio/.DS_Store
 #echo "debug code, contents of Application Support/UA folder" 1>&2
  #ls /Library/Application\ Support/Universal\ Audio 1>&2

  # clean up RTAS files
  rm -Rf /Library/Application\ Support/Universal\ Audio/com.Universal\ Audio.fxshared.bundle
  if [ -d /Library/Application\ Support/Universal\ Audio/RTAS ]; then
    rm -Rf /Library/Application\ Support/Universal\ Audio/RTAS/Template.dpm
    rm -f /Library/Application\ Support/Universal\ Audio/RTAS/.DS_Store
    rmdir /Library/Application\ Support/Universal\ Audio/RTAS
  fi

  # clean up .irz files
  if [ -d /Library/Application\ Support/Universal\ Audio/Data ]; then
    rm -f /Library/Application\ Support/Universal\ Audio/Data/Ocean\ Way\ Studios/OceanWayStudios.irz
    rm -f /Library/Application\ Support/Universal\ Audio/Data/Ocean\ Way\ Studios/.DS_Store
    rmdir /Library/Application\ Support/Universal\ Audio/Data/Ocean\ Way\ Studios
	rm -f /Library/Application\ Support/Universal\ Audio/Data/Capitol\ Chambers/CapitolChambers.irz
    rm -f /Library/Application\ Support/Universal\ Audio/Data/Capitol\ Chambers/.DS_Store
    rmdir /Library/Application\ Support/Universal\ Audio/Data/Capitol\ Chambers
    rm -f /Library/Application\ Support/Universal\ Audio/Data/.DS_Store
    rmdir /Library/Application\ Support/Universal\ Audio/Data
  fi

  #this will always contain the Presets directory which we do not remove
  #rmdir /Library/Application\ Support/Universal\ Audio
 fi


# Delete "/Applications/Universal Audio" files

if [ -d /Applications/Universal\ Audio ]; then

  rm -Rf /Applications/Universal\ Audio/UAD\ Meter\ \&\ Control\ Panel.app
  rm -Rf /Library/Application\ Support/Universal\ Audio/UAD\ Updater.app
  rm -Rf /Applications/Universal\ Audio/Console.app

  rm -f /Applications/Universal\ Audio/Icon?
  rm -f /Applications/Universal\ Audio/.DS_Store
  rm -f /Applications/Universal\ Audio/UA.xml

  rm -Rf /Applications/Universal\ Audio/Uninstall\ Universal\ Audio\ Software.app
  # Remove incorrect uninstaller folder that might have been created (see DAV-129)
  echo "Removing incorrect uninstaller folder!"
  rm -Rf /Applications/Universal\ Audio/Uninstall\ Universal\ Audio\ Software.localized

  rmdir /Applications/Universal\ Audio
fi


# Delete all pre-7.4 "/Applications/Powered Plug-Ins Tools" files

if [ -d /Applications/Powered\ Plug-Ins\ Tools ]; then
  rm -f /Applications/Powered\ Plug-Ins\ Tools/UADManual.pdf
  rm -f /Applications/Powered\ Plug-Ins\ Tools/UAD-Xpander.pdf
  rm -f /Applications/Powered\ Plug-Ins\ Tools/ReadMe.rtf
  if [ -d /Applications/Powered\ Plug-Ins\ Tools/Documentation ]; then
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/UAD\ System\ Manual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/UAD\ Plug-Ins\ Manual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/Apollo\ Hardware\ Manual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/Apollo\ Software\ Manual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/ATA_Manual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/bx_digital\ V2\ Manual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/bx_digital\ V2\ Mono\ Manual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/SPL\ Vitalizer\ MK2-T\ Manual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/UADManual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/UAD\ RTAS\ ReadMe.rtf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/Oxford\ EQ\ Manual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/Oxford\ Plug-Ins\ Toolbar\ and\ Preset\ Manager\ Manual.pdf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/Documentation/*.pdf
    rmdir /Applications/Powered\ Plug-Ins\ Tools/Documentation
   fi
    rm -f /Applications/Powered\ Plug-Ins\ Tools/ATA_Manual.pdf #old location
  rm -f /Applications/Powered\ Plug-Ins\ Tools/UAD\ RTAS\ ReadMe.rtf #old location
  rm -f /Applications/Powered\ Plug-Ins\ Tools/QuickStart.pdf
  rm -f /Applications/Powered\ Plug-Ins\ Tools/ReadMe-VST.rtf
  rm -f /Applications/Powered\ Plug-Ins\ Tools/QuickStart-VST.pdf
  rm -f /Applications/Powered\ Plug-Ins\ Tools/ReadMe-AU.rtf
  rm -f /Applications/Powered\ Plug-Ins\ Tools/QuickStart-AU.pdf
  rm -f /Applications/Powered\ Plug-Ins\ Tools/ReadMe-RTAS.rtf
  rm -f /Applications/Powered\ Plug-Ins\ Tools/QuickStart-RTAS.pdf
  rm -Rf /Applications/Powered\ Plug-Ins\ Tools/UAD-1\ Meter.app
  rm -Rf /Applications/Powered\ Plug-Ins\ Tools/UAD\ Meter.app
  rm -Rf /Applications/Powered\ Plug-Ins\ Tools/UAD\ Meter\ \&\ Control\ Panel.app
  rm -Rf /Applications/Powered\ Plug-Ins\ Tools/Console.app
  rm -Rf /Applications/Powered\ Plug-Ins\ Tools/UAD\ Console.app # pre-release name

  rm -Rf /Applications/Powered\ Plug-Ins\ Tools/UA\ RTAS\ Utility.app
  if [ -d /Applications/Powered\ Plug-Ins\ Tools/UAD-1\ Driver\ Utility\ Folder ]; then
    rm -Rf /Applications/Powered\ Plug-Ins\ Tools/UAD-1\ Driver\ Utility\ Folder/UA\ RTAS\ Utility.app
    rm -Rf /Applications/Powered\ Plug-Ins\ Tools/UAD-1\ Driver\ Utility\ Folder/UAD-1\ Driver\ Utility.app
    rm -f /Applications/Powered\ Plug-Ins\ Tools/UAD-1\ Driver\ Utility\ Folder/UAD-1\ Driver\ Utility\ ReadMe.rtf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/UAD-1\ Driver\ Utility\ Folder/Icon?
    rm -f /Applications/Powered\ Plug-Ins\ Tools/UAD-1\ Driver\ Utility\ Folder/.DS_Store
    rmdir /Applications/Powered\ Plug-Ins\ Tools/UAD-1\ Driver\ Utility\ Folder
  fi
  rm -f /Applications/Powered\ Plug-Ins\ Tools/UAD-1\ Installer\ Log
  if [ -d /Applications/Powered\ Plug-Ins\ Tools/RTAS ]; then
    rm -f /Applications/Powered\ Plug-Ins\ Tools/RTAS/*
    rm -f /Applications/Powered\ Plug-Ins\ Tools/RTAS/.DS_Store
    rm -Rf /Applications/Powered\ Plug-Ins\ Tools/RTAS/VST\ to\ RTAS\ Adapter\ Config.app
    rm -Rf /Applications/Powered\ Plug-Ins\ Tools/RTAS/UAD\ RTAS\ Installer.app
    rmdir /Applications/Powered\ Plug-Ins\ Tools/RTAS
  fi
  if [ -d /Applications/Powered\ Plug-Ins\ Tools/UAD\ Driver\ Utility\ Folder ]; then
    rm -Rf /Applications/Powered\ Plug-Ins\ Tools/UAD\ Driver\ Utility\ Folder/UA\ RTAS\ Utility.app
    rm -Rf /Applications/Powered\ Plug-Ins\ Tools/UAD\ Driver\ Utility\ Folder/UAD-1\ Driver\ Utility.app
    rm -Rf /Applications/Powered\ Plug-Ins\ Tools/UAD\ Driver\ Utility\ Folder/UAD-2\ Driver\ Utility.app
    rm -f /Applications/Powered\ Plug-Ins\ Tools/UAD\ Driver\ Utility\ Folder/UAD\ Driver\ Utility\ ReadMe.rtf
    rm -f /Applications/Powered\ Plug-Ins\ Tools/UAD\ Driver\ Utility\ Folder/Icon?
    rm -f /Applications/Powered\ Plug-Ins\ Tools/UAD\ Driver\ Utility\ Folder/.DS_Store
    rmdir /Applications/Powered\ Plug-Ins\ Tools/UAD\ Driver\ Utility\ Folder
  fi
  rm -f /Applications/Powered\ Plug-Ins\ Tools/Icon?
  rm -f /Applications/Powered\ Plug-Ins\ Tools/.DS_Store
#delete directory only if no unexpected contents
  rm -f /Applications/Powered\ Plug-Ins\ Tools/UA.xml
  rmdir /Applications/Powered\ Plug-Ins\ Tools
fi

# remove UAD Meter that was mistakenly placed in Applications for some internal builds
if [ -d /Applications/UAD\ Meter\ \&\ Control\ Panel.app ]; then
  rm -Rf /Applications/UAD\ Meter\ \&\ Control\ Panel.app
fi

# remove mono wrappers
if [ -d /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/Mono ]; then
  rm -Rf /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/Mono/UAD*
  rm -f /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/Mono/.DS_Store
  rm -f /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/Mono/Icon?
  rmdir /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/Mono
fi

# remove VST plug-ins
if [ -d /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins ]; then
  rm -Rf /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/UAD*
  rm -Rf /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/Console\ Recall.vst
  rm -f /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/.DS_Store
  rm -f /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins/Icon?
  rmdir /Library/Audio/Plug-Ins/VST/Powered\ Plug-Ins
fi

# remove AU plug-ins
rm -Rf /Library/Audio/Plug-Ins/Components/UAD*.component
rm -Rf /Library/Audio/Plug-Ins/Components/Console\ Recall.component

# remove RTAS plug-ins
rm -Rf /Library/Application\ Support/Digidesign/Plug-Ins/VW_UAD*
if [ -d /Library/Application\ Support/Digidesign/Plug-Ins/RTAS\ Powered\ Plug-Ins ]; then
  rm -Rf /Library/Application\ Support/Digidesign/Plug-Ins/RTAS\ Powered\ Plug-Ins/UAD*.dpm
  rmdir /Library/Application\ Support/Digidesign/Plug-Ins/RTAS\ Powered\ Plug-Ins
fi
if [ -d /Library/Application\ Support/Digidesign/Plug-Ins/Universal\ Audio ]; then
  rm -Rf /Library/Application\ Support/Digidesign/Plug-Ins/Universal\ Audio/UAD*.dpm
  rm -Rf /Library/Application\ Support/Digidesign/Plug-Ins/Universal\ Audio/Console\ Recall.dpm
  rm -f /Library/Application\ Support/Digidesign/Plug-Ins/Universal\ Audio/.DS_Store
  rm -f /Library/Application\ Support/Digidesign/Plug-Ins/Universal\ Audio/Icon?
  rmdir /Library/Application\ Support/Digidesign/Plug-Ins/Universal\ Audio
fi

# remove AAX plug-ins
if [ -d /Library/Application\ Support/Avid/Audio/Plug-Ins/Universal\ Audio/ ]; then
  rm -Rf /Library/Application\ Support/Avid/Audio/Plug-Ins/Universal\ Audio/UAD*.aaxplugin
  rm -Rf /Library/Application\ Support/Avid/Audio/Plug-Ins/Universal\ Audio/Console\ Recall.aaxplugin
  rm -f /Library/Application\ Support/Avid/Audio/Plug-Ins/Universal\ Audio/.DS_Store
  rm -f /Library/Application\ Support/Avid/Audio/Plug-Ins/Universal\ Audio/Icon?
  rmdir /Library/Application\ Support/Avid/Audio/Plug-Ins/Universal\ Audio
fi

rm -f /Library/Application\ Support/Digidesign/Plug-Ins/test.bin
rm -Rf /Library/Application\ Support/FXpansion/com.fxpansion.fxshared2.bundle/

rm -f /Library/Application\ Support/Universal\ Audio/UA.xml
rm -fR /Library/Application\ Support/Universal\ Audio/com.Universal Audio.fxshared.bundle


#####################################################################
# delete kexts
#####################################################################

rm -Rf /System/Library/Extensions/UAD2System.kext
rm -Rf /System/Library/Extensions/UAFWAudio.kext

# Remove any drivers from new Mavericks location that might have been
# installed by newer UAD software; need this to support back-revving
rm -Rf /Library/Extensions/UAD2System.kext
rm -Rf /Library/Extensions/UAFWAudio.kext


#####################################################################
# delete uad1-only mono
#####################################################################

##############################
# clean up
##############################
#UAD-1 only mono
VSTMONODIR="/Library/Audio/Plug-Ins/VST/Powered Plug-Ins/Mono"

if [ -d "${VSTMONODIR}/UAD DelayComp(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD DelayComp(m).vst"
fi
# this is NOT a UAD-1 only plug, disabling due to issue with a crash
if [ -d "${VSTMONODIR}/UAD Fairchild Mono.vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Fairchild Mono.vst"
fi
if [ -d "${VSTMONODIR}/UAD GateComp(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD GateComp(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD ModFilter(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD ModFilter(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Nigel(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Nigel(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Phasor(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Phasor(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Preflex(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Preflex(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD TrackAdv(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD TrackAdv(m).vst"
fi

if [ -d "${VSTMONODIR}/UAD TremModEcho(m).vst" ]; then
rm -Rf "${VSTMONODIR}/UAD TremModEcho(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Tremolo(m).vst" ]; then
rm -Rf "${VSTMONODIR}/UAD Tremolo(m).vst"
fi


#####################################################################
# delete uad1-only vst
#####################################################################

#UAD-1 only vst wrapped plugins
VSTDIR="/Library/Audio/Plug-Ins/VST/Powered Plug-Ins"

if [ -d "${VSTDIR}/UAD DelayComp.vst" ]; then
  rm -Rf "${VSTDIR}/UAD DelayComp.vst"
fi
if [ -d "${VSTDIR}/UAD GateComp.vst" ]; then
  rm -Rf "${VSTDIR}/UAD GateComp.vst"
fi
if [ -d "${VSTDIR}/UAD ModFilter.vst" ]; then
  rm -Rf "${VSTDIR}/UAD ModFilter.vst"
fi
if [ -d "${VSTDIR}/UAD Nigel.vst" ]; then
  rm -Rf "${VSTDIR}/UAD Nigel.vst"
fi
if [ -d "${VSTDIR}/UAD Phasor.vst" ]; then
  rm -Rf "${VSTDIR}/UAD Phasor.vst"
fi
if [ -d "${VSTDIR}/UAD Preflex.vst" ]; then
  rm -Rf "${VSTDIR}/UAD Preflex.vst"
fi
if [ -d "${VSTDIR}/UAD TrackAdv.vst" ]; then
  rm -Rf "${VSTDIR}/UAD TrackAdv.vst"
fi
if [ -d "${VSTDIR}/UAD TremModEcho.vst" ]; then
  rm -Rf "${VSTDIR}/UAD TremModEcho.vst"
fi
if [ -d "${VSTDIR}/UAD Tremolo.vst" ]; then
  rm -Rf "${VSTDIR}/UAD Tremolo.vst"
fi

#####################################################################
# delete uad1-only au
#####################################################################

#UAD-1 AU only vst wrapped plugins
AUCOMPDIR="/Library/Audio/Plug-Ins/Components"

if [ -d "${AUCOMPDIR}/UAD DelayComp.component" ]; then
  rm -Rf "${AUCOMPDIR}/UAD DelayComp.component"
fi
if [ -d "${AUCOMPDIR}/UAD Fairchild Mono.component" ]; then
  rm -Rf "${AUCOMPDIR}/UAD Fairchild Mono.component"
fi
if [ -d "${AUCOMPDIR}/UAD GateComp.component" ]; then
  rm -Rf "${AUCOMPDIR}/UAD GateComp.component"
fi
if [ -d "${AUCOMPDIR}/UAD ModFilter.component" ]; then
  rm -Rf "${AUCOMPDIR}/UAD ModFilter.component"
fi
if [ -d "${AUCOMPDIR}/UAD Nigel.component" ]; then
  rm -Rf "${AUCOMPDIR}/UAD Nigel.component"
fi
if [ -d "${AUCOMPDIR}/UAD Phasor.component" ]; then
  rm -Rf "${AUCOMPDIR}/UAD Phasor.component"
fi
if [ -d "${AUCOMPDIR}/UAD Preflex.component" ]; then
  rm -Rf "${AUCOMPDIR}/UAD Preflex.component"
fi
if [ -d "${AUCOMPDIR}/UAD TrackAdv.component" ]; then
  rm -Rf "${AUCOMPDIR}/UAD TrackAdv.component"
fi
if [ -d "${AUCOMPDIR}/UAD TremModEcho.component" ]; then
  rm -Rf "${AUCOMPDIR}/UAD TremModEcho.component"
fi
if [ -d "${AUCOMPDIR}/UAD Tremolo.component" ]; then
  rm -Rf "${AUCOMPDIR}/UAD Tremolo.component"
fi


#####################################################################
# delete uad2-only mono ---
# Note: This script was disabled in the VISE project
#####################################################################

#UAD-2 Mono only VST plugins delete
VSTMONODIR="/Library/Audio/Plug-Ins/VST/Powered Plug-Ins/Mono"

if [ -d "${VSTMONODIR}/UAD Cooper Time Cube(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Cooper Time Cube(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD EL7 FATSO Jr(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD EL7 FATSO Jr(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD EL7 FATSO Sr(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD EL7 FATSO Sr(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD EMT 250(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD EMT 250(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Manley Massive Passive(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Manley Massive Passive(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Manley Massive Passive MST(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Manley Massive Passive MST(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Precision Enhancer Hz(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Precision Enhancer Hz(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD EP-34 Tape Echo(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD EP-34 Tape Echo(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Studer A800(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Studer A800(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD SSL E Channel Strip(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD SSL E Channel Strip(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD SSL G Bus Compressor(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD SSL G Bus Compressor(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Lexicon 224(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Lexicon 224(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD SPL Vitalizer MK2-T(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD SPL Vitalizer MK2-T(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD bx_digital V2 Mono(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD bx_digital V2 Mono(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Ampex ATR-102(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Ampex ATR-102(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD Little Labs VOG(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD Little Labs VOG(m).vst"
fi
if [ -d "${VSTMONODIR}/UAD MXR Flanger-Doubler(m).vst" ]; then
  rm -Rf "${VSTMONODIR}/UAD MXR Flanger-Doubler(m).vst"
fi

#####################################################################
# delete uad2-only vst ---
# Note: This script was disabled in the VISE project
#####################################################################

#UAD-2 only plugins
VSTDIR="/Library/Audio/Plug-Ins/VST/Powered Plug-Ins"

if [ -d "${VSTDIR} Cooper Time Cube.vst" ]; then
  rm -Rf "${VSTDIR} Cooper Time Cube.vst"
fi
if [ -d "${VSTDIR} EL7 FATSO Jr.vst" ]; then
  rm -Rf "${VSTDIR} EL7 FATSO Jr.vst"
fi
if [ -d "${VSTDIR} EL7 FATSO Sr.vst" ]; then
  rm -Rf "${VSTDIR} EL7 FATSO Sr.vst"
fi
if [ -d "${VSTDIR} EMT 250.vst" ]; then
  rm -Rf "${VSTDIR} EMT 250.vst"
fi
if [ -d "${VSTDIR} Manley Massive Passive.vst" ]; then
  rm -Rf "${VSTDIR} Manley Massive Passive.vst"
fi
if [ -d "${VSTDIR} Manley Massive Passive MST.vst" ]; then
  rm -Rf "${VSTDIR} Manley Massive Passive MST.vst"
fi
if [ -d "${VSTDIR} Precision Enhancer Hz.vst" ]; then
  rm -Rf "${VSTDIR} Precision Enhancer Hz.vst"
fi
if [ -d "${VSTDIR} EP-34 Tape Echo.vst" ]; then
  rm -Rf "${VSTDIR} EP-34 Tape Echo.vst"
fi
if [ -d "${VSTDIR} Studer A800.vst" ]; then
  rm -Rf "${VSTDIR} Studer A800.vst"
fi
if [ -d "${VSTDIR} SSL E Channel Strip.vst" ]; then
  rm -Rf "${VSTDIR} SSL E Channel Strip.vst"
fi
if [ -d "${VSTDIR} SSL G Bus Compressor.vst" ]; then
  rm -Rf "${VSTDIR} SSL G Bus Compressor.vst"
fi
if [ -d "${VSTDIR} Lexicon 224.vst" ]; then
  rm -Rf "${VSTDIR} Lexicon 224.vst"
fi
if [ -d "${VSTDIR} SPL Vitalizer MK2-T.vst" ]; then
  rm -Rf "${VSTDIR} SPL Vitalizer MK2-T.vst"
fi
if [ -d "${VSTDIR} bx_digital V2.vst" ]; then
  rm -Rf "${VSTDIR} bx_digital V2.vst"
fi
if [ -d "${VSTDIR} bx_digital V2 Mono.vst" ]; then
  rm -Rf "${VSTDIR} bx_digital V2 Mono.vst"
 fi
if [ -d "${VSTDIR} Ampex ATR-102.vst" ]; then
  rm -Rf "${VSTDIR} Ampex ATR-102.vst"
fi
if [ -d "${VSTDIR} Little Labs VOG.vst" ]; then
  rm -Rf "${VSTDIR} Little Labs VOG.vst"
fi
if [ -d "${VSTDIR} MXR Flanger-Doubler.vst" ]; then
  rm -Rf "${VSTDIR} MXR Flanger-Doubler.vst"
fi


#####################################################################
# delete uad2-only au ---
# Note: This script was disabled in the VISE project
#####################################################################

#UAD-2 AU only plugins
AUCOMPDIR="/Library/Audio/Plug-Ins/Components"

if [ -d "${AUCOMPDIR} Cooper Time Cube.vst" ]; then
  rm -Rf "${AUCOMPDIR} Cooper Time Cube.vst"
fi
if [ -d "${AUCOMPDIR} EL7 FATSO Jr.vst" ]; then
  rm -Rf "${AUCOMPDIR} EL7 FATSO Jr.vst"
fi
if [ -d "${AUCOMPDIR} EL7 FATSO Sr.vst" ]; then
  rm -Rf "${AUCOMPDIR} EL7 FATSO Sr.vst"
fi
if [ -d "${AUCOMPDIR} EMT 250.vst" ]; then
  rm -Rf "${AUCOMPDIR} EMT 250.vst"
fi
if [ -d "${AUCOMPDIR} Manley Massive Passive.vst" ]; then
  rm -Rf "${AUCOMPDIR} Manley Massive Passive.vst"
fi
if [ -d "${AUCOMPDIR} Manley Massive Passive MST.vst" ]; then
  rm -Rf "${AUCOMPDIR} Manley Massive Passive MST.vst"
fi
if [ -d "${AUCOMPDIR} Precision Enhancer Hz.vst" ]; then
  rm -Rf "${AUCOMPDIR} Precision Enhancer Hz.vst"
fi
if [ -d "${AUCOMPDIR} EP-34 Tape Echo.vst" ]; then
  rm -Rf "${AUCOMPDIR} EP-34 Tape Echo.vst"
fi
if [ -d "${AUCOMPDIR} Studer A800.vst" ]; then
  rm -Rf "${AUCOMPDIR} Studer A800.vst"
fi
if [ -d "${AUCOMPDIR} SSL E Channel Strip.vst" ]; then
  rm -Rf "${AUCOMPDIR} SSL E Channel Strip.vst"
fi
if [ -d "${AUCOMPDIR} SSL G Bus Compressor.vst" ]; then
  rm -Rf "${AUCOMPDIR} SSL G Bus Compressor.vst"
fi
if [ -d "${AUCOMPDIR} Lexicon 224.vst" ]; then
  rm -Rf "${AUCOMPDIR} Lexicon 224.vst"
fi
if [ -d "${AUCOMPDIR} SPL Vitalizer MK2-T.vst" ]; then
  rm -Rf "${AUCOMPDIR} SPL Vitalizer MK2-T.vst"
fi
if [ -d "${AUCOMPDIR} bx_digital V2.vst" ]; then
  rm -Rf "${AUCOMPDIR} bx_digital V2.vst"
fi
if [ -d "${AUCOMPDIR} bx_digital V2 Mono.vst" ]; then
  rm -Rf "${AUCOMPDIR} bx_digital V2 Mono.vst"
 fi
if [ -d "${AUCOMPDIR} Ampex ATR-102.vst" ]; then
  rm -Rf "${AUCOMPDIR} Ampex ATR-102.vst"
fi
if [ -d "${AUCOMPDIR} Little Labs VOG.vst" ]; then
  rm -Rf "${AUCOMPDIR} Little Labs VOG.vst"
fi
if [ -d "${AUCOMPDIR} MXR Flanger-Doubler.vst" ]; then
  rm -Rf "${AUCOMPDIR} MXR Flanger-Doubler.vst"
fi

#####################################################################
# delete apollo-only
#####################################################################

UADIR="/Library/Application Support/Universal Audio/UAD-2 Powered Plug-Ins"

VSTDIR="/Library/Audio/Plug-Ins/VST/Powered Plug-Ins"

AUCOMPDIR="/Library/Audio/Plug-Ins/Components"

if [ -d "${UADIR}/Console Recall.vst" ]; then
  rm -Rf "${UADIR}/Console Recall.vst"
fi

if [ -d "${VSTDIR}/Console Recall.vst" ]; then
  rm -Rf "${VSTDIR}/Console Recall.vst"
fi

if [ -d "${AUCOMPDIR}/Console Recall.component" ]; then
  rm -Rf "${AUCOMPDIR}/Console Recall.component"
fi

# at this point, the pro tools plugs are not installed yet

#####################################################################
# delete old doc
#####################################################################

rm -f "/Applications/Universal Audio/Documentation/"*.pdf
rm -f "/Applications/Universal Audio/ReadMe.rtf"
rmdir /Applications/Universal\ Audio/Documentation

# clean up of pre 7.4 doc
rm -f "/Applications/Powered Plug-Ins Tools/Documentation/UAD RTAS ReadMe.rtf"

rm -f "/Applications/Powered Plug-Ins Tools/UADManual.pdf"

rm -f "/Applications/Powered Plug-Ins Tools/SPL Vitalizer MK2-T Manual.pdf"
rm -f "/Applications/Powered Plug-Ins Tools/bx_digital V2 Manual.pdf"
rm -f "/Applications/Powered Plug-Ins Tools/bx_digital V2 Mono Manual.pdf"

rm -f "/Applications/Powered Plug-Ins Tools/UAD RTAS ReadMe.rtf"
rm -f "/Applications/Powered Plug-Ins Tools/ATA_Manual.pdf"

# clean up of post 6.4 doc
rm -f "/Applications/Powered Plug-Ins Tools/Documentation/"*.pdf

#####################################################################
# delete RTAS pre-install
#####################################################################

rm -f /Applications/Powered\ Plug-Ins\ Tools/RTAS/*
# the 5.8 release shipped with these two RTAS dummy files as folders rather than files
if [ -d /Applications/Powered\ Plug-Ins\ Tools/RTAS/68 ]; then
rmdir /Applications/Powered\ Plug-Ins\ Tools/RTAS/68
fi
if [ -d /Applications/Powered\ Plug-Ins\ Tools/RTAS/69 ]; then
rmdir /Applications/Powered\ Plug-Ins\ Tools/RTAS/69
fi
rm -f /Applications/Powered\ Plug-Ins\ Tools/RTAS/.DS_Store
rm -Rf /Applications/Powered\ Plug-Ins\ Tools/RTAS/VST\ to\ RTAS\ Adapter\ Config.app
if [ -d /Applications/Powered\ Plug-Ins\ Tools/RTAS ]; then
rmdir /Applications/Powered\ Plug-Ins\ Tools/RTAS
fi
rm -f /Library/Application\ Support/Digidesign/Plug-Ins/test.bin
#remove 5.9.1 and earlier UA wrapped plugs
rm -Rf /Library/Application\ Support/Digidesign/Plug-Ins/VW_UAD*
if [ -d /Library/Application\ Support/Digidesign/Plug-Ins/RTAS\ Powered\ Plug-Ins ]; then
rm -Rf /Library/Application\ Support/Digidesign/Plug-Ins/RTAS\ Powered\ Plug-Ins/UAD*
rm -f /Library/Application\ Support/Digidesign/Plug-Ins/RTAS\ Powered\ Plug-Ins/.DS_Store
rmdir /Library/Application\ Support/Digidesign/Plug-Ins/RTAS\ Powered\ Plug-Ins
fi

#this should not be needed, used for bug 4170
#earlier v600 builds had left this folder on an uninstall
if [ -d /Applications/Universal\Audio ];then
rm -Rf /Applications/Universal\ Audio
fi


#####################################################################
# rtas plug-in settings rename
#####################################################################

###############################################################
# Check for old folder, if old folder exist, check for new folder
# if new folder exist, do nothing, otherwise, rename old folder to new folder
# Force a rename regardless if RTAS option is checked since this script is
# in the RTAS bundle checklist.  Perform the conditional check there.
# Don't worry about changing the directory, stack will pop to the correct directory
# once this script is done.
###############################################################
if [ -d "/Library/Application Support/Digidesign/Plug-In Settings" ]; then
cd "/Library/Application Support/Digidesign/Plug-In Settings"
if [ -d "VST UAD 4K Buss " ]; then
if [ ! -d "UAD 4K Bus Comp" ]; then
	mv -f "VST UAD 4K Buss "		"UAD 4K Bus Comp"
fi
fi
if [ -d "VST UAD 4K Chann" ]; then
if [ ! -d "UAD 4K Chn Strip" ]; then
	mv -f "VST UAD 4K Chann"		"UAD 4K Chn Strip"
fi
fi
if [ -d "VST UAD 1176LN" ]; then
if [ ! -d "UAD 1176LN" ]; then
	mv -f "VST UAD 1176LN"			"UAD 1176LN"
fi
fi
if [ -d "VST UAD 1176SE" ]; then
if [ ! -d "UAD 1176SE" ]; then
	mv -f "VST UAD 1176SE"			"UAD 1176SE"
fi
fi
if [ -d "VST UAD Cambridg" ]; then
if [ ! -d "UAD Cambridge" ]; then
	mv -f "VST UAD Cambridg"		"UAD Cambridge"
fi
fi
if [ -d "VST UAD Cooper T" ]; then
if [ ! -d "UAD CooprTmCbe" ]; then
	mv -f "VST UAD Cooper T"		"UAD CooprTmCbe"
fi
fi
if [ -d "VST UAD CS-1" ]; then
if [ ! -d "UAD CS-1" ]; then
	mv -f "VST UAD CS-1"			"UAD CS-1"
fi
fi
if [ -d "VST UAD dbx 160" ]; then
if [ ! -d "UAD dbx 160" ]; then
	mv -f "VST UAD dbx 160"			"UAD dbx 160"
fi
fi
if [ -d "VST UAD DelayCom" ]; then
if [ ! -d "UAD DelayComp" ]; then
	mv -f "VST UAD DelayCom"		"UAD DelayComp"
fi
fi
if [ -d "VST UAD DM-1" ]; then
if [ ! -d "UAD DM-1" ]; then
	mv -f "VST UAD DM-1"			"UAD DM-1"
fi
fi
if [ -d "VST UAD DM-1L" ]; then
if [ ! -d "UAD DM-1L" ]; then
	mv -f "VST UAD DM-1L"			"UAD DM-1L"
fi
fi
if [ -d "VST UAD DreamVer" ]; then
if [ ! -d "UAD DreamVerb" ]; then
	mv -f "VST UAD DreamVer"    	"UAD DreamVerb"
fi
fi
if [ -d "VST UAD EL7 FATS" ]; then
if [ ! -d "UAD EL7 FATSO" ]; then
	mv -f "VST UAD EL7 FATS"	"UAD EL7 FATSO"
	cd "UAD EL7 FATSO"
	mv -f "EL7 FATSO Jr"		"UAD EL7 FATSO Jr"
	mv -f "EL7 FATSO Sr"		"UAD EL7 FATSO Sr"
	cd ..
	if [ ! -d "UAD EL7 FATSO Jr" ]; then
	mv -f UAD\ EL7\ FATSO/UAD\ EL7\ FATSO\ Jr		UAD\ EL7\ FATSO\ Jr
fi
	if [ ! -d "UAD EL7 FATSO Sr" ]; then
	mv -f UAD\ EL7\ FATSO/UAD\ EL7\ FATSO\ Sr		UAD\ EL7\ FATSO\ Sr
fi
fi
fi
if [ -d "VST UAD EMT 140" ]; then
if [ ! -d "UAD EMT 140" ]; then
	mv -f "VST UAD EMT 140"			"UAD EMT 140"
fi
fi
if [ -d "VST UAD EMT 250" ]; then
if [ ! -d "UAD EMT 250" ]; then
	mv -f "VST UAD EMT 250"			"UAD EMT 250"
fi
fi
if [ -d "VST UAD EP-34 Ta" ]; then
if [ ! -d "UAD EP-34 Echo" ]; then
	mv -f "VST UAD EP-34 Ta"    	"UAD EP-34 Echo"
fi
fi
if [ -d "VST UAD EX-1" ]; then
if [ ! -d "UAD EX-1" ]; then
	mv -f "VST UAD EX-1"			"UAD EX-1"
fi
fi
if [ -d "VST UAD Fairchil" ]; then
if [ ! -d "UAD Fairchild" ]; then
	mv -f "VST UAD Fairchil"    	"UAD Fairchild"
fi
fi
if [ -d "VST UAD GateComp" ]; then
if [ ! -d "UAD GateComp" ]; then
	mv -f "VST UAD GateComp"    	"UAD GateComp"
fi
fi
if [ -d "VST UAD Harrison" ]; then
if [ ! -d "UAD Harrison 32C" ]; then
	mv -f "VST UAD Harrison"		"UAD Harrison 32C"
fi
fi
if [ -d "VST UAD Helios 6" ]; then
if [ ! -d "UAD Helios 69" ]; then
	mv -f "VST UAD Helios 6"		"UAD Helios 69"
fi
fi
if [ -d "VST UAD LA2A" ]; then
if [ ! -d "UAD LA2A" ]; then
	mv -f "VST UAD LA2A"			"UAD LA2A"
fi
fi
if [ -d "VST UAD LA3A" ]; then
if [ ! -d "UAD LA3A" ]; then
	mv -f "VST UAD LA3A"			"UAD LA3A"
fi
fi
if [ -d "VST UAD Lex 224" ]; then
if [ ! -d "UAD Lexicon 224" ]; then
	mv -f "VST UAD Lex 224"			"UAD Lexicon 224"
fi
fi
if [ -d "VST UAD Little L" ]; then
if [ ! -d "UAD LilLabs IBP" ]; then
	mv -f "VST UAD Little L"    	"UAD LilLabs IBP"
fi
fi
if [ -d "VST UAD MMP" ]; then
if [ ! -d "UAD MasPassive" ]; then
	mv -f "VST UAD MMP"				"UAD MasPassive"
fi
fi
if [ -d "VST UAD MMP MST" ]; then
if [ ! -d "UAD MasPasMST" ]; then
	mv -f "VST UAD MMP MST"			"UAD MasPasMST"
fi
fi
if [ -d "VST UAD ModFilte" ]; then
if [ ! -d "UAD ModFilter" ]; then
	mv -f "VST UAD ModFilte"		"UAD ModFilter"
fi
fi
if [ -d "VST UAD Moog Fil" ]; then
if [ ! -d "UAD Moog Filter" ]; then
	mv -f "VST UAD Moog Fil"		"UAD Moog Filter"
fi
fi
if [ -d "VST UAD Neve 88R" ]; then
if [ ! -d "UAD Neve 88RS" ]; then
	mv -f "VST UAD Neve 88R"		"UAD Neve 88RS"
fi
fi
if [ -d "VST UAD Neve 107" ]; then
if [ ! -d "UAD Neve 1073" ]; then
	mv -f "VST UAD Neve 107"		"UAD Neve 1073"
fi
fi
if [ -d "VST UAD Neve 108" ]; then
if [ ! -d "UAD Neve 1081" ]; then
	mv -f "VST UAD Neve 108"		"UAD Neve 1081"
fi
fi
if [ -d "VST UAD Neve 311" ]; then
if [ ! -d "UAD Neve 31102" ]; then
	mv -f "VST UAD Neve 311"		"UAD Neve 31102"
fi
fi
if [ -d "VST UAD Neve 336" ]; then
if [ ! -d "UAD Neve 33609" ]; then
	mv -f "VST UAD Neve 336"		"UAD Neve 33609"
fi
fi
if [ -d "VST UAD Nigel" ]; then
if [ ! -d "UAD Nigel" ]; then
	mv -f "VST UAD Nigel"			"UAD Nigel"
fi
fi
if [ -d "VST UAD Phasor" ]; then
if [ ! -d "UAD Phasor" ]; then
	mv -f "VST UAD Phasor"			"UAD Phasor"
fi
fi
if [ -d "VST UAD Prec Hz" ]; then
if [ ! -d "UAD P Enh Hz" ]; then
	mv -f "VST UAD Prec Hz"			"UAD P Enh Hz"
fi
fi
if [ -d "VST UAD Precisio" ]; then
if [ ! -d "UAD Precision" ]; then
	mv -f "VST UAD Precisio"		"UAD Precision"
	cd "UAD Precision"
	mv -f "Precision Buss Comp"		"UAD P BusComp"
	mv -f "Precision DeEsser"		"UAD P De-Esser"
	mv -f "Precision Enhancer kHz"	"UAD P Enh kHz"
	mv -f "Precision EQ"			"UAD P Equalizer"
	mv -f "Precision Limiter"		"UAD P Limiter"
	mv -f "Precision Maximizer"		"UAD P Maximizer"
	mv -f "Precision Multiband"		"UAD P Multiband"
	cd ..
	if [ ! -d "UAD P BusComp" ]; then
	mv -f UAD\ Precision/UAD\ P\ BusComp		UAD\ P\ BusComp
fi
	if [ ! -d "UAD P De-Esser" ]; then
	mv -f UAD\ Precision/UAD\ P\ De-Esser		UAD\ P\ De-Esser
fi
	if [ ! -d "UAD P Enh kHz" ]; then
	mv -f UAD\ Precision/UAD\ P\ Enh\ kHz		UAD\ P\ Enh\ kHz
fi
	if [ ! -d "UAD P Equalizer" ]; then
	mv -f UAD\ Precision/UAD\ P\ Equalizer		UAD\ P\ Equalizer
fi
	if [ ! -d "UAD P Limiter" ]; then
	mv -f UAD\ Precision/UAD\ P\ Limiter		UAD\ P\ Limiter
fi
	if [ ! -d "UAD P Maximizer" ]; then
	mv -f UAD\ Precision/UAD\ P\ Maximizer		UAD\ P\ Maximizer
fi
	if [ ! -d "UAD P Multiband" ]; then
	mv -f UAD\ Precision/UAD\ P\ Multiband		UAD\ P\ Multiband
fi
fi
fi
if [ -d "VST UAD Preflex" ]; then
if [ ! -d "UAD Preflex" ]; then
	mv -f "VST UAD Preflex"			"UAD Preflex"
fi
fi
if [ -d "VST UAD Pultec" ]; then
if [ ! -d "UAD Pultec" ]; then
	mv -f "VST UAD Pultec"			"UAD Pultec"
fi
fi
if [ -d "VST UAD Pultec-P" ]; then
if [ ! -d "UAD Pultec-Pro" ]; then
	mv -f "VST UAD Pultec-P"	    "UAD Pultec-Pro"
fi
fi
if [ -d "VST UAD RealVerb" ]; then
if [ ! -d "UAD RealVerb-Pro" ]; then
	mv -f "VST UAD RealVerb"	    "UAD RealVerb-Pro"
fi
fi
if [ -d "VST UAD Roland C" ]; then
if [ ! -d "UAD Roland CE-1" ]; then
	mv -f "VST UAD Roland C"		"UAD Roland CE-1"
fi
fi
if [ -d "VST UAD Roland D" ]; then
if [ ! -d "UAD Roland Dim D" ]; then
	mv -f "VST UAD Roland D"		"UAD Roland Dim D"
fi
fi
if [ -d "VST UAD Roland R" ]; then
if [ ! -d "UAD Roland RE201" ]; then
	mv -f "VST UAD Roland R"	    "UAD Roland RE201"
fi
fi
if [ -d "VST UAD RS-1" ]; then
if [ ! -d "UAD RS-1" ]; then
	mv -f "VST UAD RS-1"			"UAD RS-1"
fi
fi
if [ -d "VST UAD SPL Tran" ]; then
if [ ! -d "UAD SPL Trans D" ]; then
	mv -f "VST UAD SPL Tran"		"UAD SPL Trans D"
fi
fi
if [ -d "VST UAD SSL E Ch" ]; then
if [ ! -d "UAD SSL E ChnStp" ]; then
	mv -f "VST UAD SSL E Ch"		"UAD SSL E ChnStp"
fi
fi
if [ -d "VST UAD SSL G Bu" ]; then
if [ ! -d "UAD SSL G BusCmp" ]; then
	mv -f "VST UAD SSL G Bu"		"UAD SSL G BusCmp"
fi
fi
if [ -d "VST UAD Studer A" ]; then
if [ ! -d "UAD Studer A800" ]; then
	mv -f "VST UAD Studer A"		"UAD Studer A800"
fi
fi
if [ -d "VST UAD TrackAdv" ]; then
if [ ! -d "UAD TrackAdv" ]; then
	mv -f "VST UAD TrackAdv"		"UAD TrackAdv"
fi
fi
if [ -d "VST UAD TremModE" ]; then
if [ ! -d "UAD TremModEcho" ]; then
	mv -f "VST UAD TremModE"		"UAD TremModEcho"
fi
fi
if [ -d "VST UAD Tremolo" ]; then
if [ ! -d "UAD Tremolo" ]; then
	mv -f "VST UAD Tremolo"			"UAD Tremelo"
fi
fi
if [ -d "VST UAD Trident " ]; then
if [ ! -d "UAD Trident" ]; then
	mv -f "VST UAD Trident " 		"UAD Trident"
fi
fi
fi


#####################################################################
# rtas 1176+ preset rename
#####################################################################

#fix to PPINST-342 Mac 1176+ RTAS Presets not installed
#upgrade installation of v6.2-v6.5.2 which contained
#incorrect RTAS preset folder names
#move existing "UAD UA1176 A" and "UAD UA1176LN E"
#to the correct locations of "UAD UA 1176 A" and "UAD UA 1176LN E", over-writing contents
#then remove the old folder names
#fresh installation of v7.0.0 and newer does not have this issue
#this script acts only if the old named folders exist

#runs as administrator as part of the Mac installer
#BEFORE all stock presets have been unzipped
#correctly named RTAS preset folder may or may not exist

RTASPRESET_DIR="/Library/Application Support/Digidesign/Plug-In Settings"

SRC1176A_DIR="UAD UA1176 A"
DEST1176A_DIR="UAD UA 1176 A"

SRC1176LNE_DIR="UAD UA1176LN E"
DEST1176LNE_DIR="UAD UA 1176LN E"

if [ -d "$RTASPRESET_DIR" ]; then
  cd "$RTASPRESET_DIR"

  if [ -d "$SRC1176A_DIR" ]; then
    if [ ! -d "$DEST1176A_DIR" ]; then
      mv -f "$SRC1176A_DIR" "$DEST1176A_DIR"
    else
      cd "$SRC1176A_DIR"
      find . | cpio -pmdv "$RTASPRESET_DIR/$DEST1176A_DIR"
      cd "$RTASPRESET_DIR"
      rm -Rf "$RTASPRESET_DIR/$SRC1176A_DIR"
    fi
  fi

  if [ -d "$SRC1176LNE_DIR" ]; then
    if [ ! -d "$DEST1176LNE_DIR" ]; then
      mv -f "$SRC1176LNE_DIR" "$DEST1176LNE_DIR"
    else
      cd "$SRC1176LNE_DIR"
      find . | cpio -pmdv "$RTASPRESET_DIR/$DEST1176LNE_DIR"
      cd "$RTASPRESET_DIR"
      rm -Rf  "$RTASPRESET_DIR/$SRC1176LNE_DIR"
    fi
  fi

fi

#####################################################################
# rtas OWS preset rename
#####################################################################

#change for OCNSTU-400
#rename old placeholder OWS preset folder named "UAD OWS" to "UAD Ocean Way"
#runs as administrator as part of the Mac installer
#BEFORE all stock presets have been unzipped
#correctly named RTAS preset folder may or may not exist

RTASPRESET_DIR="/Library/Application Support/Digidesign/Plug-In Settings"

SRCOWS_DIR="UAD OWS"
DESTOWS_DIR="UAD Ocean Way"


if [ -d "$RTASPRESET_DIR" ]; then
  cd "$RTASPRESET_DIR"

  if [ -d "$SRCOWS_DIR" ]; then
    if [ ! -d "$DESTOWS_DIR" ]; then
      mv -f "$SRCOWS_DIR" "$DESTOWS_DIR"
    else
      cd "$SRCOWS_DIR"
      find . | cpio -pmdv "$RTASPRESET_DIR/$DESTOWS_DIR"
      cd "$RTASPRESET_DIR"
      rm -Rf "$RTASPRESET_DIR/$SRCOWS_DIR"
    fi
  fi

fi


#####################################################################
# RTAS Neve 1073 Legacy preset rename
#####################################################################

#correctly named RTAS preset folder may or may not exist

TOOLBARPRESET_DIR="/Library/Application Support/Universal Audio/Presets"
RTASPRESET_DIR="/Library/Application Support/Digidesign/Plug-In Settings"
AAXPRESET_DIR="/Users/$loggedInUser/Documents/Pro Tools/Plug-In Settings"

NUM_PRESET_FOLDERS=14

VST_SRC_DIRS[0]="UAD Neve 1073"
VST_DEST_DIRS[0]="UAD Neve 1073 Legacy"
PROTOOLS_SRC_DIRS[0]="UAD Neve 1073"
PROTOOLS_DEST_DIRS[0]="UAD Neve 1073 L"

VST_SRC_DIRS[1]="UAD Neve 1073SE"
VST_DEST_DIRS[1]="UAD Neve 1073SE Legacy"
PROTOOLS_SRC_DIRS[1]="UAD Neve 1073SE"
PROTOOLS_DEST_DIRS[1]="UAD Neve 1073 SEL"

VST_SRC_DIRS[2]="UAD Neve 88RS"
VST_DEST_DIRS[2]="UAD Neve 88RS Legacy"
PROTOOLS_SRC_DIRS[2]="UAD Neve 88RS"
PROTOOLS_DEST_DIRS[2]="UAD Neve 88RS L"

VST_SRC_DIRS[3]="UAD DM-1"
VST_DEST_DIRS[3]="UAD Precision Delay Mod"
PROTOOLS_SRC_DIRS[3]="UAD DM-1"
PROTOOLS_DEST_DIRS[3]="UAD P Delay Mod"

VST_SRC_DIRS[4]="UAD DM-1L"
VST_DEST_DIRS[4]="UAD Precision Delay Mod L"
PROTOOLS_SRC_DIRS[4]="UAD DM-1L"
PROTOOLS_DEST_DIRS[4]="UAD P Delay ModL"

VST_SRC_DIRS[5]="UAD EX-1"
VST_DEST_DIRS[5]="UAD Precision Channel Strip"
PROTOOLS_SRC_DIRS[5]="UAD EX-1"
PROTOOLS_DEST_DIRS[5]="UAD P Chan Strip"

VST_SRC_DIRS[6]="UAD RS-1"
VST_DEST_DIRS[6]="UAD Precision Reflection Engine"
PROTOOLS_SRC_DIRS[6]="UAD RS-1"
PROTOOLS_DEST_DIRS[6]="UAD P Refl Eng"

VST_SRC_DIRS[7]="UAD Moog Filter"
VST_DEST_DIRS[7]="UAD Moog Multimode Filter"
PROTOOLS_SRC_DIRS[7]="UAD Moog Filter"
PROTOOLS_DEST_DIRS[7]="UAD Moog MF"

VST_SRC_DIRS[8]="UAD Moog Filter SE"
VST_DEST_DIRS[8]="UAD Moog Multimode Filter SE"
PROTOOLS_SRC_DIRS[8]="UAD MoogFilterSE"
PROTOOLS_DEST_DIRS[8]="UAD Moog MF SE"

VST_SRC_DIRS[9]="UAD SSL E Channel Strip"
VST_DEST_DIRS[9]="UAD SSL E Channel Strip Legacy"
PROTOOLS_SRC_DIRS[9]="UAD SSL E ChnStp"
PROTOOLS_DEST_DIRS[9]="UAD SSL E Legacy"

VST_SRC_DIRS[10]="UAD SSL G Bus Compressor"
VST_DEST_DIRS[10]="UAD SSL G Bus Compressor Legacy"
PROTOOLS_SRC_DIRS[10]="UAD SSL G BusCmp"
PROTOOLS_DEST_DIRS[10]="UAD SSL G Legacy"

VST_SRC_DIRS[11]="UAD EL7 FATSO Jr"
VST_DEST_DIRS[11]="UAD Empirical Labs FATSO Jr"
PROTOOLS_SRC_DIRS[11]="UAD EL7 FATSO Jr"
PROTOOLS_DEST_DIRS[11]="UAD EL7 FATSO Jr"

VST_SRC_DIRS[12]="UAD EL7 FATSO Sr"
VST_DEST_DIRS[12]="UAD Empirical Labs FATSO Sr"
PROTOOLS_SRC_DIRS[12]="UAD EL7 FATSO Sr"
PROTOOLS_DEST_DIRS[12]="UAD EL7 FATSO Sr"

VST_SRC_DIRS[12]="UAD Helios 69"
VST_DEST_DIRS[12]="UAD Helios Type 69 Legacy"
PROTOOLS_SRC_DIRS[12]="UAD Helios 69"
PROTOOLS_DEST_DIRS[12]="UAD Helios 69 L"


# TODO add PCS

for ((idx=0; idx<=$NUM_PRESET_FOLDERS-1; idx++))
do
  VST_SRC_DIR=${VST_SRC_DIRS[$idx]}
  VST_DEST_DIR=${VST_DEST_DIRS[$idx]}
  PROTOOLS_SRC_DIR=${PROTOOLS_SRC_DIRS[$idx]}
  PROTOOLS_DEST_DIR=${PROTOOLS_DEST_DIRS[$idx]}
  #ensure we do not migrate the presets!
  #do this by checking for the existence of renamed folders
  if [ -d "$TOOLBARPRESET_DIR" ]; then
    cd "$TOOLBARPRESET_DIR"
    if [ ! -d "$VST_DEST_DIR" ]; then
      # system does not yet have renamed presets
      if [ -d "$VST_SRC_DIR" ]; then
        mv -f "$VST_SRC_DIR" "$VST_DEST_DIR"
      fi
    fi
  fi

  if [ -d "$RTASPRESET_DIR" ]; then
    cd "$RTASPRESET_DIR"
      if [ ! -d "$PROTOOLS_DEST_DIR" ]; then
      # system does not yet have renamed RTAS legacy preset folder
      if [ -d "$PROTOOLS_SRC_DIR" ]; then
        mv -f "$PROTOOLS_SRC_DIR" "$PROTOOLS_DEST_DIR"
      fi
    fi
  fi

  if [ -d "$AAXPRESET_DIR" ]; then
    cd "$AAXPRESET_DIR"
    if [ ! -d "$PROTOOLS_DEST_DIR" ]; then
      # system does not yet have renamed AAX legacy preset folder
      if [ -d "$PROTOOLS_SRC_DIR" ]; then
      mv -f "$PROTOOLS_SRC_DIR" "$PROTOOLS_DEST_DIR"
      fi
    fi
  fi

done


#####################################################################
# migrate plist and ini files
#####################################################################

SYSTEM_PREFSDIR=/Library/Preferences
SYSTEM_PLISTDIR=$SYSTEM_PREFSDIR/com.uaudio.uad.plist
SYSTEM_INIDIR="$SYSTEM_PREFSDIR/Universal Audio"
SYSTEM_INIFILE="$SYSTEM_INIDIR/Powered Plugins.ini"
USER_PREFSDIR=/Users/$loggedInUser/Library/Preferences
USER_PLISTDIR=$USER_PREFSDIR/com.uaudio.uad.plist
USER_INIFILE="$USER_PREFSDIR/Universal Audio/Powered Plugins.ini"

#migrate system plist to user
if [ ! -f "$USER_PLISTDIR" ]; then
  if [ -f "$SYSTEM_PLISTDIR" ]; then
    cp -f "$SYSTEM_PLISTDIR" "$USER_PLISTDIR"
    rm -f "$SYSTEM_PLISTDIR"
  fi
fi

# migrate system ini to user
if [ ! -f "$USER_INIFILE" ]; then
  if [ -f "$SYSTEM_INIFILE" ]; then
    cp -f "$SYSTEM_INIFILE" "$USER_INIFILE"
    rm -f "$SYSTEM_INIFILE"
    rm -f "$SYSTEM_INIDIR"/.DS_Store
    rmdir "$SYSTEM_INIDIR"
  fi
fi
