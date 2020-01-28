#!/bin/bash

#DMG's are copied to local machine via Package
#This is the postinstall script to mount the DMG's and install ProTools and addons in the corerct order
#and location as per Chris Stone guidlines.

#As part of standardising the ProTools installation we need to check that an external hard drive is connected and named correctly
#WKSxxxxx Avastor Pro Tools Sessions this is done with a installation check script
#First get the Mac hostname
hostName=$(scutil --get ComputerName)

        #Mount all the DMG's silently
        hdiutil mount -noverify -nobrowse /usr/local/ProTools/iLok/LicenseSupportInstallerMac_v3.1.7_r37900.dmg
        hdiutil mount -noverify -nobrowse /usr/local/ProTools/ProTools/Pro_Tools_12_8_1_Mac_98913.dmg
        hdiutil mount -noverify -nobrowse /usr/local/ProTools/ProTools/First_AIR_Effects_Bundle_12.0_Mac.dmg
        hdiutil mount -noverify -nobrowse /usr/local/ProTools/ProTools/AIR\ Instruments\ and\ XPand2.dmg

        #Create the Folders for hold the plugins on the Avastor HDD
        mkdir -v /Volumes/$hostName\ Avastor\ Pro\ Tools\ Sessions/Pro\ Tools\ Session
        #mkdir -v /Volumes/$hostName\ Avastor\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content
        #Allow everybody to RW the folders
        chmod 777 /Volumes/$hostName\ Avastor\ Pro\ Tools\ Sessions/Pro\ Tools\ Session
        chmod 777 /Volumes/$hostName\ Avastor\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content

        #Now copy in the audio files from the AIR Instruments and XPand2.dmg
        ditto -v /Volumes/Virtual\ Instrument\ Content/ /Volumes/$hostName\ Avastor\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/

		#Remove the pacakges that got copied in via ditto
        rm /Volumes/$hostName\ Avastor\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/XPand\ II\ NoAudio.pkg
        rm /Volumes/$hostName\ Avastor\ Pro\ Tools\ Sessions/Virtual\ Instrument\ Content/First\ AIR\ Instruments\ Bundle\ 12\ NoAudio.pkg

        #Install all packages in correct order
        #iLOK
        installer -pkg /Volumes/License\ Support\ Installer\ v3.1.7\ r37900/License\ Support.pkg -target /
        #ProTools 12.4
        installer -pkg /Volumes/Pro\ Tools/Install\ Pro\ Tools\ 12.8.1.pkg -target /
        #CodecsLE 2.5.1
        installer -pkg /Volumes/Pro\ Tools/Codec\ Installers/Install\ Avid\ Codecs\ LE.pkg -target /
        #HD Driver
        installer -pkg /Volumes/Pro\ Tools/Driver\ Installers/Install\ Avid\ HD\ Driver.pkg -target /
        #First AIR Effects Bundle 12
        installer -pkg /Volumes/First\ AIR\ Effects\ Bundle/Install\ First\ AIR\ Effects\ Bundle.pkg -target /
        #First AIR Instruments Bundle 12
        installer -pkg /Volumes/Virtual\ Instrument\ Content/First\ AIR\ Instruments\ Bundle\ 12\ NoAudio.pkg -target /
        #Xpand II
        installer -pkg /Volumes/Virtual\ Instrument\ Content/XPand\ II\ NoAudio.pkg -target /


        #UnMount all DMG's
        hdiutil unmount -force /Volumes/License\ Support\ Installer\ v3.1.7\ r37900
        hdiutil unmount -force /Volumes/Pro\ Tools/
        hdiutil unmount -force /Volumes/First\ AIR\ Effects\ Bundle/
        hdiutil unmount -force /Volumes/Virtual\ Instrument\ Content/

		#Clean up - Remove Install DMG's and packages
		rm -r /usr/local/ProTools/

exit 0
