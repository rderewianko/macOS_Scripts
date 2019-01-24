#!/bin/bash

#######################################################################
#            Create a Virtual Machine for VMware Fusion               #
#        (OS DMG create with AutoDMG, vfuse and qemu required)        #
######################### written by Phil Walker ######################
#######################################################################

#Check VMware Fusion is installed
VMware_Fusion=$(ls -1 /Applications/ | grep -i "vmware" | wc -l)
#Check VMware Fusion version
VMware_Version=$(defaults read /Applications/VMware\ Fusion.app/Contents/Info CFBundleShortVersionString | cut -c -2)
#Vfuse directory
vfuse_Loc="/usr/local/vfuse"
#Vfuse binary
vfuse="/usr/local/vfuse/bin/vfuse"
#AutoDMG Image Location
DMGs=(/Users/philwalker/Desktop/AutoDMG_Images/*)

#function checkVMwareFusion() {
#if [[  ]]
#}

function checkDependencies() {
if [[ $VMware_Fusion -lt "1" ]]; then
  echo "VMware Fusion not installed, install VMware Fusion before running again. Exiting script..."
  exit 1
else
  if [[ ! -d "$vfuse_Loc" ]]; then
    echo "vfuse not installed, install vfuse from https://github.com/chilcote/vfuse/releases. Exiting script..."
    exit 1
  else
    echo "Dependencies all installed"
  fi
fi
}

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
    exit 1
fi

if [[ $VMware_Version -ge "11" ]]; then
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
mv -v "/Users/philwalker/Desktop/$NAME.vmwarevm" "/Users/philwalker/Virtual Machines/"
echo "Virtual Machine created and moved to the correct directory"
