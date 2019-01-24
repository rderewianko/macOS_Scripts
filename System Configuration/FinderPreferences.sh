#!/bin/sh

#######################################################
#     Set Finder Preferences for the logged in user   #
#             Script created by Phil Walker           #
#######################################################

# Set Finder Preferences

# Get the logged in user
LoggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

echo setting Finder preferences...

# Display Disks/Drives/Servers on Desktop
su -l "$LoggedInUser" -c 'defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true'
su -l "$LoggedInUser" -c 'defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true'
su -l "$LoggedInUser" -c 'defaults write com.apple.finder ShowMountedServersOnDesktop -bool true'
su -l "$LoggedInUser" -c 'defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true'

# Show Status Bar
su -l "$LoggedInUser" -c 'defaults write com.apple.finder ShowStatusBar -bool true'

# Show Path Bar
su -l "$LoggedInUser" -c 'defaults write com.apple.finder ShowPathbar -bool true'

# Show Side Bar
su -l "$LoggedInUser" -c 'defaults write com.apple.finder ShowSidebar -bool true'
su -l "$LoggedInUser" -c 'defaults write com.apple.finder ShowSideBar -bool true'

# Restart Finder
killall Finder
exit 0
