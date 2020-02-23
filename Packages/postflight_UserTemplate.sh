#!/bin/bash

########################################################################
#         Copy user template data to all existing user profiles        #
#################### Written by Phil Walker Jan 2020 ###################
########################################################################

#Copy user template data to all existing user profiles
pathToScript=$0                                                 # path to this script - supplied by the installer
pathToPackage=$1                                                # path to the package containing this script - supplied by the installer
targetLocation=$2                                               # path to the target location - supplied by the installer
targetVolume=$3                                                 # path to the target volume - supplied by the installer
template_path="/System/Library/User Template/English.lproj"     # path to the user templates folder

#
# make some temp files to hold the user lists
#
tmp_users=$(mktemp "/tmp/users-unsort-XXXXX")
if [[ -z "$tmp_users" ]]; then
	echo "error: could not make tmp file"
	exit 1
fi


#
# Make a list of homes that are in /Users or /Volumes/Users
#
for the_folder in "$targetVolume/Users" "/Volumes/Users"; do
    if [[ -d "$the_folder" ]]; then
        ls -lTn "$the_folder" | awk -v vDIR="$the_folder" '/^d/{vUID = $3; vGID = $4; sub("^.*[0-9]+:[0-9]+.[0-9]+","");sub("^ +","");if($0 !~ "^[.]"){print vUID, vGID, vDIR "/" $0}}'
    fi
done | sed '/\/Shared/d' >> "$tmp_users"


#
# Walk the list of user details, get the users UID, GID and home folder path
#
cat "$tmp_users" | while read the_user; do
    user_uid=$(echo "$the_user" | awk '{print $1}')
    user_gid=$(echo "$the_user" | awk '{print $2}')
    user_home=$(echo "$the_user" | awk '{$1 = ""; $2 = ""; sub("^ +","");print}')

    #
    # Only process this user if we have a home folder path
    #
    if [[ -n "$user_home" ]]; then

        #
        # Get a list of files and folders loaded into user templates from this packages BOM and walk that list
        #
        lsbom -p Mf "$pathToPackage/Contents/Archive.bom" | awk -v tPath=".$template_path." '$0 ~ tPath {print}' | while read the_item; do

            #
            # check if the item is a directory or file entry, also get the items source path in user templates and target path in the users home folder
            #
            item_is_dir=$(echo "$the_item" | grep -ci "^d")
            source_item=$(echo "$the_item" | sed -E 's/^[^[:blank:]]+[[:blank:]]+[.]//')
            target_item=$(echo "$source_item" | awk -v tPath="$template_path" -v hPath="$user_home" '{sub(tPath,hPath);print}')

            #
            # Dont overwrite anything that already exists
            #
            if [[ ! -e "$target_item" ]]; then

                #
                # If the item is a directory then create it, if it is a file then copy it. Either way, set ownership to the target user
                #
                if [[ $item_is_dir -gt 0 ]]; then
                    mkdir -p "$target_item"
                else
                    ditto "$targetVolume/$source_item" "$target_item"
                fi
                chown $user_uid:$user_gid "$target_item"
            fi
        done
    fi
done

exit 0