#!/bin/zsh

########################################################################
#         Move Bauer Asset Reports to EUCReports File Share           #
################## Written by Phil Walker Apr 2021 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# OneDrive target file
targetFile="/Users/${loggedInUser}/OneDrive - Bauer Media Group/Mac Infrastructure Data/Jigsaw Asset Reports/BAUERREPORT.CSV"
# EUCReports destination directory
destDir="/Volumes/EUCReports/jamfPro/PurchasingUpdate"
# Log directory
logDir="/Users/${loggedInUser}/Library/Logs/Bauer/AssetReport"
# Log file
logFile="${logDir}/MoveAssetReport.log"
# Date and time
datetime=$(date +%d-%m-%Y\ %T)

########################################################################
#                         Script starts here                           #
########################################################################

# Create the log directory, if required
if [[ ! -d "$logDir" ]]; then
    mkdir -p "$logDir"
fi
# Create the log file, if required
if [[ ! -e "$logFile" ]]; then
    touch "$logFile"
fi
# If an Asset Report is found, move it
if [[ -f "$targetFile" ]]; then
    # redirect both standard output and standard error to the log
    exec >> "$logFile" 2>&1
    mv "$targetFile" "$destDir" &>/dev/null
    if [[ -f "${destDir}/BAUERREPORT.CSV" ]]; then
        echo "${datetime}: Bauer Asset Report moved to the EUCReports file share"
    else
        echo "${datetime}: A Bauer Asset Report is available but failed to move"
        exit 1
    fi
fi
exit 0