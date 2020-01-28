#!/bin/bash

########################################################################
#            Install Pro Tools 2019 and all additional content         #
##################### Written by Phil Walker Oct 2019 ##################
########################################################################

#DMG's and packages are copied to local machine via Package
#This is the postinstall script to mount the DMG's and install Pro Tools and addons in the correct order

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
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -windowPosition ur -title "Message from Bauer IT" -heading "Pro Tools 2019 installation in progress" -alignHeading natural -description "This may take up to 10 minutes to complete

When prompted to send anonymous usage data to Avid, please select either Yes or No to allow the installation to continue" -alignDescription natural &
jamfmsg1
}

function jamfHelperCopyInProgress ()
{
#Show a message via Jamf Helper that the data copy is in progress
su - $loggedInUser <<'jamfmsg2'
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "Effects and Virtual Instrument Bundles install in progress" -alignHeading natural -description "This may take between 2 - 20 minutes to complete depending on your external hard disk" -alignDescription natural &
jamfmsg2
}

function jamfHelperUpdateComplete ()
{
#Show a message via Jamf Helper that the install has completed
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /Library/Application\ Support/JAMF/bin/Management\ Action.app/Contents/Resources/Self\ Service.icns -title "Message from Bauer IT" -heading "Pro Tools 2019 installation complete" -description "Pro Tools 2019 has been successfully installed" -alignDescription natural -timeout 30 -button1 "Ok" -defaultButton "1"
}

function dittoWhile ()
{
#While the content copy is running we wait, this leaves the jamf helper message up. Once the copy is complete the message is killed
while ps axg | grep -vw grep | grep -w ditto > /dev/null;
do
        echo "Copying data..."
        sleep 1;
done
echo "Copy finished"
killall jamfHelper
sleep 2
}

function mountDMGs ()
{
#Mount all the DMG's silently
hdiutil mount -noverify -nobrowse /usr/local/Pro\ Tools/Pro\ Tools/Pro_Tools_2019_10_Mac_106296_.dmg
hdiutil mount -noverify -nobrowse /usr/local/Pro\ Tools/Virtual\ Instruments\ and\ Effects/First_AIR_Effects_Bundle_12.0_Mac.dmg
hdiutil mount -noverify -nobrowse /usr/local/Pro\ Tools/Virtual\ Instruments\ and\ Effects/AIR\ Instruments\ and\ XPand2.dmg
}

function installProTools ()
{
#Install all packages/apps in correct order
#iLOK
installer -pkg /usr/local/Pro\ Tools/iLok/UK_PACE_iLok_5.1.0.pkg -target /
#eLicenser
installer -pkg /usr/local/Pro\ Tools/eLicenser/UK_Steinberg_eLicenserControlCenter_6.11.9.3259.pkg -target /
#ProTools 2019.10
installer -pkg /Volumes/Pro\ Tools/Install\ Pro\ Tools\ 2019.10.0.pkg -target /
#CodecsLE
installer -pkg /Volumes/Pro\ Tools/Codec\ Installers/Install\ Avid\ Codecs\ LE.pkg -target /
#HD Driver
installer -pkg /Volumes/Pro\ Tools/Driver\ Installers/Install\ Avid\ HD\ Driver.pkg -target /
#AvidLink Update
installer -pkg /usr/local/Pro\ Tools/Pro\ Tools/UK_Avid_Link_20.1.0.1090.pkg -target /
#First AIR Effects Bundle 12
installer -pkg /Volumes/First\ AIR\ Effects\ Bundle/Install\ First\ AIR\ Effects\ Bundle.pkg -target /
#First AIR Instruments Bundle 12
installer -pkg /Volumes/Virtual\ Instrument\ Content/First\ AIR\ Instruments\ Bundle\ 12\ NoAudio.pkg -target /
#Xpand II
installer -pkg /Volumes/Virtual\ Instrument\ Content/XPand\ II\ NoAudio.pkg -target /
#Waves Central
installer -pkg /usr/local/Pro\ Tools/Waves\ Central/UK_WavesCentral_11.0.50.pkg -target /
}

function copyVirtualInstrumentContent ()
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

function userTemplate ()
{
#Copy user template data to all existing user profiles
pathToScript=$0                                                 # path to this script - supplied by the installer
pathToPackage=$1                                                # path to the package containing this script - supplied by the installer
targetLocation=$2                                               # path to the target location - supplied by the installer
targetVolume=$3                                                 # path to the target volume - supplied by the installer
template_path="/System/Library/User Template/English.lproj"     # path to the user templates folder

#
# make some temp files to hold the user lists
#
tmp_users=$(mktemp "/tmp/users-unsort-XXXXX")
if [[ -z "$tmp_users" ]]; then
	echo "error: could not make tmp file"
	exit 1
fi


#
# Make a list of homes that are in /Users or /Volumes/Users
#
for the_folder in "$targetVolume/Users" "/Volumes/Users"; do
    if [[ -d "$the_folder" ]]; then
        ls -lTn "$the_folder" | awk -v vDIR="$the_folder" '/^d/{vUID = $3; vGID = $4; sub("^.*[0-9]+:[0-9]+.[0-9]+","");sub("^ +","");if($0 !~ "^[.]"){print vUID, vGID, vDIR "/" $0}}'
    fi
done | sed '/\/Shared/d' >> "$tmp_users"


#
# Walk the list of user details, get the users UID, GID and home folder path
#
cat "$tmp_users" | while read the_user; do
    user_uid=$(echo "$the_user" | awk '{print $1}')
    user_gid=$(echo "$the_user" | awk '{print $2}')
    user_home=$(echo "$the_user" | awk '{$1 = ""; $2 = ""; sub("^ +","");print}')

    #
    # Only process this user if we have a home folder path
    #
    if [[ -n "$user_home" ]]; then

        #
        # Get a list of files and folders loaded into user templates from this packages BOM and walk that list
        #
        lsbom -p Mf "$pathToPackage/Contents/Archive.bom" | awk -v tPath=".$template_path." '$0 ~ tPath {print}' | while read the_item; do

            #
            # check if the item is a directory or file entry, also get the items source path in user templates and target path in the users home folder
            #
            item_is_dir=$(echo "$the_item" | grep -ci "^d")
            source_item=$(echo "$the_item" | sed -E 's/^[^[:blank:]]+[[:blank:]]+[.]//')
            target_item=$(echo "$source_item" | awk -v tPath="$template_path" -v hPath="$user_home" '{sub(tPath,hPath);print}')

            #
            # Dont overwrite anything that already exists
            #
            if [[ ! -e "$target_item" ]]; then

                #
                # If the item is a directory then create it, if it is a file then copy it. Either way, set ownership to the target user
                #
                if [[ $item_is_dir -gt 0 ]]; then
                    mkdir -p "$target_item"
                else
                    ditto "$targetVolume/$source_item" "$target_item"
                fi
                chown $user_uid:$user_gid "$target_item"
            fi
        done
    fi
done
}

function cleanUp ()
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

#Mount DMG's
mountDMGs
#Install in progress jamf Helper window
jamfHelperInstallInProgress
#Install all packages
installProTools
sleep 2
#Kill the install in progess jamf Helper window
killall jamfHelper

#Copy in progress jamf Helper window
jamfHelperCopyInProgress
#Copy the Effects and Virtual Instrument content
copyVirtualInstrumentContent
#Keep checking the copy and kill the jamf Helper window once its complete
dittoWhile

#Display a jamf Helper window once everything has completed
jamfHelperUpdateComplete
#Copy user template data to all existing profiles
userTemplate
#Unmount all DMG's and remove all temporary content
cleanUp

exit 0
