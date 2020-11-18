#!/bin/zsh

########################################################################
#      Kill NoMAD post successful password change to force alert       #
############### Written by Phil Walker Jan 2019 ########################
########################################################################

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$(pgrep NoMAD)" == "" ]]; then
    echo "NoMAD process not running, nothing to kill"
else
    pkill -9 "NoMAD"
    echo "NoMAD process killed!"
fi
exit 0