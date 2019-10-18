#!/bin/bash

########################################################################
#            Install Pro Tools 2019 and all additional content         #
##################### Written by Phil Walker Oct 2019 ##################
########################################################################

#DMG's and packages are copied to local machine via Package
#This is the postinstall script to mount the DMG's and install ProTools and addons in the correct order

#As part of standardising the ProTools installation we need to check that an external hard drive is connected and named correctly
#WKSxxxxx Pro Tools Sessions this is done with a installation check script

########################################################################
#                            Variables                                 #
########################################################################

#Get the current logged in user and store in variable
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Get the Mac hostname
hostName=$(scutil --get HostName)

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperInstallInProgress ()
{
#Show a message via Jamf Helper that the install is in progress
su - $loggedInUser <<'jamfmsg1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "Pro Tools 2019 installation in progress" -alignHeading natural -description "This may take up to 10 minutes to complete" -alignDescription natural &
jamfmsg1
}

function jamfHelperCopyInProgress ()
{
#Show a message via Jamf Helper that the data copy is in progress
su - $loggedInUser <<'jamfmsg2'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "Virtual Instrument content copy in progress" -alignHeading natural -description "This may take up to 30 minutes to complete" -alignDescription natural &
jamfmsg2
}

function jamfHelperUpdateComplete ()
{
#Show a message via Jamf Helper that the install has completed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "Pro Tools 2019 installation complete" -description "Pro Tools 2019 has been successfully installed" -alignDescription natural -timeout 30 -button1 "Ok" -defaultButton "1"
}

function dittoWhile ()
{
#While the installer porcess is running we wait, this leaves the jamf helper message up. Once installation is complete the message is killed
while ps axg | grep -vw grep | grep -w ditto > /dev/null;
do
        echo "Copying data..."
        sleep 1;
done
echo "Copy finished"
killall jamfHelper
sleep 2
}

function mountDMGs()
{
#Mount all the DMG's silently
hdiutil mount -noverify -nobrowse /usr/local/Pro\ Tools/Pro\ Tools/Pro_Tools_2019.6_Mac.dmg
hdiutil mount -noverify -nobrowse /usr/local/Pro\ Tools/Virtual\ Instruments\ and\ Effects/First_AIR_Effects_Bundle_12.0_Mac.dmg
hdiutil mount -noverify -nobrowse /usr/local/Pro\ Tools/Virtual\ Instruments\ and\ Effects/AIR\ Instruments\ and\ XPand2.dmg
}

function installProTools()
{
#Install all packages/apps in correct order
#iLOK
installer -pkg /usr/local/Pro\ Tools/iLok/UK_PACE_iLok_5.1.0.pkg -target /
#eLicenser
installer -pkg /usr/local/Pro\ Tools/eLicenser/UK_Steinberg_eLicenserControlCenter_6.11.8.9256.pkg -target /
#ProTools 2019.6
installer -pkg /Volumes/Pro\ Tools/Install\ Pro\ Tools\ 2019.6.0.pkg -target /
#CodecsLE
installer -pkg /Volumes/Pro\ Tools/Codec\ Installers/Install\ Avid\ Codecs\ LE.pkg -target /
#HD Driver
installer -pkg /Volumes/Pro\ Tools/Driver\ Installers/Install\ Avid\ HD\ Driver.pkg -target /
#First AIR Effects Bundle 12
installer -pkg /Volumes/First\ AIR\ Effects\ Bundle/Install\ First\ AIR\ Effects\ Bundle.pkg -target /
#First AIR Instruments Bundle 12
installer -pkg /Volumes/Virtual\ Instrument\ Content/First\ AIR\ Instruments\ Bundle\ 12\ NoAudio.pkg -target /
#Xpand II
installer -pkg /Volumes/Virtual\ Instrument\ Content/XPand\ II\ NoAudio.pkg -target /
#Waves Central
installer -pkg /usr/local/Pro\ Tools/Waves\ Central/UK_WavesCentral_10.0.1.3.pkg -target /
}

function copyVirtualInstrumentContent()
{
#Create the Folders to hold the plugins on the Pro Tools HDD
mkdir -v /Volumes/$hostName\ Pro\ Tools\ Sessions/Pro\ Tools\ Sessions/
mkdir -v /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/
#Allow everybody to RW the folders
chmod 777 /Volumes/$hostName\ Pro\ Tools\ Sessions/Pro\ Tools\ Sessions/
chmod 777 /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/

#Now copy in the audio files from the AIR Instruments and XPand2.dmg
ditto -v /Volumes/Virtual\ Instrument\ Content/ /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/

#Remove the packages that got copied in via ditto
rm -f /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/XPand\ II\ NoAudio.pkg
rm -f /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/First\ AIR\ Instruments\ Bundle\ 12\ NoAudio.pkg
}

function cleanUp()
{
#Clean up
#UnMount all DMG's
hdiutil unmount -force /Volumes/Pro\ Tools/
hdiutil unmount -force /Volumes/First\ AIR\ Effects\ Bundle/
hdiutil unmount -force /Volumes/Virtual\ Instrument\ Content/
#Remove Install DMG's and packages
rm -rf /usr/local/Pro\ Tools/

if [[ ! -d "/usr/local/Pro\ Tools/" ]]; then
  echo "Clean up has been successful"
else
  echo "Clean up FAILED, please delete the folder /usr/local/Pro\ Tools/ manually"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

mountDMGs
jamfHelperInstallInProgress
installProTools
sleep 2
killall jamfHelper

jamfHelperCopyInProgress
copyVirtualInstrumentContent
dittoWhile

jamfHelperUpdateComplete

cleanUp

exit 0
