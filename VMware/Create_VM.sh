#!/bin/bash

#######################################################################
#            Create a Virtual Machine for VMware Fusion               #
#       (OS DMG created with AutoDMG, vfuse and qemu required)        #
######################## written by Phil Walker ######################£
#######################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
#Check VMware Fusion is installed
vmwareFusion="/Applications/VMware Fusion.app"
#Check VMware Fusion version
vmwareFusionVersion=$(defaults read /Applications/VMware\ Fusion.app/Contents/Info CFBundleShortVersionString | cut -c -2)
#vfuse directory
vfuseDir="/usr/local/vfuse"
#vfuse binary
vfuse="/usr/local/vfuse/bin/vfuse"
#qemu binary
qemu="/usr/local/bin/qemu-img"
#AutoDMG Image Location
osImages=(/Users/$loggedInUser/Desktop/AutoDMG_Images/*)
#Script location
scriptDirectory="$(cd "$(dirname "$0")"; pwd)"

########################################################################
#                            Functions                                 #
########################################################################

function checkDependencies () 
{
if [[ ! -d "$vmwareFusion" ]]; then
  echo "VMware Fusion not installed, install VMware Fusion before running again. Exiting script..."
  exit 0
else
  if [[ ! -d "$vfuseDir" ]] && [[ ! -d "$qemu" ]]; then
    echo "vfuse and qemu not installed"
    echo "Install vfuse from https://github.com/chilcote/vfuse/releases"
    echo "Install qemu via Homebrew, command: brew install qemu"
    echo "Exiting script..."
    exit 0
      if [[ -d "$vfuseDir" ]] && [[ ! -d "$qemu" ]]; then
        echo "qemu not installed"
        echo "Install qemu via Homebrew, command: brew install qemu"
        echo "Exiting script..."
        exit 0
          if [[ ! -d "$vfuseDir" ]] && [[ -d "$qemu" ]]; then
            echo "vfuse not installed"
            echo "Install vfuse from https://github.com/chilcote/vfuse/releases"
            echo "Exiting script..."
            exit 0
  else
    echo "Dependencies all installed"
          fi
      fi
  fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

echo "$scriptDirectory"
checkDependencies

read -p "Enter the VM name: " NAME

read -p "Enter the serial number: " SERIAL

read -p "$(
        f=0
        for dmgname in "${osImages[@]}" ; do
                echo "$((++f)): $dmgname"
        done

        echo -ne 'Please select a DMG > '
)" selection

selectedDMG="${osImages[$((selection-1))]}"

echo "Check details entered are correct before continuing"
echo "---------------------------------------------------"
echo "Virtual machine name entered: $NAME"
echo "Serial number entered: $SERIAL"
echo "DMG selected: $selectedDMG"
echo "---------------------------------------------------"

read -p "Are all details entered correct? (Yy/Nn) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Details entered incorrect, exiting script..."
    exit 0
fi

if [[ $vmwareFusionVersion -ge "11" ]]; then
  echo "VMware Fusion 11 installed, qemu will need to be used"
      if [[ $SERIAL == "" ]]; then
        "$vfuse" -i "$selectedDMG" --hw-model iMac16,2 --use-qemu -n "$NAME"
      else
        "$vfuse" -i "$selectedDMG" -s $SERIAL --hw-model iMac16,2 --use-qemu -n "$NAME"
      fi
else
  echo "VMware Fusion version 10 or previous"
      if [[ $SERIAL == "" ]]; then
        "$vfuse" -i "$selectedDMG" --hw-model iMac16,2 -n "$NAME"
      else
        "$vfuse" -i "$selectedDMG" -s $SERIAL --hw-model iMac16,2 -n "$NAME"
      fi
fi

echo "Moving "$NAME" to Virtual Machines directory...."
mv -v "$scriptDirectory/$NAME.vmwarevm" "/Users/$loggedInUser/Virtual Machines.localized/"
echo "Virtual Machine created and moved to the correct directory"
