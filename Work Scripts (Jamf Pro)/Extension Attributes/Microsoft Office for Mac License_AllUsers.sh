#!/bin/bash

########################################################################
#            Office for Mac Licensing Status (All Users)               #
################### written by Phil Walker Oct 2019 ####################
########################################################################

########################################################################
#                            Functions                                 #
########################################################################

function detectPerpetualLicense
{
perpetualLicense="/Library/Preferences/com.microsoft.office.licensingV2.plist"

#Check if a perpetual license file is present and what kind
	if [[ $( /bin/cat "$perpetualLicense" 2>/dev/null | grep "A7vRjN2l/dCJHZOm8LKan11/zCYPCRpyChB6lOrgfi" ) ]]; then
		echo "Office 2019 Volume"
	elif [[ $( /bin/cat "$perpetualLicense" 2>/dev/null | grep "Bozo+MzVxzFzbIo+hhzTl4JKv18WeUuUhLXtH0z36s" ) ]]; then
		echo "Office 2019 Preview Volume"
	elif [[ $( /bin/cat "$perpetualLicense" 2>/dev/null | grep "A7vRjN2l/dCJHZOm8LKan1Jax2s2f21lEF8Pe11Y+V" ) ]]; then
		echo "Office 2016 Volume"
	elif [[ $( /bin/cat "$perpetualLicense" 2>/dev/null | grep "DrL/l9tx4T9MsjKloHI5eX" ) ]]; then
		echo "Office 2016 Home and Business"
	elif [[ $( /bin/cat "$perpetualLicense" 2>/dev/null | grep "C8l2E2OeU13/p1FPI6EJAn" ) ]]; then
		echo "Office 2016 Home and Student"
	elif [[ $( /bin/cat "$perpetualLicense" 2>/dev/null | grep "Bozo+MzVxzFzbIo+hhzTl4m" ) ]]; then
		echo "Office 2019 Home and Business"
	elif [[ $( /bin/cat "$perpetualLicense" 2>/dev/null | grep "Bozo+MzVxzFzbIo+hhzTl4j" ) ]]; then
		echo "Office 2019 Home and Student"
	else
		echo "No"
	fi
}

function detectO365License
{
#List all user accounts
allUsers=$(dscl . -list /Users | grep -v "^_\|casadmin\|daemon\|nobody\|root\|admin")

	while IFS= read aUser
	do
		# get the user's home folder path
		homePath=$( eval echo ~$aUser )

		# list of potential Office 365 activation files
		o365Submain="$homePath/Library/Group Containers/UBF8T346G9.Office/com.microsoft.Office365.plist"
		o365Subbak1="$homePath/Library/Group Containers/UBF8T346G9.Office/com.microsoft.e0E2OUQxNUY1LTAxOUQtNDQwNS04QkJELTAxQTI5M0JBOTk4O.plist"
		o365Subbak2="$homePath/Library/Group Containers/UBF8T346G9.Office/e0E2OUQxNUY1LTAxOUQtNDQwNS04QkJELTAxQTI5M0JBOTk4O" # hidden file
		o365SubmainB="$homePath/Library/Group Containers/UBF8T346G9.Office/com.microsoft.Office365V2.plist"
		o365Subbak1B="$homePath/Library/Group Containers/UBF8T346G9.Office/com.microsoft.O4kTOBJ0M5ITQxATLEJkQ40SNwQDNtQUOxATL1YUNxQUO2E0e.plist"
		o365Subbak2B="$homePath/Library/Group Containers/UBF8T346G9.Office/O4kTOBJ0M5ITQxATLEJkQ40SNwQDNtQUOxATL1YUNxQUO2E0e"

		# checks to see if an O365 subscription license file is present for each user
		if [[ -f "$o365Submain" || -f "$o365Subbak1" || -f "$o365Subbak2" || -f "$o365SubmainB" || -f "$o365Subbak1B" || -f "$o365Subbak2B" ]]; then
			activations=$((activations+1))
		fi
	done <<< "$allUsers"

	# returns the number of activations to O365Activations
	echo $activations
}

########################################################################
#                         Script starts here                           #
########################################################################


plPresent=$(detectPerpetualLicense)
o365Activations=$(detectO365License)

if [ "$plPresent" != "No" ] && [ "$o365Activations" ]; then
	echo "<result>$plPresent and Office 365 licenses detected. Only the $plPresent license will be used.</result>"

elif [ "$plPresent" != "No" ]; then
	echo "<result>$plPresent License</result>"

elif [ "$o365Activations" ]; then
	echo "<result>Office 365 Activations: $o365Activations</result>"

elif [ "$plPresent" == "No" ] && [ ! "$o365Activations" ]; then
	echo "<result>No Licenses</result>"
fi

exit 0
