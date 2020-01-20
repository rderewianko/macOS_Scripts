#!/bin/bash
#Get OS version
os_ver=$(/usr/bin/sw_vers -productVersion | awk -F. {'print $2'})
#Get a list of users
users=$(dscl /Local/Default -list /Users uid | awk '$2 >= 400 && $0 !~ /^_/ { print $1 }')
echo "<result>"
#Check the OS version first as SecureToken only exists in 10.13 and above
if [[ "$os_ver" -eq "13" ]] || [[ "$os_ver" -eq "14" ]]; then
for i in $users; do
  # Get SecureTokenStaus
  secureTokenStatus=$(dscl . -read /Users/$i AuthenticationAuthority | grep -o SecureToken)
  if [ -z "$secureTokenStatus" ]; then
    echo "$i : SecureToken Missing"
  else
    echo "$i : SecureToken Found"
  fi
done
elif [[ "$os_ver" -eq "15" ]]; then
#Get a list of users and include the management account
userList=$(dscl . -list /Users | grep -v "^_\|daemon\|nobody\|root")
  for i in $userList; do
    # Get SecureTokenStaus
    secureTokenStatus=$(dscl . -read /Users/$i AuthenticationAuthority | grep -o SecureToken)
    if [ -z "$secureTokenStatus" ]; then
      echo "$i : SecureToken Missing"
    else
      echo "$i : SecureToken Found"
    fi
  done
else
  echo "$os_ver does not use SecureToken"
fi
echo "</result>"
