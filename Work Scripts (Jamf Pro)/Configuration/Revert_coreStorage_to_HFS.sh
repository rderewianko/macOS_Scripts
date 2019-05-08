#!/bin/bash

########################################################################
#               Revert Core Storage back to HFS+                       #
############## Written by Phil Walker March 2018 #######################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

csLVGUUID=$(/usr/sbin/diskutil list | grep -A1 "Logical Volume on" | tail -1)
echo "Logical Volume has UUID: $csLVGUUID..."

csRevertible=$(/usr/sbin/diskutil cs list | grep "Revertible" | awk '{print $2}')

########################################################################
#                            Functions                                 #
########################################################################

function checkRevertible() {
if [ "$csRevertible" = "Yes" ]; then
  echo "Core Storage Volume revertible"
  /usr/sbin/diskutil corestorage revert $csLVGUUID
else
  echo "Core Storage Volume not revertible"
  exit 1
fi
}

function checkRevert() {
csRevertStatus=$(diskutil cs list | grep "Revert Status" | awk '{print $3,$4,$5,$6,$7}')
if [ "$csRevertStatus" = "PV to LV passthrough mode" ]; then
  echo "Core Storage reverted back successfully"
  echo "Must restart for changes to take affect"
  shutdown -r now
  exit 0
else
  echo "Reverting from Core Storage to HFS failed"
  exit 1
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [ -z "$csLVGUUID" ]; then
        echo "No Core Storage found, nothing to do"
        exit 0
else
        checkRevertible
        checkRevert
fi
exit 0
