#!/bin/bash

########################################################################
#            Set NoMADLogin-AD To Run DEPNotify Post Login             #
################### Written by Phil Walker Aug 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# NoMADLogin-AD bundle
noLoADBundle="/Library/Security/SecurityAgentPlugins/NoMADLoginAD.bundle"
# DEPNotify app
depNotify="/var/tmp/DEPNotify.app"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$noLoADBundle" ]]; then
    echo "NoMADLogin-AD found"
    if [[ -d "$depNotify" ]]; then
        echo "DEPNotify application found"
        echo "Setting NoMADLogin-AD to run DEPNotify post login..."
        /usr/local/bin/authchanger -reset -AD -postAuth "NoMADLoginAD:RunScript,privileged"
        /bin/sleep 2
        authCheck=$(usr/local/bin/authchanger -print | grep "NoMADLoginAD:RunScript,privileged" | xargs)
        if [[ "$authCheck" == "NoMADLoginAD:RunScript,privileged" ]]; then
            echo "NoMADLogin-AD set to run DEPNotify post login"
            /usr/bin/killall -HUP loginwindow
            exit 0
        else
            echo "Failed to set NoMADLogin-AD to run DEPNotify post login!"
            /usr/local/bin/authchanger -reset
            /usr/bin/killall -HUP loginwindow
            echo "Login window set back to default Apple login window to prevent logins"
            exit 1
        fi
    else
        echo "DEPNotify application not found!"
        /usr/local/bin/authchanger -reset
        /usr/bin/killall -HUP loginwindow
        echo "Login window set back to default Apple login window to prevent logins"
        exit 1
    fi
else
    echo "NoMADLogin-AD not found!"
    exit 1
fi