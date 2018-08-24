#!/bin/bash

#use applescript to open sys prefs to Users pane - 10.12 or higher has no assistive access due to SIP
echo
osascript <<EOD2
 tell application "System Preferences"
 activate
	try -- to use UI scripting
		set current pane to pane id "com.apple.preferences.users"
		activate
		delay 1
    end try
end tell
