#!/bin/zsh

########################################################################
#             Create Required Directories for Waves Central            #
#################### Written by Phil Walker May 2021 ###################
########################################################################

# Requirements
# Outset (https://github.com/chilcote/outset)
# macOS 10.15+
# python 3.7+ (https://github.com/macadmins/python)

########################################################################
#                            Variables                                 #
########################################################################

# System level directories
systemDirs=( "/Applications/Waves" "/Applications/Waves/Data/Instrument\ Data/Waves\ Sample\ Libraries" \
"/Library/Application\ Support/Waves" "/Library/Application\ Support/Waves/Licenses" "/Users/Shared/Waves" \
"/Library/Application\ Support/Propellerhead\ Software/ReWire" "/Library/Application\ Support/Native\ Instruments/Service\ Center" )
# Plug-Ins directories array
pluginsDirs=( "/Library/Audio/Plug-Ins/WPAPI" "/Library/Audio/Plug-Ins/VST" "/Library/Audio/Plug-Ins/VST3" \
"/Library/Audio/Plug-Ins/Components" "/Library/Application\ Support/Avid/Audio/Plug-Ins" )

########################################################################
#                            Functions                                 #
########################################################################

function loggedInUserStatus ()
{
# Check if a user is logged in
loggedInUserCheck=$(stat -f %Su /dev/console)
if [[ "$loggedInUserCheck" == "" ]] || [[ "$loggedInUserCheck" == "root" ]]; then
	loggedInUser=""
	echo "No user is currently logged in"
else
	loggedInUser="$loggedInUserCheck"
    # Get the logged in users ID
    loggedInUserID=$(id -u "$loggedInUser")
    # Get the logged in users primary group
    loggedInUserGroup=$(id -gn "$loggedInUser")
    # User directories arrays
    userDirs1=( "/Users/${loggedInUser}/Library/Caches/Waves\ Audio" "/Users/${loggedInUser}/Library/Application\ Support/Waves\ Audio" \
    "/Users/${loggedInUser}/Library/Application\ Support/Waves\ Audio/Waves\ Central" \
    "/Users/${loggedInUser}/Library/Application\ Support/Waves\ Audio/Waves\ Central/Logs" )
    userDirs2=( "/Users/${loggedInUser}/Library/Application\ Support/Waves\ Central" "/Users/${loggedInUser}/Library/Preferences/Waves\ Preferences" )
fi
}

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

function createLibraryDirectories ()
{
echo "Creating all system level directories for Waves Central..."
# Create all additional system level directories if needed
for dir in ${(Q)${(z)systemDirs}}; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        chmod -R 777 "$dir"
        if [[ -d "$dir" ]]; then
            echo "${dir} directory created successfully"
        else
            echo "Failed to create ${dir} directory, Waves Central will prompt for admin on first launch"
        fi
    else
        echo "${dir} directory found, nothing to do"
fi
done
# Create the Waves plug-ins directories if needed
for dir in ${(Q)${(z)pluginsDirs}}; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        chmod -R 777 "$dir"
        if [[ -d "$dir" ]]; then
            echo "${dir} directory created successfully"
        else
            echo "Failed to create ${dir} directory, Waves Central will prompt for admin on first launch"
        fi
    else
        echo "${dir} directory found, nothing to do"
fi
done
}

function createUserDirectories ()
{
echo "Creating all user level directories for Waves Central..."
# Create all user level directories that require all user+groups to have RWX, if needed
for dir in ${(Q)${(z)userDirs1}}; do
    if [[ ! -d "$dir" ]]; then
        runAsUser mkdir -p "$dir"
        runAsUser chmod -R 777 "$dir"
        # Check permission changes
        checkPerms=$(stat -f "%OLp" "$dir")
        if [[ -d "$dir" ]] && [[ "$checkPerms" == "777" ]]; then
            echo "${dir} directory created successfully"
        else
            echo "Failed to create ${dir} directory, Waves Central will prompt for admin on first launch"
        fi
    else
        checkPerms=$(stat -f "%OLp" "$dir")
        if [[ "$checkPerms" == "777" ]]; then
            echo "${dir} directory found and permissions are correct, nothing to do"
        else
            echo "Correcting permissions for the ${dir} directory"
            chown -R "$loggedInUser":"$loggedInUserGroup" "$dir"
            chmod -R 777 "$dir"
            checkPerms=$(stat -f "%OLp" "$dir")
            if [[ "$checkPerms" == "777" ]]; then
                echo "Correct permissions now set for the ${dir} directory"
            else
                echo "Failed to correct permissions for the ${dir} directory"
                echo "Waves Central will prompt for admin on first launch"
            fi
        fi
    fi
done
# Create all standard user level directories, if needed
for dir in ${(Q)${(z)userDirs2}}; do
    if [[ ! -d "$dir" ]]; then
        runAsUser mkdir -p "$dir"
        # Check permission changes
        checkPerms=$(stat -f "%OLp" "$dir")
        if [[ -d "$dir" ]] && [[ "$checkPerms" == "755" ]]; then
            echo "${dir} directory created successfully"
        else
            echo "Failed to create ${dir} directory, Waves Central will prompt for admin on first launch"
        fi
    else
        checkPerms=$(stat -f "%OLp" "$dir")
        if [[ "$checkPerms" == "755" ]]; then
            echo "${dir} directory found and permissions are correct, nothing to do"
        else
            echo "Correcting permissions for the ${dir} directory"
            chown -R "$loggedInUser":"$loggedInUserGroup" "$dir"
            chmod -R 755 "$dir"
            checkPerms=$(stat -f "%OLp" "$dir")
            if [[ "$checkPerms" == "755" ]]; then
                echo "Correct permissions now set for the ${dir} directory"
            else
                echo "Failed to correct permissions for the ${dir} directory"
                echo "Waves Central will prompt for admin on first launch"
            fi
        fi
    fi
done
}

function createUserPrefs ()
{
echo "Creating user preferences"
read -r -d '' userPrefs <<"EOF"
{
  "UserSettings": {
    "eula": {
      "acceptedVersion": 1
    },
    "permissionFixer": {
      "lastRunVersion": 4
    }
  },
  "SessionData": "",
  "WindowSettings": {
    "width": 1200,
    "height": 790,
    "x": 315,
    "y": 74
  }
}
EOF
su -l "$loggedInUser" -c "/bin/cat > /Users/${loggedInUser}/Library/Preferences/Waves\ Preferences/Waves\ Central.json<<<'$userPrefs'"
if [[ -f "/Users/${loggedInUser}/Library/Preferences/Waves Preferences/Waves Central.json" ]]; then
    echo "User preferences created"
else
    echo "Failed to create user preferences"
    echo "Waves Central will prompt for admin on first launch"
fi
}

function setPermissions ()
{
# If a normal users is logged in then correct the perms for the Waves directories
echo "Checking all system level Waves Central directories permissions..."
for dir in ${(Q)${(z)systemDirs}}; do
    checkOwnership=$(stat -f %Su "$dir")
    checkGroup=$(stat -f %Sg "$dir")
    checkPerms=$(stat -f "%OLp" "$dir")
    if [[ "$dir" == "/Users/Shared/Waves" ]]; then
        if [[ "$checkPerms" == "777" ]]; then
            echo "Permissions correct for ${dir} directory, nothing to do"
        else
            echo "Correcting permissions for ${dir}"
            chmod -R 777 "$dir"
            checkPerms=$(stat -f "%OLp" "$dir")
            if [[ "$checkPerms" == "777" ]]; then
                echo "Permissions correct for ${dir}"
            else
                echo "Failed to correct permissions for ${dir}"
                echo "Waves Central will prompt for admin on first launch"
            fi
        fi
    else
        if [[ "$checkOwnership" == "$loggedInUser" ]] && [[ "$checkGroup" == "$loggedInUserGroup" ]] && [[ "$checkPerms" == "777" ]]; then
            echo "Permissions correct for ${dir} directory, nothing to do"
        else
            echo "Correcting permissions for the ${dir} directory"
            chown -R "$loggedInUser":"$loggedInUserGroup" "$dir"
            chmod -R 777 "$dir"
            # re-populate the variables
            checkOwnership=$(stat -f %Su "$dir")
            checkGroup=$(stat -f %Sg "$dir")
            checkPerms=$(stat -f "%OLp" "$dir")
            if [[ "$checkOwnership" == "$loggedInUser" ]] && [[ "$checkGroup" == "$loggedInUserGroup" ]] && [[ "$checkPerms" == "777" ]]; then
                echo "Permissions corrected for the ${dir} directory"
            else
                echo "Failed to correct permissions for the ${dir} directory"
                echo "Waves Central will prompt for admin on first launch"
            fi
        fi
    fi
done
# Check permissions for the plug-ins directories
for dir in ${(Q)${(z)pluginsDirs}}; do
    checkPerms=$(stat -f "%OLp" "$dir")
    if [[ "$checkPerms" == "777" ]]; then
        echo "Permissions correct for ${dir} directory, nothing to do"
    else
        echo "Correcting permissions for the ${dir} directory"
        chmod -R 777 "$dir"
        # re-populate the variables
        checkPerms=$(stat -f "%OLp" "$dir")
        if [[ "$checkPerms" == "777" ]]; then
            echo "Permissions corrected for the ${dir} directory"
        else
            echo "Failed to correct permissions for the ${dir} directory"
            echo "Waves Central will prompt for admin on first launch"
        fi
    fi
done
}

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
loggedInUserStatus
if [[ "$loggedInUser" == "" ]]; then
    echo "Directories will be created but correct permissions cannot be set"
    echo "Waves Central will prompt for admin on first launch to set correct permissions"
    createLibraryDirectories
else
    echo "${loggedInUser} is logged in"
    createLibraryDirectories
    createUserDirectories
    if [[ ! -f "/Users/${loggedInUser}/Library/Preferences/Waves Preferences/Waves Central.json" ]]; then
        createUserPrefs
    else
        echo "User preferences found, nothing to do"
    fi
    setPermissions
fi
echo "Script completed at: $(date +"%Y-%m-%d_%H-%M-%S")"
exit 0