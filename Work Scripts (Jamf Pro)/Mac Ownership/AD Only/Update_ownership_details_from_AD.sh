#!/bin/bash

#Get the logged in users username
LoggedInUser=$(stat -f %Su /dev/console)

#Get UniqueID
accountType=$(dscl . -read /Users/"$LoggedInUser" | grep UniqueID | /usr/bin/awk '{ print $2 }')

if [ -z "$LoggedInUser" ]; then
        echo "No one logged in, quit."
        exit 0
else
        echo "$LoggedInUser is logged in."
        #If UniqueID is over 1000 then account will be a network account
        if (( "$accountType" > 1000 )); then
          echo "AD account being used"
          #if [[ $LoggedInUser == *"admin"* ]]; then
          if [[ "$LoggedInUser" == "admin" ]]; then
            echo "Umm, looks to be an admin quitting..."
            exit 0
          else
            echo "Not an admin, carry on"
            #Get Real Name
            userRealName=$(dscl . -read /Users/$LoggedInUser | grep -A1 "RealName:" | sed -n 2p | awk '{print $2, $1}' | sed 's/,$//')
            #Get logged in users email address
            userEMail=$(dscl . -read /Users/$LoggedInUser | grep EMailAddress: | awk '{print $2}')
            #Get logged in users position
            userPosition=$(dscl . -read /Users/$LoggedInUser | awk '/^JobTitle:/,/^LastName:/' | sed -n 2p | cut -c 2-)
            #Get logged in users Phone Number
            userPhoneNumber=$(dscl . -read /Users/$LoggedInUser  | grep -A1 "PhoneNumber:" | sed -n 2p)
            #Get logged in users Department
            userDepartment=$(dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$LoggedInUser | grep -A1 "physicalDeliveryOfficeName" | sed -n 2p)

            #Check connection to the JSS before submitting ownership details
            jssConnection=$(jamf checkjssconnection | tail -1)

            #Check for values and if not populated populate with predefined data
            #If $userRealName is blank
            if [[ -z $userRealName ]]; then
              userRealName="No Name Found"
            fi
            #If $userEMail is blank
            if [[ -z $userEMail ]]; then
              userEMail="No email address found"
            fi
            #If $userPosition is blank
            if [[ -z $userPosition ]]; then
              userPosition="No Job Title found"
            fi
            #If $userPhoneNumber is blank
            if [[ -z $userPhoneNumber ]]; then
              userPhoneNumber="No Phone Number found"
            fi
            #If $userDepartment is blank
            if [[ -z $userDepartment ]]; then
              userDepartment="No Office Listed"
            fi

            ### DEBUG
            #echo "LoggedInUser:$LoggedInUser"
            #echo "accountType:$accountType"
            #echo "-------------"
            #echo "userRealName:$userRealName"
            #echo "userEMail:$userEMail"
            #echo "userPosition:$userPosition"
            #echo "userPhoneNumber:$userPhoneNumber"
            #echo "userDepartment:$userDepartment"
            #echo "jssConnection:$jssConnection"

            if [ "$jssConnection" == "The JSS is available." ]; then
                echo "$jssConnection"
                echo "Submitting ownership for network account $LoggedInUser..."
                jamf recon -endUsername "$LoggedInUser" -realname "$userRealName" -email "$userEMail" -position "$userPosition" -phone "$userPhoneNumber" -room "$userDepartment"
                exit 0
            else
                echo "Can't connect to the JSS"
                exit 0
            fi
          fi
        else
          #If UniqueID is less than 1000
          echo "Non Ad account, quit"
          exit 0
        fi
fi
