#!/bin/zsh

cat << EOF > /Library/LaunchDaemons/com.bauer.launch.depnotify.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GroupName</key>
	<string>wheel</string>
	<key>InitGroups</key>
	<false/>
	<key>Label</key>
	<string>com.bauer.launch.depnotify</string>
	<key>Program</key>
	<string>/Library/Application Support/JAMF/DEPNotify/launchDEPNotify.sh</string>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>10</integer>
	<key>UserName</key>
	<string>root</string>
	<key>StandardErrorPath</key>
	<string>/private/var/tmp/launch.depnotify.error.log</string>
	<key>StandardOutPath</key>
	<string>/private/var/tmp/launch.depnotify.log</string>
</dict>
</plist>
EOF

chmod 644 /Library/LaunchDaemons/com.bauer.launch.depnotify.plist
chown root:wheel /Library/LaunchDaemons/com.bauer.launch.depnotify.plist

/bin/launchctl bootstrap system /Library/LaunchDaemons/com.bauer.launch.depnotify.plist