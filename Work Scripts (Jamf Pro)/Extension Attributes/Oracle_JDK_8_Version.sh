#!/bin/bash

########################################################################
#                         Oracle JDK Version 8                         #
################## Written by Phil Walker June 2019 ####################
########################################################################

JDK_Check=$(ls /Library/Java/JavaVirtualMachines/ | grep "jdk1.8")

if [[ "$JDK_Check" == "" ]]; then
  echo "<result>Not Installed</result>"
else
  JDK=$(ls /Library/Java/JavaVirtualMachines/ | grep "jdk1.8" | sed -e 's/jdk//' -e 's/.jdk//')
  JDK_Version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion $JDK" /Library/Java/JavaVirtualMachines/$JDK_Check/Contents/Info.plist)
  echo "<result>$JDK_Version</result>"
fi
