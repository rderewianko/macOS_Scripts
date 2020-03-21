#!/bin/sh

#postinstall

mgmtAccountFV=$(fdesetup list | grep "casadmin" | sed 's/.*,//g')

if [[ "$mgmtAccountFV" != "" ]]; then
    echo "Management account has a SecureToken"
    echo "This Pro Tools MacBook can now be configured by IT Support"
    echo "FileVault must be enabled for the end user when the MacBook"
else
    echo "Management account does not have a SecureToken"
    echo "FileVault will be enabled automatically for the first user to logon"
    exit 1
fi

exit 0
