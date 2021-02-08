#!/bin/zsh

########################################################################
#           Uninstall Oracle Java SE Runtime Environment 8             #
################## Written by Phil Walker Feb 2021 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Java Plug-in
internetPlugin="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"
# Java Pref Pane
prefPane="/Library/PreferencePanes/JavaControlPanel.prefPane"
# Check for installed JDK's
jdkCheck=$(find /Library/Java/JavaVirtualMachines -iname "*jdk*" -maxdepth 1 | awk 'END {print NR}')

########################################################################
#                            Functions                                 #
########################################################################

function checkJREVersion ()
{
# Check installed JDK version so that removal is only on Macs without Oracle JDK 8 as the active version
if [[ "$jdkCheck" -gt "0" ]]; then
    activeJDK=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    if [[ "$activeJDK" =~ "1.8" ]]; then
        jdkVersion="8"
    else
        jdkVersion=""
    fi
fi
# Get installed JRE version
if [[ -f "${internetPlugin}/Contents/Enabled.plist" ]]; then
	currentVersion=$(/usr/bin/defaults read "${internetPlugin}/Contents/Enabled.plist" CFBundleVersion)
	majorVersion=$(/usr/bin/defaults read "${internetPlugin}/Contents/Enabled.plist" CFBundleVersion | /usr/bin/awk -F'.' '{print $2}')
	if [[ "$majorVersion" -eq "8" ]] && [[ "$jdkVersion" -ne "8" ]]; then
		echo "JRE version ${currentVersion} installed"
        echo "Uninstalling JRE version: ${currentVersion}..."
	else
		echo "JRE version:${currentVersion} and JDK version: ${activeJDK} installed"
        echo "Nothing has been uninstalled"
        exit 0
	fi
else
	echo "JRE not installed, exiting"
    exit 0
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Only remove JRE if it's version 8 and JDK 8 is not the active version
checkJREVersion
# Remove the Preference Pane
if [[ -e "$prefPane" ]]; then
    rm -rf "$prefPane"
    if [[ ! -e "$prefPane" ]]; then
        echo "Java Preference Pane removed successfully"
    else
        # No need to fail if this removal fails
        echo "Java Preference Pane removal failed"        
    fi
else
    echo "Java Preference Pane not found"
fi
# Remove the plug-in
if [[ -e "$internetPlugin" ]]; then
    rm -rf "$internetPlugin"
    if [[ ! -e "$internetPlugin" ]]; then
        echo "JRE Plug-In removed successfully"
    else
        echo "JRE Plug-In removal failed"
        exit 1
    fi
else
    echo "JRE Plug-In not found"
fi
exit 0