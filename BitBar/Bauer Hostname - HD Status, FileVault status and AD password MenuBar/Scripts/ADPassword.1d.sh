#!/bin/bash
# <bitbar.title>Bauer hostname and HD Status</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Ben Carter March 2017</bitbar.author>
# <bitbar.author.github>retrac81</bitbar.author.github>
# <bitbar.desc>This script is designed to be used with bitbar application in the
# distro format. The script checks for a connection to the bauer
# network and if found will retrieve the amount of days left of the
# users password. A dropdown menu allows the user to read more info
# on MediaVine or change thier password - on click sys prefs is
# launched. </bitbar.desc>
# <bitbar.image>base64 encoded for Self Service graphic</bitbar.image>
# <bitbar.dependencies>JSS Binary</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/retrac81</bitbar.abouturl>

# # # # # # # # # # # # # # # # # # #
#Variables
# # # # # # # # # # # # # # # # # # #

#How many days left of password before warnings start
pwPolicyWarning=14

#Applescript to launch sys prefs to user pane from dropdown menubar
launchsyspref="/usr/local/launchSysPrefstoUserPane.sh"

#JamfHelper variables to be used later
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
title="Message from Bauer IT"
heading="Your Login Password Will Expire Soon"
heading1day="Your Login Password Will Expire Tomorrow!"
icon="/Applications/Utilities/Keychain Access.app/Contents/Resources/AppIcon.icns"
iconwarning="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"

#Get the ScreenSaver state - running or not
screenSaver=$(ps -ef | grep ScreenSaverEngine | awk {'print $7'} | head -1 | sed 's/^..//' | sed 's/.\{3\}$//')
zeroRun="00"

# # # # # # # # # # # # # # # # # # #
#Functions
# # # # # # # # # # # # # # # # # # #

function calcPassWD ()
{
pwPolicy=180
user=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
lastpwdMS=`dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$user | grep SMBPasswordLastSet | cut -d' ' -f 2`
expirepwdMS=`dscl /Active\ Directory/BAUER-UK/bauer-uk.bauermedia.group -read /Users/$user | grep userAccountControl | awk '{print $2}'`
todayUnix=`date "+%s"`
lastpwdUnix=`expr $lastpwdMS / 10000000 - 11644473600`
diffUnix=`expr $todayUnix - $lastpwdUnix`
diffdays=`expr $diffUnix / 86400`
daysremaining=`expr $pwPolicy - $diffdays`
#Check if the logged in user account has password never expired ticked. AD attribute userAccountControl value of 66048 defines a no expiry password
if [ "$expirepwdMS" == "66048" ] || [ "$user" == "root" ] || [ "$user" == "admin" ]; then
daysremaining="999"
fi
}

function appleScriptOpenSysPrefstoUsersPane ()
{
  #use applescript to open sys prefs and launch password reset box
echo
osascript <<EOD
 tell application "System Preferences"
	try -- to use UI scripting
		set current pane to pane id "com.apple.preferences.users"
		activate
		delay 1
    end try
end tell
EOD
}

function jamfHelperPasswordExpiry ()
{
  HELPER=`"$jamfHelper" -windowType utility -icon "$icon" -heading "$heading" -title "$title" -description "Your login password is due to expire in $daysremaining days. Please update your password." -button1 "Update Now" -button2 "Later" -defaultButton "1" `
}

function jamfHelperPasswordExpiry1DayLeft ()
{
  HELPER=`"$jamfHelper" -windowType utility -icon "$iconwarning" -heading "$heading1day" -title "$title" -description "Your login password is due to expire tomorrow. Please update your password immediately!" -button1 "Update Now" -defaultButton "1" `
}

function buildMenuBar ()
{
  #Start the menu bar
  if [[ $daysremaining -ge "$pwPolicyWarning" ]]; then
      echo ":key: $daysremaining days | color=green"
  else
      echo ":exclamation: Password expiring in $daysremaining days | color=red"
  fi
      echo "---"
      echo ":arrow_forward: More Information | href=https://bauermedia.interactgo.com/Interact/Pages/Content/Document.aspx?id=2064"
      echo ":key: Change Password | bash="$launchsyspref" terminal=false"
      #echo ":arrow_forward: Self Service | href=selfservice://localhost color=orange"
}

function buildMenuBarNoAD ()
{
  #Start the menu bar

      echo ":exclamation:"
      echo "---"
      echo "Mac is not bound to AD | href=selfservice://localhost color=red"
}

# # # # # # # # # # # # # # # # # # #
#Start the Script
# # # # # # # # # # # # # # # # # # #

#Check if we can get to AD - if we can then run the function to calculate how many days left of password.
ping -c1 bauer-uk.bauermedia.group &>/dev/null
#If no ping then set bitbar to display a key and a link to MV
if [ $? -ne 0 ]; then
        #No ping so don't build anything in the menubar.
        echo ""
else
    #Check that Mac is bound to AD
    check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`
    if [[ "${check4AD}" != "Active Directory" ]]; then
      #Call funtion to build the menu bar with a warning and message of not bound to AD
      buildMenuBarNoAD
      exit 0
    fi

    #Call function to calulate the users password, we have good ping to AD
    calcPassWD
    #Wait for 2 seconds for things to calm down
    sleep 2
    #Check how many days are remaining, if more than 14 then call function to build the menu bar
    if [[ $daysremaining -ge "$pwPolicyWarning" ]]; then
      #If password has more than policy threshold then don't render anything in the menu bar
      echo ""
      exit 0
      #buildMenuBar
    elif [ -z $daysremaining ]; then
      #Nothing found in daysremaining don't render the menubar.
      echo ""
      exit 0
    #Less then 14 days remain, start notifiying the user.
    else
      #Check to see if days left to show a different message or load the menu bar
      if [ $daysremaining == "1" ] && [ $zeroRun -eq 00 ]; then
        #Call function to show a message to the user that thier password needs changing now.
        jamfHelperPasswordExpiry1DayLeft
      elif [ $daysremaining -lt 7 ] && [ $zeroRun -eq 00 ]; then
        #Call function to show a message to the user that thier password needs changing.
        jamfHelperPasswordExpiry
      else
        #No need to prompt wil jamfHelper yet, just build the menu bar.
        buildMenuBar
        exit 0
      fi
      #Get the value of the jamfHelper, use can choose to change now or ignore
      if [ "$HELPER" -gt 0 ]; then
        #User chose to ignore so we will just build the menu bar
        buildMenuBar
        exit 0
      else
        #User clicked update password
        appleScriptOpenSysPrefstoUsersPane
        #Start the menu bar
        buildMenuBar
        exit 0
      fi
    fi
fi
