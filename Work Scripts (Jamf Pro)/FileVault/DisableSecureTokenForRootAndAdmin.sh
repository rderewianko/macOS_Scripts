#!/bin/zsh

########################################################################
#    Set Disable Secure Token Attribute For Root and Admin Accounts    #
#################### Written by Phil Walker July 2021 ##################
########################################################################
# Edited to add root account

########################################################################
#                            Variables                                 #
########################################################################

# User list
userList=$(dscl . -list /Users | grep -v "^_\|daemon\|nobody\|cas\|cloud")

########################################################################
#                         Script starts here                           #
########################################################################

for user in ${(f)userList}; do
    # Check for local admin
    if [[ "$user" == "admin" || "$user" == "root" ]]; then
        echo "${user} account found"
        authAuthority=$(dscl . -read /Users/"$user" AuthenticationAuthority 2>/dev/null)
        if [[ "$authAuthority" =~ ";DisabledTags;SecureToken" ]]; then
            echo "Authentication Authority attribute already has Secure Token disabled, nothing to do"
        else
            # Disable Secure Token
            dscl . -append /Users/"$user" AuthenticationAuthority ";DisabledTags;SecureToken"
            # re-populate the variable
            authAuthority=$(dscl . -read /Users/"$user" AuthenticationAuthority 2>/dev/null)
            if [[ "$authAuthority" =~ ";DisabledTags;SecureToken" ]]; then
                echo "Secure Token disabled for ${user}"
            else
                echo "Failed to disable Secure Token for ${user}"
            fi
        fi
    else
        echo "Account attributes not changed for ${user}"
    fi
done
exit 0