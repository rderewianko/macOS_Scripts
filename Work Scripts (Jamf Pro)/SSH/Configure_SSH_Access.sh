#!/bin/zsh

########################################################################
#              Configure SSH and Admin Access (AD Groups)              #
################### Written by Phil Walker Dec 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Check if the domain is reachable
domainPing=$(ping -c1 -W5 -q "your domain" 2>/dev/null | head -n1 | sed 's/.*(\(.*\))/\1/;s/:.*//')
# AD Domain
theDomain="your domain"
# Check the Mac is bound to AD
checkbindStatus=$(/usr/bin/dscl localhost -list . | grep "Active Directory")
# Get the HostName
hostName=$(scutil --get HostName)
# Mac model
modelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# Check rol groups SSH access
SSHAccess=$(dscl . -read /Groups/com.apple.access_ssh | grep "NestedGroups" | awk '{print $2, $3}' | wc -w)

########################################################################
#                            Functions                                 #
########################################################################

function configureSSHAccess ()
{
# Create new SACL group
dseditgroup -o create -q com.apple.access_ssh
# Recreate management account access in the new SACL group
dseditgroup -o edit -a "your management/local admin account" -t user com.apple.access_ssh
# Add the AD groups to the new SACL group
dseditgroup -o edit -a "security group for ssh access" -t group com.apple.access_ssh
dseditgroup -o edit -a "security group for ssh access" -t group com.apple.access_ssh
# Add the AD groups to the Admin group on the Mac client
dseditgroup -o edit -a "security group for admin users" -t group admin
dseditgroup -o edit -a "security group for admin users" -t group admin

# Check security groups can now SSH
SSHAccess=$(dscl . -read /Groups/com.apple.access_ssh | grep "NestedGroups" | awk '{print $2, $3}' | wc -w)
if [[ "$SSHAccess" -ne "2" ]]; then
	echo "Something went wrong, SSH access NOT configured"
	exit 1
else
  	echo "Members of group 1 and group 2 can now SSH to this Mac ($hostName)"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$domainPing" != "" ]]; then
	echo "$theDomain is reachable"
    if [[ "$checkbindStatus" == "Active Directory" ]]; then
        echo "This $modelFull $hostName is bound to Active Directory, checking SSH access..."
        if [[ "$SSHAccess" -ne "2" ]]; then
            echo "Configuring SSH access..."
            configureSSHAccess
        else
            echo "SSH access already configured"
            echo "Members of group 1 and group 2 can SSH to this Mac ($hostName)"
        fi
    else
        echo "This $modelFull $hostName is not bound to Active Directory"
        echo "Calling the bind policy which includes configuring SSH access..."
        /usr/local/jamf/bin/jamf policy -event "custom event"
        exit 0
    fi
else
    echo "$theDomain is not reachable, unable to check SSH access"
fi
exit 0