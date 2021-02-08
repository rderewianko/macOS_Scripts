#!/bin/zsh

########################################################################
#                 Install Rosetta 2 on Apple Silicon Macs              #    
#################### Written by Phil Walker Nov 2020 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# OS version
osVersion=$(sw_vers -productVersion)
# Big Sur
minReqOS="11"
# Mac model
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# CPU Architecture
cpuArch=$(/usr/bin/arch)
# Rosetta 2 Launch Daemon
launchDaemon="/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist"

########################################################################
#                         Script starts here                           #
########################################################################

# Load is-at-least
autoload is-at-least
# Make sure it's running Big Sur or later
if is-at-least "$minReqOS" "$osVersion"; then
    echo "$macModelFull running ${osVersion}, checking to see if Rosetta 2 is required..."
    # Check to see if the Mac needs Rosetta 2 installing by checking for an ARM CPU
    if [[ "$cpuArch" == "arm64" ]]; then
        # Check Rosetta Launch Daemon. If no Launch Daemon is found,
        # perform a non-interactive install of Rosetta 2
        if [[ ! -f "$launchDaemon" ]]; then
            softwareupdate --install-rosetta --agree-to-license
            installResult="$?"
            if [[ "$installResult" -eq "0" ]]; then
        	    echo "Rosetta 2 has been successfully installed"
            else
        	    echo "Rosetta 2 installation failed!"
                exit 1
            fi
        else
    	    echo "Rosetta 2 is already installed, nothing to do"
        fi
    else
        echo "Intel processor detected, no need to install Rosetta 2"
    fi
else
    echo "$macModelFull running ${osVersion}"
    echo "No requirement for Rosetta 2"
fi
exit 0