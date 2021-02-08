#!/bin/zsh

########################################################################
#        Remove Microsoft Office 2016 for Mac Perpetual License        #
################## Written by Phil Walker July 2019 ####################
######################## Revised October 2019 ##########################
########################################################################

# Perpetual license file
perpetualLicense="/Library/Preferences/com.microsoft.office.licensingV2.plist"
# Check for a perpetual license file, if one is found then delete it
if [[ -f "$perpetualLicense" ]]; then
    echo "Office 2016 volume license file found"
    echo "Removing Office 2016 volume license file..."
    rm -f "$perpetualLicense"
    # re-populate variable
    perpetualLicense="/Library/Preferences/com.microsoft.office.licensingV2.plist"
    if [[ ! -f "$perpetualLicense" ]]; then
        echo "Office 2016 volume license successfully removed"
    else
        echo "Office 2016 volume license removal FAILED"
        echo "Please delete ${perpetualLicense} manually"
    fi
else
    echo "Office 2016 volume license file not found"
fi

# Package receipts
pkgReceipt1=$(pkgutil --pkgs | grep "com.microsoft.pkg.licensing")
pkgReceipt2=$(pkgutil --pkgs | grep "com.microsoft.pkg.licensing.volume")
# Check for the serialiser package receipts, if one is found then remove it
if [[ "$pkgReceipt1" != "" ]] || [[ "$pkgReceipt2" != "" ]]; then
    echo "Removing VL Serialiser V2 package receipts..."
    pkgutil --forget "com.microsoft.pkg.licensing.volume" >/dev/null 2>&1
    pkgutil --forget "com.microsoft.pkg.licensing" >/dev/null 2>&1
    # re-populate variables
    pkgReceipt1=$(pkgutil --pkgs | grep "com.microsoft.pkg.licensing.volume")
    pkgReceipt2=$(pkgutil --pkgs | grep "com.microsoft.pkg.licensing")
    if [[ "$pkgReceipt1" == "" ]] && [[ "$pkgReceipt2" == "" ]]; then
        echo "Package receipts for VL Serialiser V2 successfully removed"
    fi
else
    echo "Package receipts for VL Serialiser V2 not found"
fi
exit 0
