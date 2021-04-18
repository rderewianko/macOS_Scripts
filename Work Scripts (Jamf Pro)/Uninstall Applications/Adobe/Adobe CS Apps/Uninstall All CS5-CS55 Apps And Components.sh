#!/bin/bash

########################################################################
#              Uninstall All Adobe CS5-CS5.5 Applications              #
################### Written by Phil Walker Aug 2020 ####################
######################################################################## 

# Kill CS5-CS5.5, kill it with FIRE!!!

########################################################################
#                            Variables                                 #
########################################################################

# Creative Cloud Cleaner
cleanerTool="/private/var/tmp/Adobe Creative Cloud Cleaner Tool.app/Contents/MacOS/Adobe Creative Cloud Cleaner Tool"
# Check for Adobe CS5-CS5.5 Apps
adobeCSApps=$(find /Applications/Adobe\ *CS5* -type d -maxdepth 0 2>/dev/null | wc -l)
# CS5 directories. This is not the full list when CS5 is installed but some are also used for CC so have been excluded
adobeCS5Folders=( "/Applications/Adobe Acrobat 9 Pro" "/Applications/Adobe Acrobat X Pro" "/Applications/Adobe After Effects CS5" \
"/Applications/Adobe Bridge CS5" "/Applications/Adobe Contribute CS5" "/Applications/Adobe Device Central CS5" "/Applications/Adobe Dreamweaver CS5" \
"/Applications/Adobe Encore CS5" "/Applications/Adobe Extension Manager CS5" "/Applications/Adobe Fireworks CS5" "/Applications/Adobe Flash Builder 4" \
"/Applications/Adobe Flash Catalyst CS5" "/Applications/Adobe Flash CS5" "/Applications/Adobe Illustrator CS5" "/Applications/Adobe InDesign CS5" \
"/Applications/Adobe Media Encoder CS5" "/Applications/Adobe Media Player.app" "/Applications/Adobe OnLocation CS5" "/Applications/Adobe Photoshop CS5" \
"/Applications/Adobe Premiere Pro CS5" "/Applications/Adobe Soundbooth CS5" "/Applications/Utilities/Adobe AIR Application Installer.app" \
"/Applications/Utilities/Adobe AIR Uninstaller.app" "/Applications/Utilities/Adobe Utilities-CS5.localized" "/Applications/osx" \
"/Library/Application Support/Macromedia/.rskya9250.bin" "/Library/Application Support/Macromedia/FlashAuthor.cfg" \
"/Library/Application Support/Macromedia/FlashPlayerTrust" "/Library/Application Support/Mozilla" "/Library/Application Support/PACE Anti-Piracy" \
"/Library/Application Support/Synthetic Aperture Adobe CS5 Bundle" "/Library/Frameworks/Adobe AIR.framework" "/Library/Internet Plug-Ins/Flash Player.plugin" \
"/Library/Internet Plug-Ins/npContributeMac.bundle" "/Library/QuickTime/SoundboothScoreCodec.component" "/Library/ScriptingAdditions/Adobe Unit Types.osax" \
"/Library/Application Support/Adobe/Common/dynamiclink/CS5/dynamiclinkmanager.app" "/Library/Application Support/Adobe/CS5ServiceManager/CS5ServiceManager.app" )
# CS5 files
adobeCS5Files=("/Library/Fonts/ACaslonPro-Bold.otf" "/Library/Fonts/ACaslonPro-BoldItalic.otf" "/Library/Fonts/ACaslonPro-Italic.otf" \
"/Library/Fonts/ACaslonPro-Regular.otf" "/Library/Fonts/ACaslonPro-Semibold.otf" "/Library/Fonts/ACaslonPro-SemiboldItalic.otf" "/Library/Fonts/AdobeArabic-Bold.otf" \
"/Library/Fonts/AdobeArabic-BoldItalic.otf" "/Library/Fonts/AdobeArabic-Italic.otf" "/Library/Fonts/AdobeArabic-Regular.otf" \
"/Library/Fonts/AdobeFangsongStd-Regular.otf" "/Library/Fonts/AdobeFanHeitiStd-Bold.otf" "/Library/Fonts/AdobeGothicStd-Bold.otf" "/Library/Fonts/AdobeHebrew-Bold.otf" \
"/Library/Fonts/AdobeHebrew-BoldItalic.otf" "/Library/Fonts/AdobeHebrew-Italic.otf" "/Library/Fonts/AdobeHebrew-Regular.otf" "/Library/Fonts/AdobeHeitiStd-Regular.otf" \
"/Library/Fonts/AdobeKaitiStd-Regular.otf" "/Library/Fonts/AdobeMingStd-Light.otf" "/Library/Fonts/AdobeMyungjoStd-Medium.otf" "/Library/Fonts/AdobeSongStd-Light.otf" \
"/Library/Fonts/AGaramondPro-Bold.otf" "/Library/Fonts/AGaramondPro-BoldItalic.otf" "/Library/Fonts/AGaramondPro-Italic.otf" "/Library/Fonts/AGaramondPro-Regular.otf" \
"/Library/Fonts/BirchStd.otf" "/Library/Fonts/BlackoakStd.otf" "/Library/Fonts/BrushScriptStd.otf" "/Library/Fonts/ChaparralPro-Bold.otf" \
"/Library/Fonts/ChaparralPro-BoldIt.otf" "/Library/Fonts/ChaparralPro-Italic.otf" "/Library/Fonts/ChaparralPro-Regular.otf" "/Library/Fonts/CharlemagneStd-Bold.otf" \
"/Library/Fonts/CooperBlackStd-Italic.otf" "/Library/Fonts/CooperBlackStd.otf" "/Library/Fonts/GiddyupStd.otf" "/Library/Fonts/HoboStd.otf" \
"/Library/Fonts/KozGoPr6N-Bold.otf" "/Library/Fonts/KozGoPr6N-ExtraLight.otf" "/Library/Fonts/KozGoPr6N-Heavy.otf" "/Library/Fonts/KozGoPr6N-Light.otf" \
"/Library/Fonts/KozGoPr6N-Medium.otf" "/Library/Fonts/KozGoPr6N-Regular.otf" "/Library/Fonts/KozGoPro-Bold.otf" "/Library/Fonts/KozGoPro-ExtraLight.otf" \
"/Library/Fonts/KozGoPro-Heavy.otf" "/Library/Fonts/KozGoPro-Light.otf" "/Library/Fonts/KozGoPro-Medium.otf" "/Library/Fonts/KozGoPro-Regular.otf" \
"/Library/Fonts/KozMinPr6N-Bold.otf" "/Library/Fonts/KozMinPr6N-ExtraLight.otf" "/Library/Fonts/KozMinPr6N-Heavy.otf" "/Library/Fonts/KozMinPr6N-Light.otf" \
"/Library/Fonts/KozMinPr6N-Medium.otf" "/Library/Fonts/KozMinPr6N-Regular.otf" "/Library/Fonts/KozMinPro-Bold.otf" "/Library/Fonts/KozMinPro-ExtraLight.otf" \
"/Library/Fonts/KozMinPro-Heavy.otf" "/Library/Fonts/KozMinPro-Light.otf" "/Library/Fonts/KozMinPro-Medium.otf" "/Library/Fonts/KozMinPro-Regular.otf" \
"/Library/Fonts/LetterGothicStd-Bold.otf" "/Library/Fonts/LetterGothicStd-BoldSlanted.otf" "/Library/Fonts/LetterGothicStd-Slanted.otf" \
"/Library/Fonts/LetterGothicStd.otf" "/Library/Fonts/LithosPro-Black.otf" "/Library/Fonts/LithosPro-Regular.otf" "/Library/Fonts/MesquiteStd.otf" \
"/Library/Fonts/MinionPro-Bold.otf" "/Library/Fonts/MinionPro-BoldCn.otf" "/Library/Fonts/MinionPro-BoldCnIt.otf" "/Library/Fonts/MinionPro-BoldIt.otf" \
"/Library/Fonts/MinionPro-It.otf" "/Library/Fonts/MinionPro-Medium.otf" "/Library/Fonts/MinionPro-MediumIt.otf" "/Library/Fonts/MinionPro-Regular.otf" \
"/Library/Fonts/MinionPro-Semibold.otf" "/Library/Fonts/MinionPro-SemiboldIt.otf" "/Library/Fonts/MyriadPro-Bold.otf" "/Library/Fonts/MyriadPro-BoldCond.otf" \
"/Library/Fonts/MyriadPro-BoldCondIt.otf" "/Library/Fonts/MyriadPro-BoldIt.otf" "/Library/Fonts/MyriadPro-Cond.otf" "/Library/Fonts/MyriadPro-CondIt.otf" \
"/Library/Fonts/MyriadPro-It.otf" "/Library/Fonts/MyriadPro-Regular.otf" "/Library/Fonts/MyriadPro-Semibold.otf" "/Library/Fonts/MyriadPro-SemiboldIt.otf" \
"/Library/Fonts/MyriadWebPro-Bold.ttf" "/Library/Fonts/MyriadWebPro-Italic.ttf" "/Library/Fonts/MyriadWebPro.ttf" "/Library/Fonts/NuevaStd-BoldCond.otf" \
"/Library/Fonts/NuevaStd-BoldCondItalic.otf" "/Library/Fonts/NuevaStd-Cond.otf" "/Library/Fonts/NuevaStd-CondItalic.otf" "/Library/Fonts/OCRAStd.otf" \
"/Library/Fonts/OratorStd-Slanted.otf" "/Library/Fonts/OratorStd.otf" "/Library/Fonts/PoplarStd.otf" "/Library/Fonts/PrestigeEliteStd-Bd.otf" \
"/Library/Fonts/RosewoodStd-Regular.otf" "/Library/Fonts/StencilStd.otf" "/Library/Fonts/TektonPro-Bold.otf" "/Library/Fonts/TektonPro-BoldCond.otf" \
"/Library/Fonts/TektonPro-BoldExt.otf" "/Library/Fonts/TektonPro-BoldObl.otf" "/Library/Fonts/TrajanPro-Bold.otf" "/Library/Fonts/TrajanPro-Regular.otf" \
"/Library/LaunchAgents/com.adobe.CS5ServiceManager.plist" "/Library/LaunchDaemons/com.adobe.SwitchBoard.plist" "/private/etc/mach_init_per_user.d/com.adobe.SwitchBoard.monitor.plist" \
"/Library/Preferences/com.adobe.headlights.apip.plist" "/Library/Preferences/com.adobe.Illustrator.15.0.2.plist" "/Library/Preferences/com.masi.ddpp.plist" \
"/Library/Preferences/com.adobe.InDesign.7.0.3.plist" "/Library/Preferences/com.adobe.Contribute.6.0.plist" "/Library/Preferences/com.adobe.CSXS2Preferences.plist" \
"/Library/Preferences/com.adobe.Dreamweaver.11.plist" "/Library/Preferences/com.adobe.Fireworks.11.0.0.plist" "/Library/Preferences/com.adobe.Illustrator.15.0.0.plist" \
"/Library/Preferences/com.adobe.InDesign.7.0.plist" "/Library/Preferences/com.apple.mediaio.DeviceSettings.plist" )
# CS5.5 directories. This is not the full list when CS5 is installed but some are also used for CC so have been excluded
adobeCS55Folders=("/Applications/Adobe Acrobat X Pro" "/Applications/Adobe After Effects CS5.5" "/Applications/Adobe Audition CS5.5" "/Applications/Adobe Bridge CS5.1" \
"/Applications/Adobe Contribute CS5.1" "/Applications/Adobe Device Central CS5.5" "/Applications/Adobe Dreamweaver CS5.5" "/Applications/Adobe Encore CS5.1" \
"/Applications/Adobe Extension Manager CS5.5" "/Applications/Adobe Fireworks CS5.1" "/Applications/Adobe Flash Builder 4.5" "/Applications/Adobe Flash Catalyst CS5.5" \
"/Applications/Adobe Flash CS5.5" "/Applications/Adobe Illustrator CS5.1" "/Applications/Adobe InDesign CS5.5" "/Applications/Adobe Media Encoder CS5.5" \
"/Applications/Adobe OnLocation CS5.1" "/Applications/Adobe Photoshop CS5.1" "/Applications/Adobe Premiere Pro CS5.5" "/Applications/Adobe Story.app" \
"/Applications/Utilities/Adobe AIR Application Installer.app" "/Applications/Utilities/Adobe AIR Uninstaller.app" "/Applications/Utilities/Adobe Utilities-CS5.5.localized" \
"/Library/Application Support/Macromedia" "/Library/Application Support/Synthetic Aperture Adobe CS5.5 Bundle" "/Library/Frameworks/Adobe AIR.framework" \
"/Library/Internet Plug-Ins/Flash Player.plugin" "/Library/Internet Plug-Ins/npContributeMac.bundle" "/Library/ScriptingAdditions/Adobe Unit Types.osax" \
"/private/var/root/Library/Preferences/Macromedia" "/Library/Application Support/Adobe/SwitchBoard/SwitchBoard.app" "/Library/Application Support/Adobe/CS5.5ServiceManager/CS5.5ServiceManager.app" \
"/Applications/Utilities/Adobe Utilities-CS5.5.localized/Pixel Bender Toolkit 2.6/Pixel Bender Toolkit.app" "/Applications/Utilities/Adobe Utilities-CS5.5.localized/ExtendScript Toolkit CS5.5/ExtendScript Toolkit.app" \
"/Applications/Utilities/Adobe Application Manager/LWA/AAM Registration Notifier.app" "/Applications/Utilities/Adobe Application Manager/LWA/adobe_licutil.app" \
"/Applications/Utilities/Adobe Application Manager/UWA/AAM Updates Notifier.app" "/Applications/Utilities/Adobe Application Manager/core/Adobe Application Manager.app" \
"/Applications/Utilities/Adobe Application Manager/DWA/Setup.app" "/Applications/Utilities/Adobe Application Manager/DWA/resources/uninstall/Uninstall Product.app" )
# CS5.5 files
adobeCS55Files=("/Library/Fonts/ACaslonPro-Bold.otf" "/Library/Fonts/ACaslonPro-BoldItalic.otf" "/Library/Fonts/ACaslonPro-Italic.otf" \
"/Library/Fonts/ACaslonPro-Regular.otf" "/Library/Fonts/ACaslonPro-Semibold.otf" "/Library/Fonts/ACaslonPro-SemiboldItalic.otf" \
"/Library/Fonts/AdobeArabic-Bold.otf" "/Library/Fonts/AdobeArabic-BoldItalic.otf" "/Library/Fonts/AdobeArabic-Italic.otf" \
"/Library/Fonts/AdobeArabic-Regular.otf" "/Library/Fonts/AdobeFangsongStd-Regular.otf" "/Library/Fonts/AdobeFanHeitiStd-Bold.otf" \
"/Library/Fonts/AdobeGothicStd-Bold.otf" "/Library/Fonts/AdobeHebrew-Bold.otf" "/Library/Fonts/AdobeHebrew-BoldItalic.otf" \
"/Library/Fonts/AdobeHebrew-Italic.otf" "/Library/Fonts/AdobeHebrew-Regular.otf" "/Library/Fonts/AdobeHeitiStd-Regular.otf" \
"/Library/Fonts/AdobeKaitiStd-Regular.otf" "/Library/Fonts/AdobeMingStd-Light.otf" "/Library/Fonts/AdobeMyungjoStd-Medium.otf" \
"/Library/Fonts/AdobeSongStd-Light.otf" "/Library/Fonts/AGaramondPro-Bold.otf" "/Library/Fonts/AGaramondPro-BoldItalic.otf" \
"/Library/Fonts/AGaramondPro-Italic.otf" "/Library/Fonts/AGaramondPro-Regular.otf" "/Library/Fonts/BirchStd.otf" "/Library/Fonts/BlackoakStd.otf" \
"/Library/Fonts/BrushScriptStd.otf" "/Library/Fonts/ChaparralPro-Bold.otf" "/Library/Fonts/ChaparralPro-BoldIt.otf" "/Library/Fonts/ChaparralPro-Italic.otf" \
"/Library/Fonts/ChaparralPro-Regular.otf" "/Library/Fonts/CharlemagneStd-Bold.otf" "/Library/Fonts/CooperBlackStd-Italic.otf" \
"/Library/Fonts/CooperBlackStd.otf" "/Library/Fonts/GiddyupStd.otf" "/Library/Fonts/HoboStd.otf" "/Library/Fonts/KozGoPr6N-Bold.otf" \
"/Library/Fonts/KozGoPr6N-ExtraLight.otf" "/Library/Fonts/KozGoPr6N-Heavy.otf" "/Library/Fonts/KozGoPr6N-Light.otf" "/Library/Fonts/KozGoPr6N-Medium.otf" \
"/Library/Fonts/KozGoPr6N-Regular.otf" "/Library/Fonts/KozGoPro-Bold.otf" "/Library/Fonts/KozGoPro-ExtraLight.otf" "/Library/Fonts/KozGoPro-Heavy.otf" \
"/Library/Fonts/KozGoPro-Light.otf" "/Library/Fonts/KozGoPro-Medium.otf" "/Library/Fonts/KozGoPro-Regular.otf" "/Library/Fonts/KozMinPr6N-Bold.otf" \
"/Library/Fonts/KozMinPr6N-ExtraLight.otf" "/Library/Fonts/KozMinPr6N-Heavy.otf" "/Library/Fonts/KozMinPr6N-Light.otf" "/Library/Fonts/KozMinPr6N-Medium.otf" \
"/Library/Fonts/KozMinPr6N-Regular.otf" "/Library/Fonts/KozMinPro-Bold.otf" "/Library/Fonts/KozMinPro-ExtraLight.otf" "/Library/Fonts/KozMinPro-Heavy.otf" \
"/Library/Fonts/KozMinPro-Light.otf" "/Library/Fonts/KozMinPro-Medium.otf" "/Library/Fonts/KozMinPro-Regular.otf" "/Library/Fonts/LetterGothicStd-Bold.otf" \
"/Library/Fonts/LetterGothicStd-BoldSlanted.otf" "/Library/Fonts/LetterGothicStd-Slanted.otf" "/Library/Fonts/LetterGothicStd.otf" \
"/Library/Fonts/LithosPro-Black.otf" "/Library/Fonts/LithosPro-Regular.otf" "/Library/Fonts/MesquiteStd.otf" "/Library/Fonts/MinionPro-Bold.otf" \
"/Library/Fonts/MinionPro-BoldCn.otf" "/Library/Fonts/MinionPro-BoldCnIt.otf" "/Library/Fonts/MinionPro-BoldIt.otf" "/Library/Fonts/MinionPro-It.otf" \
"/Library/Fonts/MinionPro-Medium.otf" "/Library/Fonts/MinionPro-MediumIt.otf" "/Library/Fonts/MinionPro-Regular.otf" "/Library/Fonts/MinionPro-Semibold.otf" \
"/Library/Fonts/MinionPro-SemiboldIt.otf" "/Library/Fonts/MyriadPro-Bold.otf" "/Library/Fonts/MyriadPro-BoldCond.otf" "/Library/Fonts/MyriadPro-BoldCondIt.otf" \
"/Library/Fonts/MyriadPro-BoldIt.otf" "/Library/Fonts/MyriadPro-Cond.otf" "/Library/Fonts/MyriadPro-CondIt.otf" "/Library/Fonts/MyriadPro-It.otf" \
"/Library/Fonts/MyriadPro-Regular.otf" "/Library/Fonts/MyriadPro-Semibold.otf" "/Library/Fonts/MyriadPro-SemiboldIt.otf" "/Library/Fonts/MyriadWebPro-Bold.ttf" \
"/Library/Fonts/MyriadWebPro-Italic.ttf" "/Library/Fonts/MyriadWebPro.ttf" "/Library/Fonts/NuevaStd-BoldCond.otf" "/Library/Fonts/NuevaStd-BoldCondItalic.otf" \
"/Library/Fonts/NuevaStd-Cond.otf" "/Library/Fonts/NuevaStd-CondItalic.otf" "/Library/Fonts/OCRAStd.otf" "/Library/Fonts/OratorStd-Slanted.otf" \
"/Library/Fonts/OratorStd.otf" "/Library/Fonts/PoplarStd.otf" "/Library/Fonts/PrestigeEliteStd-Bd.otf" "/Library/Fonts/RosewoodStd-Regular.otf" \
"/Library/Fonts/StencilStd.otf" "/Library/Fonts/TektonPro-Bold.otf" "/Library/Fonts/TektonPro-BoldCond.otf" "/Library/Fonts/TektonPro-BoldExt.otf" \
"/Library/Fonts/TektonPro-BoldObl.otf" "/Library/Fonts/TrajanPro-Bold.otf" "/Library/Fonts/TrajanPro-Regular.otf" "/Library/Internet Plug-Ins/flashplayer.xpt" \
"/Library/LaunchDaemons/com.adobe.SwitchBoard.plist" "/Library/Preferences/com.adobe.Contribute.6.1.plist" "/Library/Preferences/com.adobe.CSXS.2.5.plist" \
"/Library/Preferences/com.adobe.Dreamweaver.11.5.plist" "/Library/Preferences/com.adobe.Fireworks.11.1.0.plist" \
"/Library/Preferences/com.adobe.headlights.apip.plist.lockfile" "/Library/Preferences/com.adobe.headlights.apip.plist" \
"/Library/Preferences/com.adobe.Illustrator.15.1.0.plist" "/Library/Preferences/com.adobe.InDesign.7.5.1.plist" "/Library/Preferences/com.adobe.InDesign.7.5.plist" \
"/private/etc/mach_init_per_user.d/com.adobe.SwitchBoard.monitor.plist" )

########################################################################
#                            Functions                                 #
########################################################################

# Kill all CS5 processes
function closeAllCS5 ()
{
adobeCSProcs=$(ps aux | grep -v grep | grep -i "Adobe" | grep -i "cs5" | awk '{print $2}')
if [[ "$adobeCSProcs" != "" ]]; then
    echo "Killing all Adobe CS5 processes..."
    while [[ "$adobeCSProcs" != "" ]]; do
        for proc in $adobeCSProcs; do
            kill -9 "$proc" 2>/dev/null
        done
    sleep 2
    # re-populate variable
    adobeCSProcs=$(ps aux | grep -v grep | grep -i "Adobe" | grep -i "cs5" | awk '{print $2}')
    done
    echo "All Adobe CS5 processes killed"
fi
}

# Remove CC Cleaner app
function cleanUp ()
{
if [[ -e "$cleanerTool"  ]]; then
    rm -rf "/private/var/tmp/Adobe Creative Cloud Cleaner Tool.app"
    if [[ ! -e "$cleanerTool" ]]; then
        echo "CC Cleaner Tool removed successfully"
    else
        echo "Failed to remove CC Cleaner Tool, manual removal required"
    fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ ! -e "$cleanerTool" ]]; then
    echo "CC Cleaner Tool not installed, exiting"
    exit 1
else
    # Make sure all CS5-CS5.5. apps are closed
    closeAllCS5
    # If any CS5-CS5.5 apps are found KILL THEM ALL!!!
    if [[ "$adobeCSApps" -ge "1" ]]; then
        echo "Adobe CS5-CS5.5 applications found"
        echo "Uninstalling all CS5-CS5.5 apps..."
        # Kill SafariBookmarksSyncAgent - required for clean uninstall
        pkill -9 "SafariBookmarksSyncAgent" 2>/dev/null
        # Kill SafariLaunchAgent - required for clean uninstall
        pkill -9 "SafariLaunchAgent" 2>/dev/null
        # Kill SafariPlugInUpdateNotifier - required for clean uninstall (CS5 Only)
        pkill -9 "SafariPlugInUpdateNotifier" 2>/dev/null
        # Run the CC Cleaner tool and specify CS5-CS5.5 only
        "$cleanerTool" --removeAll=CS5-CS5.5 >/dev/null 2>&1
        # Confirm CC Cleaner was successful
        if [[ "$?" == "0" ]]; then
            echo "All Adobe CS5-CS5.5 Applications Uninstalled"
        else
            echo "Failed to complete uninstall process, some manual clean-up may be required"
        fi
        # To complete the clean-up make sure all directories and files for CS5 are deleted
        # Loop through the array of folders and delete any that are found
        for folder in "${adobeCS5Folders[@]}"; do
            if [[ -e "$folder" ]]; then
                rm -rf "$folder"
        # DEBUG echo "Deleted ${folder}"
            fi
        done
        # Loop through the array of files and delete any that are found
        for file in "${adobeCS5Files[@]}"; do
            if [[ -e "$file" ]]; then
                rm -f "$file"
        # DEBUG echo "Deleted ${file}"
            fi
        done
        # To complete the clean-up make sure all directories and files for CS5.5 are deleted
        # Loop through the array of folders and delete any that are found
        for folder in "${adobeCS55Folders[@]}"; do
            if [[ -e "$folder" ]]; then
                rm -rf "$folder"
        # DEBUG echo "Deleted ${folder}"
            fi
        done
        # Loop through the array of files and delete any that are found
        for file in "${adobeCS55Files[@]}"; do
            if [[ -e "$file" ]]; then
                rm -f "$file"
        # DEBUG echo "Deleted ${file}"
            fi
        done
    else
        echo "No CS5-CS5.5 apps found, nothing to do"
    fi
    # Remove CC Cleaner Tool
    cleanUp
fi

exit 0