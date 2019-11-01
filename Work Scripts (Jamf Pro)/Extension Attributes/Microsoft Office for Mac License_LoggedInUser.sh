#!/bin/bash

########################################################################
#        Office for Mac Licensing Status (Logged in user only)         #
################### written by Phil Walker Oct 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

#Get the current logged in user and store in variable
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
#Logged in users home directory
userHomeDirectory=$(/usr/bin/dscl . -read /Users/"$loggedInUser" NFSHomeDirectory | awk '{print $2}')
#Office volume license
volumeLicense="/Library/Preferences/com.microsoft.office.licensingV2.plist"
#Office 365 licensing files
o365Product="$userHomeDirectory/Library/Group Containers/UBF8T346G9.Office"
o365Submain="$o365Product/com.microsoft.Office365.plist"
o365Subbak1="$o365Product/com.microsoft.e0E2OUQxNUY1LTAxOUQtNDQwNS04QkJELTAxQTI5M0JBOTk4O.plist"
o365Subbak2="$o365Product/e0E2OUQxNUY1LTAxOUQtNDQwNS04QkJELTAxQTI5M0JBOTk4O" # hidden file
o365SubmainB="$o365Product/com.microsoft.Office365V2.plist"
o365Subbak1B="$o365Product/com.microsoft.O4kTOBJ0M5ITQxATLEJkQ40SNwQDNtQUOxATL1YUNxQUO2E0e.plist"
o365Subbak2B="$o365Product/O4kTOBJ0M5ITQxATLEJkQ40SNwQDNtQUOxATL1YUNxQUO2E0e"

########################################################################
#                            Functions                                 #
########################################################################

# Reports the type of perpetual license installed
function perpetualLicenseType
{
	if [ -f "$volumeLicense" ]; then
		/bin/cat "$volumeLicense" | grep -q "A7vRjN2l/dCJHZOm8LKan11/zCYPCRpyChB6lOrgfi"
		if [ "$?" == "0" ]; then
				echo "<result>Office 2019 Volume License</result>"
				return
		fi
		/bin/cat "$volumeLicense" | grep -q "Bozo+MzVxzFzbIo+hhzTl4JKv18WeUuUhLXtH0z36s"
		if [ "$?" == "0" ]; then
				echo "<result>Office 2019 Preview Volume License</result>"
				return
		fi
		/bin/cat "$volumeLicense" | grep -q "A7vRjN2l/dCJHZOm8LKan1Jax2s2f21lEF8Pe11Y+V"
		if [ "$?" == "0" ]; then
				echo "<result>Office 2016 Volume License</result>"
				return
		fi
		/bin/cat "$volumeLicense" | grep -q "DrL/l9tx4T9MsjKloHI5eX"
		if [ "$?" == "0" ]; then
				echo "<result>Office 2016 Home and Business License</result>"
				return
		fi
		/bin/cat "$volumeLicense" | grep -q "C8l2E2OeU13/p1FPI6EJAn"
		if [ "$?" == "0" ]; then
				echo "<result>Office 2016 Home and Student License</result>"
				return
		fi
		/bin/cat "$volumeLicense" | grep -q "Bozo+MzVxzFzbIo+hhzTl4m"
		if [ "$?" == "0" ]; then
				echo "<result>Office 2019 Home and Business License</result>"
				return
		fi
		/bin/cat "$volumeLicense" | grep -q "Bozo+MzVxzFzbIo+hhzTl4j"
		if [ "$?" == "0" ]; then
				echo "<result>Office 2019 Home and Student License</result>"
				return
		fi
	fi
}

# Checks to see if an O365 subscription license file is present
function detectO365License
{
	if [[ -f "$o365Submain" || -f "$o365Subbak1" || -f "$o365Subbak2" || -f "$o365SubmainB" || -f "$o365Subbak1B" || -f "$o365Subbak2B" ]]; then
		echo "<result>Office 365 Subscription</result>"
	else
		echo "<result>Office not activated</result>"
	fi
}

########################################################################
#                         Script starts here                           #
########################################################################

#Check to see if a volume license file is present
if [ -f "$volumeLicense" ]; then
	perpetualLicenseType
else
#If not check for an Office 365 subscription license file
	detectO365License
fi

exit 0
