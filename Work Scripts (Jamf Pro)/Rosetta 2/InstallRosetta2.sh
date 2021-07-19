#!/bin/zsh

########################################################################
#                 Install Rosetta 2 on Apple Silicon Macs              #    
#################### Written by Phil Walker Nov 2020 ###################
########################################################################
# Edit July 2021

########################################################################
#                            Variables                                 #
########################################################################

# OS version
osVersion=$(sw_vers -productVersion)
# Big Sur
minReqOS="11"
# Mac model
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# Intel CPU check
intelCPU=$(sysctl -n machdep.cpu.brand_string | grep -o "Intel")
# CPU brand
cpuBrand=$(sysctl -n machdep.cpu.brand_string)
# Rosetta 2 Launch Daemon
launchDaemon="/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist"

########################################################################
#                         Script starts here                           #
########################################################################

# Load is-at-least
autoload is-at-least
# Make sure it's running Big Sur or later
if is-at-least "$minReqOS" "$osVersion"; then
    echo "$macModelFull running ${osVersion}"
    # Check to see if the Mac needs Rosetta 2 installing by checking for an Intel CPU
    if [[ -n "$intelCPU" ]]; then
        echo "CPU detected: ${cpuBrand}"
        echo "No need to install Rosetta 2"
    else
        echo "CPU detected: ${cpuBrand}"
        echo "Rosetta 2 required"
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
    fi
else
    echo "$macModelFull running ${osVersion}"
    echo "No requirement for Rosetta 2"
fi
exit 0