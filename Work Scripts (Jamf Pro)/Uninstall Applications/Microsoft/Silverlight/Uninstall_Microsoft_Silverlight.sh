#!/bin/zsh

#########################################################################
#					  Uninstall Microsoft Silverlight					#
#########################################################################

########################################################################
#                            Variables                                 #
########################################################################

internetPlugin=$(find "/Library/Internet Plug-Ins" -iname "*Silverlight*" -type d -maxdepth 1)
appSupportDirectory=$(find "/Library/Application Support/Microsoft" -iname "Silverlight" -type d -maxdepth 1)

########################################################################
#                            Functions                                 #
########################################################################

cleanUpOldContent ()
{
# Remove older content
rm -rf "/Library/Receipts/Silverlight.pkg" >/dev/null 2>&1
rm -rf "/Library/Receipts/Silverlight_W2_MIX.pkg" >/dev/null 2>&1
rm -rf "/Library/Internet Plug-Ins/WPFe.plugin" >/dev/null 2>&1
rm -rf "/Library/Receipts/WPFe.pkg" >/dev/null 2>&1
}

########################################################################
#                         Script starts here                           #
########################################################################

# Check if any Microsoft Silverlight components are installed
if [[ "$internetPlugin" == "" ]] && [[ "$appSupportDirectory" == "" ]]; then
	echo "No Silverlight components found"
else
	# If any Silverlight components found, remove them 
	if [[ "$internetPlugin" != "" ]]; then
		echo "Silverlight Internet Plug-In found"
		rm -rf "/Library/Internet Plug-Ins/Silverlight.plugin"
		if [[ ! -d "/Library/Internet Plug-Ins/Silverlight.plugin" ]]; then
			echo "Silverlight Internet Plug-In removed"
		else
			echo "Failed to remove the Silverlight Internet Plug-In"
		fi
	fi
	if [[ "$appSupportDirectory" != "" ]]; then
		echo "Silverlight Application Support directory found"
		rm -rf "/Library/Application Support/Microsoft/Silverlight"
		if [[ ! -d "/Library/Application Support/Microsoft/Silverlight" ]]; then
			echo "Silverlight Application Support directory removed"
		else
			echo "Failed to remove the Silverlight Application Support directory"
        fi
	fi
	# Make sure all old content is also removed
	cleanUpOldContent
fi
exit 0