#!/bin/zsh

########################################################################
################# Written by Suleyman Twana Aug 2019 ###################
########################################################################
# Edit Phil Walker May 2021

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Management account username
mngmtAccount="$4"
############ Variables for Jamf Pro Parameters - End ###################

# Get a list of users and include the management account
userList=$(dscl . -list /Users | grep -v "^_\|daemon\|nobody\|root\|admin\|${mngmtAccount}")
appPath="/Applications/FontExplorer X Pro.app/"
appProcess=$(pgrep -i "fontexplorer")
fexPlugins=$(find /Applications -name "*FontExplorer X for*" -type d -maxdepth 3)
userTempPath="/Library/User Template/English.lproj/Library/Application Support/Linotype/"
sharedContentFEX="/Users/Shared/FontExplorer"
sharedContentLino="/Users/Shared/Linotype"

########################################################################
#                            Functions                                 #
########################################################################

function checkAppPath ()
{
if [[ ! -d "${appPath}" ]]; then
	echo "FontExplorer X Pro is not installed"
    exit 0
else
	echo "FontExplorer X Pro is installed"
fi
}

function checkApppID ()
{
if [[ ! "$appProcess" ]]; then
	echo "FontExplorer X Pro is not running"
else
	echo "FontExplorer X Pro is running"
    kill -9 pid "$appProcess" 2> /dev/null
	echo "FontExplorer X Pro is closed"
fi
}

function removeApp ()
{
rm -rf "${appPath}"
if [[ ! -d "$appPath" ]]; then
    echo "FontExplorer X Pro app has been successfully removed"
else
    echo "Failed to remove the FontExplorer X Pro app"
    exit 1
fi
}

function removePlugins ()
{
if [[ "$fexPlugins" != "" ]]; then
    for plugin in ${(f)fexPlugins}; do
		rm -rf "$plugin"
        echo "Removed ${plugin}"
    done
else
	echo "No FontExplorer X plug-ins found"
fi
}

function removeAsociatedFiles ()
{
# User Template
if [[ -d "$userTempPath" ]]; then
	rm -rf "${userTempPath}"
    if [[ ! -d "$userTempPath" ]]; then
        echo "FontExplorer X Pro User Template data removed"
    fi
fi
# Shared directory
if [[ -d "$sharedContentFEX" ]] || [[ -d "$sharedContentLino" ]]; then
    rm -rf "$sharedContentFEX" 2>/dev/null
    rm -rf "$sharedContentLino"
    if [[ ! -d "$sharedContentFEX" ]] && [[ ! -d "$sharedContentLino" ]]; then
        echo "FontExplorer X Pro shared directory removed"
    fi
fi
# User content
for user in ${(f)userList}; do
    echo "Checking for FontExplorer X Pro content in ${user}'s profile..."
    if [[ -d "/Users/${user}/Library/Application Support/Linotype/" ]]; then
        rm -r "/Users/${user}/Library/Application Support/Linotype/"
        if [[ ! -d "/Users/${user}/Library/Application Support/Linotype/" ]]; then
            echo "Application Support content removed"
        fi
    fi
    if [[ -f "/Users/${user}/Library/Preferences/com.linotype.FontExplorerX.plist" ]]; then
        rm "/Users/${user}/Library/Preferences/com.linotype.FontExplorerX.plist"
        if [[ ! -f "/Users/${user}/Library/Preferences/com.linotype.FontExplorerX.plist" ]]; then
            echo "Preferences removed"
        fi
    fi
    if [[ -f "/Users/${user}/Library/LaunchAgents/com.linotype.FontFolderProtector.plist" ]]; then
        rm "/Users/${user}/Library/LaunchAgents/com.linotype.FontFolderProtector.plist"
        if [[ ! -f "/Users/${user}/Library/LaunchAgents/com.linotype.FontFolderProtector.plist" ]]; then
            echo "Launch Agent removed"
        fi
    fi
done
}

########################################################################
#                         Script starts here                           #
########################################################################

checkAppPath
checkApppID
removeApp
removePlugins
removeAsociatedFiles
exit 0