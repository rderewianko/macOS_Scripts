#!/bin/bash

########################################################################
#         Install Bauer-UK and Bauermedia Certificates                 #
############## Written by Phil Walker March 2018 #######################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

CERT_PATH="/var/tmp/BauerCerts/"
SYSTEM_KEYCHAIN="/Library/Keychains/System.keychain"

########################################################################
#                            Functions                                 #
########################################################################

function bauerCerts() {

UK_CERT=$(security find-certificate -a ${SYSTEM_KEYCHAIN} | grep "bauer-uk-MSADSLONPKI02-CA" | awk -F '"' '/alis/{print $4}')
BM_CERT=$(security find-certificate -a ${SYSTEM_KEYCHAIN} | grep "bauermedia-MSADSPKIRO02-CA" | awk -F '"' '/alis/{print $4}')

}

function getCerts() {
#Download Bauer Certs
echo "Downloading Bauer Certificates..."
mkdir "/var/tmp/BauerCerts/"
curl -o /var/tmp/BauerCerts/bauer-uk-MSADSLONPKI02-CA.crt http://pki.bauermedia.com/CertEnroll/bauer-uk-MSADSLONPKI02-CA.crt 2>/dev/null &&
curl -o /var/tmp/BauerCerts/bauermedia-MSADSPKIRO02-CA.crt http://pki.bauermedia.com/CertEnroll/bauermedia-MSADSPKIRO02-CA.crt 2>/dev/null

}

function installBauerUKCerts() {
#Install Bauer-UK certificate
if [[ -e /var/tmp/BauerCerts/bauer-uk-MSADSLONPKI02-CA.crt ]]; then
	/usr/bin/security add-trusted-cert -r trustAsRoot -k ${SYSTEM_KEYCHAIN} -d ${CERT_PATH}/bauer-uk-MSADSLONPKI02-CA.crt
fi
bauerCerts
}

function installBauermediaCerts() {
#Install Bauermedia certificate
if [[ -e /var/tmp/BauerCerts/bauermedia-MSADSPKIRO02-CA.crt ]]; then
	/usr/bin/security add-trusted-cert -k ${SYSTEM_KEYCHAIN} -d ${CERT_PATH}/bauermedia-MSADSPKIRO02-CA.crt
fi
bauerCerts
}

function cleanUp() {
#Delete temporary directory
if [[ -d $CERT_PATH ]]; then
	rm -rf /var/tmp/BauerCerts
	echo "Clean up successful"
else
	echo "Nothing to clean up"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

#Check Status of Bauer Certs
bauerCerts

if [[ "$UK_CERT" == "bauer-uk-MSADSLONPKI02-CA" ]]; then
	echo "bauer-uk certificates already installed nothing to do"
else
	#Download certificates
	getCerts
	echo "Installing bauer-uk certificates..."
	installBauerUKCerts

	if [[ "$UK_CERT" == "bauer-uk-MSADSLONPKI02-CA" ]]; then
			echo "bauer-uk certificates installed successfully"
		else
			echo "bauer-uk certificates install failed"
	fi
fi


if [[ "$BM_CERT" == "bauermedia-MSADSPKIRO02-CA" ]]; then
	echo "bauermedia certificates already installed nothing to do"
else
	#Download certificates if required
	if [[ ! -d "/var/tmp/BauerCerts/" ]]; then
	getCerts
	echo "Installing bauermedia certificates..."
	installBauermediaCerts
else
	echo "Installing bauermedia certificates..."
	installBauermediaCerts

	if [[ "$BM_CERT" == "bauermedia-MSADSPKIRO02-CA" ]]; then
			echo "bauermedia certificates installed successfully"
		else
			echo "bauermedia certificates install failed"
		fi
	fi
fi

cleanUp

exit 0
