#!/bin/zsh

########################################################################
#              Disable IPv6 for all network services                   #
################## Written by Phil Walker Mar 2021 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# All network services
networkServices=$(networksetup -listallnetworkservices | tail +2)

########################################################################
#                         Script starts here                           #
########################################################################

echo "Turning off IPv6 for all network services..."
# Loop through all network services and turn IPv6 off
for service in ${(f)networkServices}; do
    # Check IPv6 is available for the service
	ipv6Status=$(networksetup -getinfo "$service" | grep "IPv6")
    if [[ "$ipv6Status" != "" ]]; then
        # Disable IPv6
        networksetup -setv6off "$service"
        sleep 1
        # Check status of IPv6
	    postCheck=$(networksetup -getinfo "$service" | grep "IPv6:" | awk '{print $2}')
        if [[ "$postCheck" == "Off" ]]; then
            echo "IPv6 turned off for $service"
        else
            echo "IPv6 still enabled for $service"
            exit 1
        fi
    fi
done
exit 0