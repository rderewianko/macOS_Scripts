#!/bin/sh

##############################################
########## Add Bauer Search Domains ##########
########### Written by Phil Walker ###########
##############################################

###################
#### Variables ####
###################

#Identify Hardware
MacModel=`ioreg -rd1 -c IOPlatformExpertDevice | awk -F'["|"]' '/model/{print $4}' | sed 's/[0-9]*//g;s/,//g'`
#Identify current network service
currentservice=$(networksetup -listallhardwareports | grep -C1 $(route get default | grep interface | awk '{print $2}') | grep "Hardware Port" | sed 's/Hardware Port: //')
#or
#currentservice=$(networksetup -listallhardwareports | grep -C1 $(route get default | grep interface | awk '{print $2}') | grep "Hardware Port" | sed 's/.*: //g')
#or
#currentservice=$(networksetup -listallhardwareports | grep -C1 $(route get default | grep interface | awk '{print $2}') | grep "Hardware Port" | sed 's/.*:[[:blank:]]//g')

#Get the IP
theLoc=`ifconfig | awk '/inet[^6]/{split($2,ip,".");theip=ip[1] "." ip[2] ".";$0=theip}

	$0 == "10.1."	{print "London"}
	$0 == "10.3."	{print "London"}
	$0 == "10.101."	{print "London"}
	$0 == "10.102."	{print "London"}
	$0 == "172.26."	{print "London"}

	$0 == "10.96."  {print "Peterborough"}
	$0 == "10.116."	{print "Peterborough"}
	$0 == "10.168." {print "Peterborough"}

' | head -n 1`

if [ $theLoc == "London" ]; then
	DNSSuffix="aca.bauer-uk.bauermedia.group"
elif [ $theLoc == "Peterborough" ]; then
	DNSSuffix="med.bauer-uk.bauermedia.group"
else
	DNSSuffix=""
fi

###################
#### Functions ####
###################


function EthernetDomainsMacPro() {

DomainsEthernet1=`/usr/sbin/networksetup -getsearchdomains "Ethernet 1" | grep "bauer" | wc -l`
DomainsEthernet2=`/usr/sbin/networksetup -getsearchdomains "Ethernet 2" | grep "bauer" | wc -l`
if [[ $DomainsEthernet1 -eq "2" ]] && [[ $DomainsEthernet2 -eq "2" ]]; then
	echo "Ethernet 1 and Ethernet 2 interface search domains correct, nothing to add"
else
	echo "Adding search domains for Ethernet 1 and Ethernet 2 interfaces"
  /usr/sbin/networksetup -setsearchdomains "Ethernet 1" $DNSSuffix bauer-uk.bauermedia.group
  /usr/sbin/networksetup -setsearchdomains "Ethernet 2" $DNSSuffix bauer-uk.bauermedia.group
fi

}

function currentServiceDomains() {

DomainsCurrentService=`/usr/sbin/networksetup -getsearchdomains "$currentservice" | grep "bauer" | wc -l`
if [[ "$DomainsCurrentService" -eq "2" ]]; then
  echo "$currentservice interface search domains correct, nothing to add"
else
  echo "Adding search domains for $currentservice interface"
  /usr/sbin/networksetup -setsearchdomains "$currentservice" $DNSSuffix bauer-uk.bauermedia.group
fi

}

function wifiDomains() {

DomainsWiFi=`/usr/sbin/networksetup -getsearchdomains "Wi-Fi" | grep "bauer" | wc -l`
if [[ "$DomainsWiFi" -eq "2" ]]; then
  echo "Wi-Fi interface search domains correct, nothing to add"
else
  echo "Adding search domains for Wi-Fi interface"
  /usr/sbin/networksetup -setsearchdomains "Wi-Fi" $DNSSuffix bauer-uk.bauermedia.group
fi

}

function confirmDomainsMacPro() {

DomainsEthernet1=`/usr/sbin/networksetup -getsearchdomains "Ethernet 1" | grep "bauer" | wc -l`
DomainsEthernet2=`/usr/sbin/networksetup -getsearchdomains "Ethernet 2" | grep "bauer" | wc -l`

if [[ $MacModel = "MacPro" ]]; then
  if [[ $DomainsEthernet1 -eq "2" ]] && [[ $DomainsEthernet2 -eq "2" ]]; then
    echo "Ethernet interfaces search domains added successfully"
else
    echo "Ethernet interfaces search domains not added"
    exit 1
  fi
fi

}


function confirmWiFiDomains() {

DomainsWiFi=`/usr/sbin/networksetup -getsearchdomains "Wi-Fi" | grep "bauer" | wc -l`

if [[ $DomainsWiFi -eq "2" ]]; then
	echo "Wi-Fi interface search domains set correctly"
else
  echo "Wi-Fi interface search domains not added"
  exit 1
fi

}

function confirmCurrentServiceDomains() {

DomainsEthernet=`/usr/sbin/networksetup -getsearchdomains "$currentservice" | grep "bauer" | wc -l`

if [[ $DomainsEthernet -eq "2" ]]; then
	echo "Ethernet interface search domains set correctly"
else
	echo "Ethernet interface search domains not added"
	exit 1
fi

}

##########################
### script starts here ###
##########################

echo "Mac model: $MacModel with the location of $theLoc"
echo "Network Connected via $currentservice"

if [[ $MacModel = *"MacBook"* ]] && [[ "$currentservice" = *"Ethernet"* ]]; then

	currentServiceDomains
	wifiDomains

	echo "Search domains being double checked..."

	confirmCurrentServiceDomains
	confirmWiFiDomains

elif [[ $MacModel = *"MacBook"* ]] && [[ "$currentservice" = *"Wi-Fi"* ]]; then

	wifiDomains

	echo "Search domains being double checked..."

  confirmWiFiDomains


elif [[ $MacModel = "MacPro" ]]; then

	EthernetDomainsMacPro

	echo "Search domains being double checked..."

  confirmDomainsMacPro

else
 # For all other models i.e iMac and Mac Mini
	currentServiceDomains

	echo "Search domains being double checked..."

  confirmCurrentServiceDomains

fi

exit 0
