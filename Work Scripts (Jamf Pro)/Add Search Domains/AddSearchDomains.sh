#!/bin/sh

########################################################################
#                   Add Bauer Search Domains                           #
#################### Written by Phil Walker ############################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Identify Hardware
MacModel=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'["|"]' '/model/{print $4}' | sed 's/[0-9]*//g;s/,//g')
#Identify current network service
currentService=$(networksetup -listallhardwareports | grep -C1 $(route get default | grep interface | awk '{print $2}') | grep "Hardware Port" | sed 's/Hardware Port: //')

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

#Set DNS suffix based on location
if [[ "$theLoc" == "London" ]]; then
	DNSSuffix="aca.bauer-uk.bauermedia.group"
elif [[ "$theLoc" == "Peterborough" ]]; then
	DNSSuffix="med.bauer-uk.bauermedia.group"
else
	DNSSuffix=""
fi

#Set total search domain integer based on DNS suffix value
if [[ $DNSSuffix == "" ]]; then
	DomainCount="1"
else
	DomainCount="2"
fi

########################################################################
#                            Functions                                 #
########################################################################


function EthernetDomainsMacPro() {

DomainsEthernet1=$(/usr/sbin/networksetup -getsearchdomains "Ethernet 1" | grep "bauer" | wc -l)
DomainsEthernet2=$(/usr/sbin/networksetup -getsearchdomains "Ethernet 2" | grep "bauer" | wc -l)

echo "Checking search domains..."
if [[ $DomainsEthernet1 -eq "$DomainCount" ]] && [[ $DomainsEthernet2 -eq "$DomainCount" ]]; then
	echo "Ethernet 1 and 2 interfaces search domains correct, nothing to add"
else
	echo "Adding search domains for Ethernet 1 and 2 interfaces"
  /usr/sbin/networksetup -setsearchdomains "Ethernet 1" $DNSSuffix bauer-uk.bauermedia.group
  /usr/sbin/networksetup -setsearchdomains "Ethernet 2" $DNSSuffix bauer-uk.bauermedia.group
fi

}

function currentServiceDomains() {

DomainsCurrentService=$(/usr/sbin/networksetup -getsearchdomains "$currentService" | grep "bauer" | wc -l)

echo "Checking search domains..."
if [[ "$DomainsCurrentService" -eq "$DomainCount" ]]; then
  echo "$currentService interface search domains correct, nothing to add"
else
  echo "Adding search domains for $currentService interface"
	 /usr/sbin/networksetup -setsearchdomains "$currentService" $DNSSuffix bauer-uk.bauermedia.group
fi

}

function wifiDomains() {

DomainsWiFi=$(/usr/sbin/networksetup -getsearchdomains "Wi-Fi" | grep "bauer" | wc -l)

echo "Checking search domains..."
if [[ "$DomainsWiFi" -eq "$DomainCount" ]]; then
  echo "Wi-Fi interface search domains correct, nothing to add"
else
  echo "Adding search domains for Wi-Fi interface"
  /usr/sbin/networksetup -setsearchdomains "Wi-Fi" $DNSSuffix bauer-uk.bauermedia.group
fi

}

function confirmDomainsMacPro() {

DomainsEthernet1=$(/usr/sbin/networksetup -getsearchdomains "Ethernet 1" | grep "bauer" | wc -l)
DomainsEthernet2=$(/usr/sbin/networksetup -getsearchdomains "Ethernet 2" | grep "bauer" | wc -l)

if [[ $MacModel == "MacPro" ]]; then
  if [[ $DomainsEthernet1 -eq "$DomainCount" ]] && [[ $DomainsEthernet2 -eq "$DomainCount" ]]; then
    echo "RESULT: Ethernet interfaces search domains correct"
else
    echo "RESULT: Ethernet interfaces search domains not added"
    exit 1
	fi
fi

}


function confirmWiFiDomains() {

DomainsWiFi=$(/usr/sbin/networksetup -getsearchdomains "Wi-Fi" | grep "bauer" | wc -l)

if [[ $DomainsWiFi -eq "$DomainCount" ]]; then
	echo "RESULT: Wi-Fi interface search domains correct"
else
  echo "RESULT: Wi-Fi interface search domains not added"
  exit 1
fi

}

function confirmCurrentServiceDomains() {

DomainsCurrent=$(/usr/sbin/networksetup -getsearchdomains "$currentService" | grep "bauer" | wc -l)

if [[ $DomainsCurrent -eq "$DomainCount" ]]; then
	echo "RESULT: $currentService search domains correct"
else
	echo "RESULT: $currentService search domains not added"
	exit 1
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

echo "$MacModel with the location of $theLoc"
echo "Connected to network via $currentService"
echo "Search Domains Count: $DomainCount"

if [[ $MacModel = *"MacBook"* ]] && [[ "$currentService" = *"Ethernet"* || "$currentService" == "USB 10/100/1000 LAN" ]]; then

	currentServiceDomains
	wifiDomains

	echo "Search domains being double checked..."

	confirmCurrentServiceDomains
	confirmWiFiDomains

elif [[ $MacModel = *"MacBook"* ]] && [[ "$currentService" = *"Wi-Fi"* ]]; then

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
