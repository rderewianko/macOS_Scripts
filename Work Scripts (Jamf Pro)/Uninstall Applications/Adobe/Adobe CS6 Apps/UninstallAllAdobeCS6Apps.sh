#!/bin/bash

########################################################################
#                 Uninstall All Adobe CS6 Applications                 #
################### Written by Phil Walker May 2020 ####################
########################################################################

# Kill CS6, kill it with FIRE!!!

########################################################################
#                            Variables                                 #
########################################################################

# Creative Cloud Cleaner
cleanerTool="/private/var/tmp/Adobe Creative Cloud Cleaner Tool.app/Contents/MacOS/Adobe Creative Cloud Cleaner Tool"
# Acrobat Removal Tool
removeAcrobatX="/Applications/Adobe Acrobat X Pro/Adobe Acrobat Pro.app/Contents/Support/Acrobat Uninstaller.app/Contents/MacOS/RemoverTool"
# Check for Adobe CS6 Apps
adobeCSApps=$(find /Applications/Adobe\ *CS6* -type d -maxdepth 0 2>/dev/null | wc -l)
# Array listing CS6 directories. This is not the full list when CS6 is installed but some are also used for CC so have been excluded
adobeCSFolders=( "/Applications/Adobe After Effects CS6" "/Applications/Adobe Audition CS6" "/Applications/Adobe Bridge CS6" \
"/Applications/Adobe Dreamweaver CS6" "/Applications/Adobe Encore CS6" "/Applications/Adobe Extension Manager CS6" "/Applications/Adobe Fireworks CS6" \
"/Applications/Adobe Flash Builder 4.6" "/Applications/Adobe Flash CS6" "/Applications/Adobe Illustrator CS6" "/Applications/Adobe InDesign CS6" \
"/Applications/Adobe Media Encoder CS6" "/Applications/Adobe Photoshop CS6" "/Applications/Adobe Prelude CS6" "/Applications/Adobe Premiere Pro CS6" \
"/Applications/Adobe SpeedGrade CS6" "/Applications/Utilities/Adobe Installers/Adobe Creative Suite 6 Design Standard" "/Applications/Utilities/Adobe AIR Application Installer.app" \
"/Applications/Utilities/Adobe AIR Uninstaller.app" "/Applications/Utilities/Adobe Utilities-CS6.localized" "/Library/Application Support/Macromedia" \
"/Library/Application Support/Adobe/Extension Manager CS6" "/Library/Application Support/Adobe/CS6" "/Library/Application Support/Adobe/CS6ServiceManager" \
"/Library/Application Support/Adobe/SwitchBoard/SwitchBoard.app" "/Library/Application Support/Adobe/Scripting Dictionaries CS6" \
"/Library/Application Support/Adobe/Adobe Creative Suite 6 Design Standard" "/Library/Application Support/Adobe/DigitalPublishingCS6" \
"/Library/Application Support/Adobe/Bridge CS6 Extensions" "/Library/Application Support/Adobe/Startup Scripts CS6" \
"/Library/Application Support/Adobe/Adobe Photoshop CS6" "/Library/Internet Plug-Ins/AdobeAAMDetect.plugin" "/Library/Internet Plug-Ins/AdobeExManDetect.plugin" \
"/Library/Frameworks/Adobe AIR.framework" "/Library/Application Support/regid.1986-12.com.adobe" "/Library/ScriptingAdditions/Adobe Unit Types.osax" \
"/Library/Application Support/Adobe/InDesign/Version 8.0" "/Library/Application Support/Adobe/Common/dynamiclink" "/Library/Application Support/Adobe/Common/dynamiclinkmediaserver" \
"/Library/Application Support/Adobe/Uninstall/{19D99776-D832-4EB7-84BD-55C06FD8D44C}/{19D99776-D832-4EB7-84BD-55C06FD8D44C}.app" \
"/Library/Application Support/Adobe/Uninstall/{19D99776-D832-4EB7-84BD-55C06FD8D44C}.app" \
"/Library/Application Support/Adobe/Uninstall/{D8C642B6-A719-4234-8039-2654ED436D2A}/{D8C642B6-A719-4234-8039-2654ED436D2A}.app" \
"/Applications/Utilities/Adobe Application Manager/DECore/Setup.app" "/Applications/Utilities/Adobe Application Manager/DECore/DE5/resources/uninstall/Uninstall Product.app" \
"/Applications/Utilities/Adobe Application Manager/DECore/DE6/resources/uninstall/Uninstall Product.app" \
"/Applications/Utilities/Adobe Application Manager/LWA/AAM Registration Notifier.app" \
"/Applications/Utilities/Adobe Application Manager/core/Adobe Application Manager.app" "/Applications/Utilities/Adobe Application Manager/P6/AAM Registration Notifier.app" \
"/Applications/Utilities/Adobe Application Manager/P6/adobe_licutil.app" "/Applications/Utilities/Adobe Application Manager/P7/AAM Registration Notifier.app" \
"/Applications/Utilities/Adobe Application Manager/P7/adobe_licutil.app" "/Applications/Utilities/Adobe Application Manager/UWA/AAM Updates Notifier.app" \
"/Applications/Utilities/Adobe Application Manager/D6/Setup.app" "/Applications/Utilities/Adobe Application Manager/core/AAMLauncherUtil.app" \
"/Applications/Utilities/Adobe Application Manager/DWA/Setup.app" )
# Array listing CS6 files
adobeCSFiles=( "/private/etc/mach_init_per_user.d/com.adobe.SwitchBoard.monitor.plist" "/private/var/root/Library/Application Support/Adobe/OOBE/opm.db" \
"/Library/Preferences/com.adobe.Fireworks.12.0.0.plist" "/Library/Preferences/com.adobe.PDFAdminSettings.plist" \
"/Library/LaunchAgents/com.adobe.AAM.Updater-1.0.plist" "/Library/LaunchDaemons/com.adobe.SwitchBoard.plist" "/Library/Preferences/com.adobe.CSXS.3.plist" \
"/Library/Preferences/com.adobe.acrobat.pdfviewer.plist" "/Library/Fonts/KozGoPro-Bold.otf" "/Library/Fonts/TrajanPro-Bold.otf" "/Library/Fonts/AdobeDevanagari-Regular.otf" \
"/Library/Fonts/KozMinPr6N-Regular.otf" "/Library/Fonts/NuevaStd-Bold.otf" "/Library/Fonts/OratorStd.otf" "/Library/Fonts/OCRAStd.otf" "/Library/Fonts/MinionPro-SemiboldIt.otf" \
"/Library/Fonts/MyriadPro-CondIt.otf" "/Library/Fonts/TrajanPro-Regular.otf" "/Library/Fonts/NuevaStd-BoldCondItalic.otf" "/Library/Fonts/ChaparralPro-BoldIt.otf" \
"/Library/Fonts/AdobeHebrew-BoldItalic.otf" "/Library/Fonts/MyriadPro-BoldCond.otf" "/Library/Fonts/KozMinPr6N-Light.otf" "/Library/Fonts/KozGoPr6N-Bold.otf" \
"/Library/Fonts/AdobeFangsongStd-Regular.otf" "/Library/Fonts/MyriadPro-Regular.otf" "/Library/Fonts/ACaslonPro-BoldItalic.otf" "/Library/Fonts/BrushScriptStd.otf" \
"/Library/Fonts/CooperBlackStd.otf" "/Library/Fonts/AGaramondPro-BoldItalic.otf" "/Library/Fonts/AGaramondPro-Regular.otf" "/Library/Fonts/AGaramondPro-Italic.otf" \
"/Library/Fonts/AdobeHebrew-Bold.otf" "/Library/Fonts/AdobeDevanagari-BoldItalic.otf" "/Library/Fonts/ChaparralPro-Bold.otf" "/Library/Fonts/KozGoPr6N-Heavy.otf" \
"/Library/Fonts/StencilStd.otf" "/Library/Fonts/AdobeMyungjoStd-Medium.otf" "/Library/Fonts/TektonPro-BoldObl.otf" "/Library/Fonts/KozMinPro-Light.otf" \
"/Library/Fonts/MyriadHebrew-It.otf" "/Library/Fonts/AdobeHebrew-Regular.otf" "/Library/Fonts/PrestigeEliteStd-Bd.otf" "/Library/Fonts/ACaslonPro-Regular.otf" \
"/Library/Fonts/ChaparralPro-Regular.otf" "/Library/Fonts/ChaparralPro-LightIt.otf" "/Library/Fonts/KozGoPro-Medium.otf" "/Library/Fonts/CooperBlackStd-Italic.otf" \
"/Library/Fonts/RosewoodStd-Regular.otf" "/Library/Fonts/NuevaStd-Italic.otf" "/Library/Fonts/MyriadPro-BoldIt.otf" "/Library/Fonts/TektonPro-BoldExt.otf" \
"/Library/Fonts/KozMinPro-Medium.otf" "/Library/Fonts/KozGoPr6N-Regular.otf" "/Library/Fonts/AdobeDevanagari-Bold.otf" "/Library/Fonts/MyriadArabic-BoldIt.otf" \
"/Library/Fonts/KozGoPr6N-ExtraLight.otf" "/Library/Fonts/AdobeFanHeitiStd-Bold.otf" "/Library/Fonts/TektonPro-BoldCond.otf" "/Library/Fonts/MesquiteStd.otf" \
"/Library/Fonts/AdobeHeitiStd-Regular.otf" "/Library/Fonts/KozMinPr6N-ExtraLight.otf" "/Library/Fonts/KozGoPro-Regular.otf" "/Library/Fonts/AdobeKaitiStd-Regular.otf" \
"/Library/Fonts/MyriadArabic-Regular.otf" "/Library/Fonts/MyriadPro-It.otf" "/Library/Fonts/ACaslonPro-Bold.otf" "/Library/Fonts/BirchStd.otf" \
"/Library/Fonts/BlackoakStd.otf" "/Library/Fonts/MyriadPro-Bold.otf" "/Library/Fonts/TektonPro-Bold.otf" "/Library/Fonts/MinionPro-BoldCn.otf" \
"/Library/Fonts/KozGoPro-Heavy.otf" "/Library/Fonts/AGaramondPro-Bold.otf" "/Library/Fonts/AdobeArabic-Italic.otf" "/Library/Fonts/GiddyupStd.otf" \
"/Library/Fonts/MyriadPro-Semibold.otf" "/Library/Fonts/MinionPro-Semibold.otf" "/Library/Fonts/AdobeHebrew-Italic.otf" "/Library/Fonts/KozGoPr6N-Medium.otf" \
"/Library/Fonts/ACaslonPro-Italic.otf" "/Library/Fonts/MinionPro-Bold.otf" "/Library/Fonts/MyriadPro-SemiboldIt.otf" "/Library/Fonts/MyriadHebrew-Bold.otf" \
"/Library/Fonts/MinionPro-BoldCnIt.otf" "/Library/Fonts/LithosPro-Regular.otf" "/Library/Fonts/MyriadHebrew-BoldIt.otf" "/Library/Fonts/CharlemagneStd-Bold.otf" \
"/Library/Fonts/KozMinPr6N-Medium.otf" "/Library/Fonts/MinionPro-Regular.otf" "/Library/Fonts/OratorStd-Slanted.otf" "/Library/Fonts/KozMinPr6N-Heavy.otf" \
"/Library/Fonts/AdobeMingStd-Light.otf" "/Library/Fonts/AdobeSongStd-Light.otf" "/Library/Fonts/HoboStd.otf" "/Library/Fonts/LetterGothicStd-Slanted.otf" \
"/Library/Fonts/MinionPro-It.otf" "/Library/Fonts/AdobeArabic-Bold.otf" "/Library/Receipts/InstallHistory.plist" "/Library/Fonts/ACaslonPro-SemiboldItalic.otf" \
"/Library/Fonts/KozGoPr6N-Light.otf" "/Library/Fonts/ACaslonPro-Semibold.otf" "/Library/Fonts/NuevaStd-Cond.otf" "/Library/Fonts/ChaparralPro-Italic.otf" \
"/Library/Fonts/MinionPro-BoldIt.otf" "/Library/Fonts/MyriadArabic-Bold.otf" "/Library/Fonts/KozGoPro-ExtraLight.otf" "/Library/Fonts/MinionPro-MediumIt.otf" \
"/Library/Fonts/KozMinPr6N-Bold.otf" "/Library/Fonts/MyriadHebrew-Regular.otf" "/Library/Fonts/LithosPro-Black.otf" "/Library/Fonts/LetterGothicStd.otf" \
"/Library/Fonts/AdobeArabic-BoldItalic.otf" "/Library/Fonts/NuevaStd-CondItalic.otf" "/Library/Fonts/AdobeDevanagari-Italic.otf" \
"/Library/Fonts/AdobeNaskh-Medium.otf" "/Library/Fonts/AdobeArabic-Regular.otf" "/Library/Fonts/MyriadPro-Cond.otf" "/Library/Fonts/MyriadPro-BoldCondIt.otf" \
"/Library/Fonts/KozMinPro-Heavy.otf" "/Library/Fonts/LetterGothicStd-Bold.otf" "/Library/Fonts/AdobeGothicStd-Bold.otf" "/Library/Fonts/MinionPro-Medium.otf" \
"/Library/Fonts/KozMinPro-Bold.otf" "/Library/Fonts/PoplarStd.otf" "/Library/Fonts/MyriadArabic-It.otf" "/Library/Fonts/NuevaStd-BoldCond.otf" \
"/Library/Fonts/LetterGothicStd-BoldSlanted.otf" "/Library/Fonts/KozMinPro-Regular.otf" "/Library/Fonts/KozGoPro-Light.otf" "/Library/Fonts/KozMinPro-ExtraLight.otf"  )

########################################################################
#                            Functions                                 #
########################################################################

function closeAllCS6 ()
{
adobeCSProcs=$(ps aux | grep -v grep | grep -i "Adobe" | grep -i "cs6" | awk '{print $2}')
while [[ "$adobeCSProcs" != "" ]]; do
    for proc in $adobeCSProcs; do
        kill -9 "$proc" 2>/dev/null
    done
sleep 2
# re-populate variable
adobeCSProcs=$(ps aux | grep -v grep | grep -i "Adobe" | grep -i "cs6" | awk '{print $2}')
done
echo "All Adobe CS6 processes killed"
}

# The legacy version of Save as Adobe PDF should not be installed but if found, remove it (32bit app)
function removeSaveAsAdobePDF ()
{
# Acrobat Save as PDF app
saveAsAdobePDFApp="/Library/PDF Services/Save as Adobe PDF.app"
if [[ -d "$saveAsAdobePDFApp" ]]; then
    saveAsAdobePDFVersion=$(defaults read "/Library/PDF Services/Save as Adobe PDF.app/Contents/Info.plist" CFBundleShortVersionString)
    if [[ "$saveAsAdobePDFVersion" == "10.0.0" ]]; then
        rm -rf "/Library/PDF Services/Save as Adobe PDF.app"
        if [[ ! -d "saveAsPDFApp" ]]; then
            echo "Legacy Save as Adobe PDF app uninstalled"
        else
            echo "Failed to uninstall Legacy Save as Adobe PDF app"
            echo "Manual clean-up required as this app is 32bit"
        fi
    fi
fi
}

# If legacy Java is installed, uninstall it!
function removeLegacyJava ()
{
# Legacy Java
legacyJava="/Library/Java/JavaVirtualMachines/1.6.0.jdk"
if [[ -d "$legacyJava" ]]; then
    rm -rf "$legacyJava"
    sleep 2
    if [[ ! -d "$legacyJava" ]]; then
        echo "Legacy Java removed successfully"
    else
        echo "Failed to remove Legacy Java, manual clean-up required"
    fi
else
    echo "Legacy Java not found"
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
    # Make sure all CS6 apps are closed
    closeAllCS6
    # If found, uninstall Acrobat X Pro
    if [[ -d "/Applications/Adobe Acrobat X Pro" ]]; then
        removeAcrobatX="/Applications/Adobe Acrobat X Pro/Adobe Acrobat Pro.app/Contents/Support/Acrobat Uninstaller.app/Contents/MacOS/RemoverTool"
        "$removeAcrobatX" &> /dev/null | tail -n1
        rm -rf "/Applications/Adobe Acrobat X Pro"
        if [[ ! -d "/Applications/Adobe Acrobat X Pro" ]]; then
            echo "Acrobat X Pro removed"
        else
            echo "Acrobat X Pro removal failed, manual clean-up required"
        fi
    else
        echo "Acrobat X Pro not found"
    fi
    # If any CS6 apps are found KILL THEM ALL!!!
    if [[ "$adobeCSApps" -ge "1" ]]; then
        echo "Adobe CS6 applications found"
        echo "Uninstalling all CS6 apps..."
        # Kill SafariBookmarksSyncAgent - required for clean uninstall
        killall "SafariBookmarksSyncAgent" 2>/dev/null
        # Run the CC Cleaner tool and specify CS6 only
        "$cleanerTool" --removeAll=CS6 >/dev/null 2>&1
        # Confirm CC Cleaner was successful
        if [[ "$?" == "0" ]]; then
            echo "All Adobe CS6 Applications Uninstalled"
        else
            echo "Failed to complete uninstall process, some manual clean-up may be required"
        fi
        # To complete the clean-up make sure all directories and files for CS6 are deleted
        # Loop through the array of folders and delete any that are found
        for folder in "${adobeCSFolders[@]}"
        do
            if [[ -e "$folder" ]]; then
                rm -rf "$folder"
        # DEBUG echo "Deleted ${folder}"
            fi
        done
        # Loop through the array of files and delete any that are found
        for file in "${adobeCSFiles[@]}"
        do
            if [[ -e "$file" ]]; then
                rm -f "$file"
        # DEBUG echo "Deleted ${file}"
            fi
        done
        # Remove Legacy Save as Adobe PDF app
        removeSaveAsAdobePDF
        # Legacy Java removal (Required for Illustrator CS6)
        removeLegacyJava
    else
        echo "No CS6 apps found, nothing to do"
    fi
    # Remove CC Cleaner Tool
    cleanUp
fi

exit 0