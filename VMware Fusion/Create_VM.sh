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
loggedInUser=$(stat -f %Su /dev/console)
#Check VMware Fusion is installed
vmwareFusion="/Applications/VMware Fusion.app"
#Check VMware Fusion version
VMwareFusionVersion=$(defaults read /Applications/VMware\ Fusion.app/Contents/Info CFBundleShortVersionString | cut -c -2)
#Vfuse binary
vfuse="/usr/local/vfuse/bin/vfuse"
#qemu binary
qemu="/usr/local/bin/qemu-img"
#AutoDMG Image Location
DMGs=(/Users/"$loggedInUser"/Desktop/AutoDMG_Images/*)

########################################################################
#                            Functions                                 #
########################################################################

function checkDependencies ()
{
if [[ ! -d "$vmwareFusion" ]]; then
  echo "VMware Fusion not installed, install VMware Fusion before running again. Exiting script..."
  exit 0
else
  if [[ ! -f "$vfuse" ]] && [[ ! -f "$qemu" ]]; then
    echo "vfuse and qemu not installed"
    echo "Install vfuse from https://github.com/chilcote/vfuse/releases"
    echo "Install qemu via Homebrew, command: brew install qemu"
    echo "Exiting script..."
    exit 0
  elif [[ -f "$vfuse" ]] && [[ ! -f "$qemu" ]]; then
    echo "qemu not installed"
    echo "Install qemu via Homebrew, command: brew install qemu"
    echo "Exiting script..."
    exit 0
  elif [[ ! -f "$vfuse" ]] && [[ -f "$qemu" ]]; then
    echo "vfuse not installed"
    echo "Install vfuse from https://github.com/chilcote/vfuse/releases"
    echo "Exiting script..."
    exit 0
  else
    echo "Dependencies all installed"
  fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

checkDependencies

read -rp "Enter the VM name: " vmName

read -rp "Enter the serial number: " vmSerial

read -rp "Enter the model number identifier: " vmModel

read -rp "$(
        f=0
        for dmgname in "${DMGs[@]}" ; do
                echo "$((++f)): $dmgname"
        done

        echo -ne 'Please select a DMG > '
)" selection

selectedDMG="${DMGs[$((selection-1))]}"

echo "Check details entered are correct before continuing"
echo
echo "Virtual machine name entered: $vmName"
echo "Serial number entered: $vmSerial"
echo "Model Identifier entered: $vmModel"
echo "DMG selected: $selectedDMG"
echo

read -p "Are all details entered correct? (Yy/Nn) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Details entered incorrect, exiting script..."
    exit 0
fi

if [[ "$VMwareFusionVersion" -ge "11" ]]; then
  echo "VMware Fusion 11 installed, qemu will need to be used"
      if [[ $vmSerial == "" ]]; then
        "$vfuse" -i "$selectedDMG" --hw-model "$vmModel" --use-qemu -n "$vmName"
      else
        "$vfuse" -i "$selectedDMG" -s "$vmSerial" --hw-model "$vmModel" --use-qemu -n "$vmName"
      fi
else
  echo "VMware Fusion version 10 or previous"
      if [[ $vmSerial == "" ]]; then
        "$vfuse" -i "$selectedDMG" --hw-model "$vmModel" -n "$vmName"
      else
        "$vfuse" -i "$selectedDMG" -s "$vmSerial" --hw-model "$vmModel" -n "$vmName"
      fi
fi

exit 0