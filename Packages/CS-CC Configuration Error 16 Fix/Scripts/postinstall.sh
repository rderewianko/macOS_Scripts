#!/bin/bash

########################################################################
#            Adobe CS & CC Configuration Error 16 Fix                  #
################# Written by Phil Walker July 2017 #####################
####################### postinstall script #############################
########################################################################

## Updated Feb 2018

########################################################################
#                            Variables                                 #
########################################################################

tmp="/usr/local/Adobe/"
PCD="/Library/Application Support/Adobe/Adobe PCD/"
SLStore="/Library/Application Support/Adobe/SLStore/"
PCDCache="/Library/Application Support/Adobe/Adobe PCD/cache/"
CS_CC=$(ls /Library/Application\ Support/regid.1986-12.com.adobe/* 2>/dev/null | wc -l)
CS6=$(ls /Applications/ | grep -i "CS6" 2>/dev/null | wc -l)
SWID_CS6DS="/Library/Application Support/regid.1986-12.com.adobe/regid.1986-12.com.adobe_DesignSuiteStandard-CS6-Mac-GM-en_GB.swidtag"
SWID_AXP="/Library/Application Support/regid.1986-12.com.adobe/regid.1986-12.com.adobe_AcrobatPro-AS1-Mac-GM-MUL.swidtag"
SWID_CC_V6=$(ls /Library/Application\ Support/regid.1986-12.com.adobe/regid.1986-12.com.adobe_V6* 2>/dev/null | wc -l)
SWID_CC_V7=$(ls /Library/Application\ Support/regid.1986-12.com.adobe/regid.1986-12.com.adobe_V7* 2>/dev/null | wc -l)
PCDperms=$(find "/Library/Application Support/Adobe/Adobe PCD/" -type d -perm 755 2>/dev/null | wc -l)
SLStoreperms=$(find "/Library/Application Support/Adobe/SLStore/" -type d -perm 777 2>/dev/null | wc -l)
PCDCacheperms=$(find "/Library/Application Support/Adobe/Adobe PCD/cache/" -type d -perm 777 2>/dev/null | wc -l)


########################################################################
#                            Functions                                 #
########################################################################

function cleanUp ()
{
#Cleanup installation files
rm -Rf "$tmp"
if [ ! -e $tmp ] ; then
  echo "Cleanup complete"
else
  echo "Cleanup failed - Delete the folder /usr/local/Adobe manually"
fi

}

function permissionsChange ()
{
#set correct permissions
chmod -R 755 "$PCD"
chown -R root:admin "$PCD"
chmod -R 777 "$SLStore"
chown -R root:admin "$SLStore"
chmod -R 777 "$PCDCache"
}

function replaceDirectories ()
{
#Remove and replace the Adobe licensing folders (CS6 Design Standard only)
echo "Replacing Adobe PCD & SLStore folders..."
  rm -Rf "$PCD" 2>/dev/null
  rm -Rf "$SLStore" 2>/dev/null
  ditto "$tmp" /Library/Application\ Support/Adobe
}

function checkPermissions ()
{
#check permissions have been set correctly
if [[ "$PCDperms" == 0 ]] && [[ "$SLStoreperms" == 0 ]] && [[ "$PCDCacheperms" == 0 ]] ; then
  echo "Permissions not set correctly on Adobe licensing folders - Please reinstall the product"
  exit 1
else
  echo "Correct permissions set on Adobe licensing folders - REBOOT REQUIRED"
fi
}

function checkDirectories ()
{
#check if Adobe licensing folders are present
if [[ -e "$PCD" && -e "$SLStore" ]] ; then
  echo "Adobe licensing folders found"
else
  echo "Adobe licensing folders not found - Please reinstall the product"
  cleanUp
  exit 1
fi
}

function checkDirectoryReplacement ()
{
#check if Adobe licensing folders are present after replacement
if [[ -e "$PCD" && -e "$SLStore" ]] ; then
  echo "Adobe licensing folders successfully replaced"
else
  echo "Adobe licensing folders not found, replacement failed - Please reinstall the product"
  cleanUp
  exit 1
fi
}

function additionalAdobeApps ()
{
#Commands to run when CS6 Design Standard isnt found or is found alongside additional Adobe Apps
checkDirectories
permissionsChange
checkPermissions
cleanUp
}

function designStandardOnly ()
{
#Commands to run when only CS6 Design Standard is found
checkDirectories
replaceDirectories
checkDirectoryReplacement
checkPermissions
cleanUp
}

function adobeApp ()
{
#Check if CS6 Design Standard is installed but no app has ever been succesfully launched
if [[ "$CS_CC" -eq "0" ]] && [[ "$CS6" -eq "6" ]]; then
  echo "Adobe CS6 Design Standard installed but no app successfully launched (no additional CS or CC Apps found)"
  designStandardOnly
  cleanUp
fi
}


########################################################################
#                         Script starts here                           #
########################################################################

adobeApp

if [ ! -e "$SWID_CS6DS" ] ; then
echo "Adobe CS6 Design Standard not found"
  additionalAdobeApps

elif [ -e "$SWID_CS6DS" ] && [[ "$SWID_CC_V6" -gt "0" ]] || [[ "$SWID_CC_V7" -gt "0" ]] ; then
  echo "Adobe CS6 Design Standard and Adobe Creative Cloud Apps found"
  additionalAdobeApps

elif [[ -e "$SWID_CS6DS" && -e "$SWID_AXP" ]]  && [[ "$CS_CC" -gt "2" ]] ; then
  echo "Adobe CS6 Design Standard & additional CS Apps found"
  additionalAdobeApps

elif [[ -e "$SWID_CS6DS" && ! -e "$SWID_AXP" ]] && [[ "$CS_CC" -ge "2" ]] ; then
  echo "Adobe CS6 Design Standard & additional CS Apps found"
  additionalAdobeApps

else
  echo "Adobe CS6 Design Standard installed (no additional CS or CC SWIDs found)"
  designStandardOnly

fi

exit 0
