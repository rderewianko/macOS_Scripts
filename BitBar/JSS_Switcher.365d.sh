#!/bin/bash
# <bitbar.title>JSS Switcher</bitbar.title>
# <bitbar.version>1.0</bitbar.version>
# <bitbar.author>Phil Walker</bitbar.author>
# <bitbar.author.github>pwalker1485</bitbar.author.github>
# <bitbar.desc>Displays JSS URL and allows user to switch between multiple servers</bitbar.desc>
# <bitbar.dependencies>Bash scripts stored locally to write value to plist</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/pwalker1485</bitbar.abouturl>

#Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)

#Get the current JSS url from the Jamf plist and add to a variable
jssURL=$(defaults read /Users/$LoggedInUser/Library/Preferences/com.jamfsoftware.jss.plist jss_url)
#Check which URL is configured and set the name that appears in the menu bar
if [[ $jssURL == "https://casper.bauerservices.co.uk:443/" ]] || [[ $jssURL == "https://casper.bauerservices.co.uk/" ]] || [[ $jssURL == "https://casper.bauerservices.co.uk" ]]; then
	echo "Prod JSS | color=blue"
fi
if [[ $jssURL == "https://caspertest.bauerservices.co.uk:443/" ]] || [[ $jssURL == "https://caspertest.bauerservices.co.uk/" ]] || [[ $jssURL == "https://caspertest.bauerservices.co.uk" ]] ; then
	echo "Test JSS | color=red"
fi

#Start the sub menu
echo "---"
echo "Production | bash="/Users/philwalker/Documents/PackagingStuff/jssswitcher/prodjss.sh" terminal=false refresh=true" color=blue
echo "Test | bash="/Users/philwalker/Documents/PackagingStuff/jssswitcher/testjss.sh" terminal=false refresh=true" color=red

exit 0
