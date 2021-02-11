#!/bin/zsh

########################################################################
#                     Outset Content - preinstall                      #
################### written by Phil Walker Nov 2020 ####################
########################################################################

if [[ -e "/usr/local/outset/outset" ]]; then
    echo "Outset installed, continuing with install.."
else
    echo "Outset not installed, existing install!"
    exit 1
fi
exit 0