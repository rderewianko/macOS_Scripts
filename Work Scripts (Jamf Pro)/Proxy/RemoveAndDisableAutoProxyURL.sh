#!/bin/zsh

########################################################################
#                 Remove and Disable Auto Proxy URL                    #
################## Written by Phil Walker Mar 2021 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# All network services
networkServices=$(/usr/sbin/networksetup -listallnetworkservices | tail +2)
# Bauer PAC file URL
pacFile="http://proxy.bauer-uk.bauermedia.group/default.pac"
# Default Proxy bypass settings for Ethernet interfaces
proxyBypass="*.local, 169.254/16"

########################################################################
#                         Script starts here                           #
########################################################################

# Loop through all network services and remove the Auto Proxy URL if one is set
for service in ${(f)networkServices}; do
    # Check Proxy URL for all services
	autoProxyURLLocal=$(/usr/sbin/networksetup -getautoproxyurl "$service" | head -1 | cut -c 6-)
    if [[ "$autoProxyURLLocal" == "$pacFile" ]]; then
        # Set the Auto Proxy URL to a space
        /usr/sbin/networksetup -setautoproxyurl "$service" " "
        # Turn off Auto Poxy URL
		/usr/sbin/networksetup -setautoproxystate "$service" off
        # Remove custom proxy bypass address
        if [[ "$service" == "Wi-Fi" ]]; then
            /usr/sbin/networksetup -setproxybypassdomains "$service" ""
        else
            /usr/sbin/networksetup -setproxybypassdomains "$service" "$proxyBypass"
        fi
        sleep 1
        # re-populate variable
	    autoProxyURLLocal=$(/usr/sbin/networksetup -getautoproxyurl "$service" | head -1 | cut -c 6-)
        if [[ "$autoProxyURLLocal" == " " ]]; then
            echo "Auto Proxy URL removed and disabled for $service"
        else
            echo "Auto Proxy URL still set for $service"
            exit 1
        fi
    else
        echo "Auto Proxy URL not set for $service"
    fi
done
# Run an inventory update
/usr/local/jamf/bin/jamf recon
exit 0