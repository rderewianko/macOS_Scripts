#!/bin/bash

#######################################################################
#            Create a Virtual Machine for VMware Fusion               #
#       (OS DMG created with AutoDMG, vfuse and qemu required)        #
######################### written by Phil Walker ######################
#######################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Check VMware Fusion is installed
VMwareFusion="/Applications/VMware Fusion.app"
#Check VMware Fusion version
VMwareFusionVersion=$(defaults read /Applications/VMware\ Fusion.app/Contents/Info CFBundleShortVersionString | cut -c -2)
#Vfuse directory
vfuseDir="/usr/local/vfuse"
#Vfuse binary
vfuse="/usr/local/vfuse/bin/vfuse"
#AutoDMG Image Location
DMGs=(/Users/$loggedInUser/Desktop/AutoDMG_Images/*)
#Script location
ScriptDirectory="$(cd "$(dirname "$0")"; pwd)"

########################################################################
#                            Functions                                 #
########################################################################

function checkDependencies() {
if [[ ! -d "$VMwareFusion" ]]; then
  echo "VMware Fusion not installed, install VMware Fusion before running again. Exiting script..."
  exit 0
else
  if [[ ! -d "$vfuseDir" ]]; then
    echo "vfuse not installed, install vfuse from https://github.com/chilcote/vfuse/releases. Exiting script..."
    exit 0
  else
    echo "Dependencies all installed"
  fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

echo "$ScriptDirectory"
checkDependencies

read -p "Enter the VM name: " NAME

read -p "Enter the serial number: " SERIAL

read -p "$(
        f=0
        for dmgname in "${DMGs[@]}" ; do
                echo "$((++f)): $dmgname"
        done

        echo -ne 'Please select a DMG > '
)" selection

Selected_DMG="${DMGs[$((selection-1))]}"

echo "Check details entered are correct before continuing"
echo
echo "Virtual machine name entered: $NAME"
echo "Serial number entered: $SERIAL"
echo "DMG selected: $Selected_DMG"
echo

read -p "Are all details entered correct? (Yy/Nn) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Details entered incorrect, exiting script..."
    exit 0
fi

if [[ $VMwareFusionVersion -ge "11" ]]; then
  echo "VMware Fusion 11 installed, qemu will need to be used"
      if [[ $SERIAL == "" ]]; then
        "$vfuse" -i "$Selected_DMG" --hw-model iMac16,2 --use-qemu -n "$NAME"
      else
        "$vfuse" -i "$Selected_DMG" -s $SERIAL --hw-model iMac16,2 --use-qemu -n "$NAME"
      fi
else
  echo "VMware Fusion version 10 or previous"
      if [[ $SERIAL == "" ]]; then
        "$vfuse" -i "$Selected_DMG" --hw-model iMac16,2 -n "$NAME"
      else
        "$vfuse" -i "$Selected_DMG" -s $SERIAL --hw-model iMac16,2 -n "$NAME"
      fi
fi

echo "Moving "$NAME" to Virtual Machines directory...."
mv -v "$ScriptDirectory/$NAME.vmwarevm" "/Users/$loggedInUser/Virtual Machines.localized/"
echo "Virtual Machine created and moved to the correct directory"
