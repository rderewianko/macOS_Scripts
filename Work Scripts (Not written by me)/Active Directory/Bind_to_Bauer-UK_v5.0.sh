#!/bin/bash

########################################################
# Bind a Mac to AD if the following conditions are met:#
# 1) The Mac is not already bound					   #
# 2) The hostname is coorectly formatted with wks*****   #
########################################################
hostName=`/usr/local/jamf/bin/jamf getComputerName | sed -E 's/^[^>]+>//;s/<[^>]+>//;s/_.*$//'`	# the hostname for this Mac
theSerial=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`
theUser="********"									# Username for AD bind account
thePass="*********"								# password for the AD account
theDomain="YOUR_AD_DOMAIN_HERE"				# AD forest for bind
check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`
model=$(system_profiler SPHardwareDataType | awk '/Model Name/ {print $3}')
if [ "$model" == "MacBook" ]; then
  macModel="Laptop"
else
  macModel="Desktop"
fi
  #statements
DomainPing=$(ping -c1 -W5 -q bauer-uk.bauermedia.group | head -n1 | sed 's/.*(\(.*\))/\1/;s/:.*//')

function unBindFromAD ()
{
  echo "Unbinding from AD"
  sudo dsconfigad -force -remove -u $theUser -p $thePass
  echo "AD unbind complete"
}
function bindtoAD ()
{
  hostName=`/usr/local/jamf/bin/jamf getComputerName | sed -E 's/^[^>]+>//;s/<[^>]+>//;s/_.*$//'`	# the hostname for this Mac

    #Set the OU based on model for the computer record to be added into
    theOU="OU=$macModel,OU=Macs,OU=uk,OU=bauer,DC=bauer-uk,DC=bauermedia,DC=group"

    /usr/local/jamf/bin/jamf bind -type ad -domain "$theDomain" -computerID "$hostName" -username "$theUser" -password "$thePass" -ou "$theOU" -cache -defaultShell /bin/bash -localHomes

    #Add the computer name to the asset tag field in the JSS
    jamf recon -assetTag "$hostName"

}

function getcomputerOU ()
{
  ad_computer_ou=`dscl /Search read /Computers/$hostName$ | \
  grep -A 1 dsAttrTypeNative:distinguishedName | \
  cut -d, -f2- | sed -n 's/OU\=//gp' | \
  sed -n 's/\(.*\),DC\=/\1./gp' | \
  sed -n 's/DC\=//gp' | \
  awk -F, '{
  N = NF
  while ( N > 1 )
  {
  printf "%s/",$N
  N--
  }

  printf "%s",$1
  }'`
  if [[ "$ad_computer_ou" == *"Error"* ]]; then
      echo "$hostName not in AD as no OU found"
  else
    echo "Computer OU $ad_computer_ou"
  fi
}

function configureSSHAccess ()
{
#Check the bind worked so SSH access can be added
if [ "${check4AD}" == "Active Directory" ]; then
  # Create new SACL group
  	dseditgroup -o create -q com.apple.access_ssh
  # Recreate casadmin access in the new SACL group
  	dseditgroup -o edit -a "casadmin" -t user com.apple.access_ssh
  # Add the AD groups to the new SACL group
  	dseditgroup -o edit -a "rol-adm-uk-casper_admins" -t group com.apple.access_ssh
  	dseditgroup -o edit -a "rol-adm-uk-casper_superusers" -t group com.apple.access_ssh
  # Add the AD groups to the Admin group on the Mac client
  	dseditgroup -o edit -a "rol-adm-uk-casper_admins" -t group admin
  	dseditgroup -o edit -a "rol-adm-uk-casper_superusers" -t group admin

		#Check rol groups can now SSH
		SSHAccess=$(dscl . -read /Groups/com.apple.access_ssh | grep "NestedGroups")
		if [[ -z $SSHAccess ]]; then
			echo "Something went wrong, SSH access NOT configured"
			exit 1
		else
  		echo "rol-adm-uk-casper_admins and rol-adm-uk-casper_superusers can now SSH to this Mac ($hostName)"
		fi
else
      echo "This Mac $hostName is NOT bound to Active Directory so SSH access cannot be configured"
      exit 1
fi
}
#############################################################
#Check we can get to AD, bomb out if we can't get the server
#############################################################
if [[ "$DomainPing" == "" ]]; then
		echo "$theDomain is not reachable"
    exit 1
else
		echo "$theDomain is reachable"
fi

##############################################################
# Check if Mac is already bound
##############################################################

if [ "${check4AD}" == "Active Directory" ]; then
      #If the Mac is bound to AD then report success
      echo "This $model $hostName is already bound to Active Directory"

      #Next Check that the computer is in the correct OU
      getcomputerOU
      if [[ "$ad_computer_ou" == *"_mac"* || "$ad_computer_ou" == "bauermedia.group/bauer-uk/bauer/uk/Macs" ]]; then
        echo "Incorrect OU found! Moving to correct OU"
        unBindFromAD
        bindtoAD
        getcomputerOU
        sleep 3
        configureSSHAccess
      else
          echo "$hostName is in correct OU"
          configureSSHAccess
      fi
      exit 0
      if [ "${check4AD}" != "Active Directory" ]; then
        	echo " "
          exit 1
	    fi
###################################################################
#Mac not bound so perform additional hostname checks before binding
###################################################################
else
  echo "This $model $hostName is NOT bound to Active Directory"

  #Get the hostname
  hostName=`/usr/local/jamf/bin/jamf getComputerName | sed -E 's/^[^>]+>//;s/<[^>]+>//;s/_.*$//'`	# the hostname for this Mac
  echo "Hostname is currently $hostName"
    #############################################################
    #Check if the hostname contains wks and bind accordingly
    #############################################################
    if [[ $hostName == wks* ]]; then
      echo "$hostName Correctly formatted HostName bind to AD"
      bindtoAD
      getcomputerOU
      sleep 3
      configureSSHAccess
    #################################################################
    #Hostname doesn't include wks so set hostname to Serial and bind
    ##################################################################
    else
      echo "$hostName Incorrectly formatted HostName change hostname to it's Seiral number and bind"

      #Change the hostname to the serial numbers
      echo "Updating mac computer name..."
      /usr/sbin/scutil --set ComputerName "$theSerial"
      /usr/sbin/scutil --set LocalHostName "$theSerial"
      /usr/sbin/scutil --set HostName "$theSerial"

      #Get the hostname
      hostName=`/usr/local/jamf/bin/jamf getComputerName | sed -E 's/^[^>]+>//;s/<[^>]+>//;s/_.*$//'`	# the hostname for this Mac
      echo "Hostname set to $hostName"

      #Now bind using using the hostname set based on the serial number
      bindtoAD
      getcomputerOU
      configureSSHAccess
    fi
fi
