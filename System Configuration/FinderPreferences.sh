#!/bin/sh

#######################################################
################# Set Finder Preferences ##############
############# Script created by Phil Walker ###########
#######################################################

# Set Finder Preferences

echo setting Finder preferences...

# Display Disks/Drives/Servers on Desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Show Status Bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Show Side Bar
defaults write com.apple.finder ShowSidebar -bool true
defaults write com.apple.finder ShowSideBar -bool true

# Restart Finder
killall Finder
exit 0
