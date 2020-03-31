#!/bin/bash

########################################################################
#          Postinstall - Effects and Virtual Instrument Bundle         #
#################### Written by Phil Walker Nov 2019 ###################
########################################################################

#Pro Tools Bundle package (Self Service only)
#Mount the DMG's and then copy the effects and virtual instrument content

########################################################################
#                            Variables                                 #
########################################################################

#Get the current logged in user and store in variable
loggedInUser=$(stat -f %Su /dev/console)
#Get the Mac hostname
hostName=$(scutil --get HostName)

########################################################################
#                            Functions                                 #
########################################################################

function jamfHelperCopyInProgress ()
{
#Show a message via Jamf Helper that the data copy is in progress
su - $loggedInUser <<'jamfmsg1'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "PRO TOOLS 2019 BUNDLE" -alignHeading natural -description "Effects and Virtual Instrument bundle installation in progress...
This can take between 2-20 minutes to complete depending on your external hard disk" -alignDescription natural &
jamfmsg1
}

function dittoWhile ()
{
#While the content copy is running we wait, this leaves the jamf helper message up. Once the copy is complete the message is killed
while ps axg | grep -vw grep | grep -w ditto > /dev/null;
do
        echo "Copying data..."
        sleep 15;
done
echo "Copy finished"
killall jamfHelper
sleep 2
}

function mountDMGs ()
{
#Mount all the DMG's silently
hdiutil mount -noverify -nobrowse /usr/local/Pro\ Tools/Virtual\ Instruments\ and\ Effects/First_AIR_Effects_Bundle_12.0_Mac.dmg
hdiutil mount -noverify -nobrowse /usr/local/Pro\ Tools/Virtual\ Instruments\ and\ Effects/AIR\ Instruments\ and\ XPand2.dmg
}

function installPackages ()
{
#Install packages
#First AIR Effects Bundle 12
installer -pkg /Volumes/First\ AIR\ Effects\ Bundle/Install\ First\ AIR\ Effects\ Bundle.pkg -target /
#First AIR Instruments Bundle 12
installer -pkg /Volumes/Virtual\ Instrument\ Content/First\ AIR\ Instruments\ Bundle\ 12\ NoAudio.pkg -target /
#Xpand II
installer -pkg /Volumes/Virtual\ Instrument\ Content/XPand\ II\ NoAudio.pkg -target /
}

function copyVirtualInstrumentContent ()
{
#Create the folders to hold session data and virtual instruments on the Pro Tools HDD
mkdir -v /Volumes/$hostName\ Pro\ Tools\ Sessions/Pro\ Tools\ Sessions/
mkdir -v /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/
mkdir -v /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/Waves/
#Allow everybody to RWX the folders
chmod 777 /Volumes/$hostName\ Pro\ Tools\ Sessions/Pro\ Tools\ Sessions/
chmod -R 777 /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/

#Now copy in the audio files from the AIR Instruments and XPand2.dmg
ditto -v /Volumes/Virtual\ Instrument\ Content/ /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/

#Remove the packages that got copied in via ditto
rm -f /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/XPand\ II\ NoAudio.pkg
rm -f /Volumes/$hostName\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/First\ AIR\ Instruments\ Bundle\ 12\ NoAudio.pkg
}

function cleanUp ()
{
#Clean up
#Unmount all DMG's
hdiutil unmount -force /Volumes/First\ AIR\ Effects\ Bundle/
hdiutil unmount -force /Volumes/Virtual\ Instrument\ Content/
#Remove install DMG's
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

#Mount DMG's
mountDMGs
#Copy in progress jamf Helper window
jamfHelperCopyInProgress
#Install packages
installPackages
#Copy the Effects and Virtual Instrument content
copyVirtualInstrumentContent
#Keep checking the copy and kill the jamf Helper window once its complete
dittoWhile
#Unmount all DMG's and remove all temporary content
cleanUp

exit 0
