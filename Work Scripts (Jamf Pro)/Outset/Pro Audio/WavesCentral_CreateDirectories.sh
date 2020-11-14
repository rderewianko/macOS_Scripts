#!/bin/zsh

########################################################################
#             Create Required Directories for Waves Central            #
#################### Written by Phil Walker Nov 2020 ###################
########################################################################

# Requirements
# Outset (https://github.com/chilcote/outset)
# macOS 10.15+
# python 3.7+ (https://github.com/macadmins/python)

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Waves audio cache directory
wavesAudioCache="/Users/$loggedInUser/Library/Caches/Waves Audio"
# Waves sample libraries directory
sampleLibraryDir="/Applications/Waves/Data/Instrument Data/Waves Sample Libraries"
# Waves licenses directory
wavesLicensesDir="/Library/Application Support/Waves/Licenses"
# Logfile
logFile="/Library/Logs/Bauer/Outset/WavesCentral_CreateDirectories_${loggedInUser}.log"

########################################################################
#                         Script starts here                           #
########################################################################

# Create the log directory if required
if [[ ! -d "/Library/Logs/Bauer/Outset" ]]; then
    mkdir -p "/Library/Logs/Bauer/Outset"
fi
# Create the log file if required
if [[ ! -e "$logFile" ]]; then
    touch "$logFile"
fi
# redirect both standard output and standard error to the log
exec >> "$logFile" 2>&1
echo "Script started at: $(date +"%Y-%m-%d_%H-%M-%S")"
# Create the Waves sample libraries directory if needed
if [[ ! -d "$sampleLibraryDir" ]]; then
    mkdir -p "$sampleLibraryDir"
    chmod -R 777 "/Applications/Waves/"
    if [[ -d "$sampleLibraryDir" ]]; then
        echo "Waves sample libraries directory created successfully"
    else
        echo "Failed to create Waves sample libraries directory, Waves Central will prompt for admin on first launch"
    fi
else
    echo "Waves sample libraries directory found, nothing to do"
fi
# Create the Waves licenses directory if needed
if [[ ! -d "$wavesLicensesDir" ]]; then
    mkdir -p "$wavesLicensesDir"
    chmod -R 777 "/Library/Application Support/Waves/"
    if [[ -d "$wavesLicensesDir" ]]; then
        echo "Waves licenses directory created successfully"
    else
        echo "Failed to create Waves licenses directory, Waves Central will prompt for admin on first launch"
    fi
else
    echo "Waves licenses directory found, nothing to do"
fi
# Create the Waves audio cache directory if needed
if [[ ! -d "$wavesAudioCache" ]]; then
    sudo -u "$loggedInUser" mkdir "$wavesAudioCache"
    if [[ -d "$wavesAudioCache" ]]; then
        echo "Waves audio cache directory created successfully for ${loggedInUser}"
    else
        echo "Failed to create Waves audio cache directory, Waves Central will prompt for admin on first launch"
    fi
else
    echo "Waves audio cache directory for ${loggedInUser} found, nothing to do"
fi
echo "Script completed at: $(date +"%Y-%m-%d_%H-%M-%S")"
exit 0
