#!/bin/bash

########################################################################
#                         Oracle JDK Version 8                         #
################## Written by Phil Walker June 2019 ####################
########################################################################

jdkCheck=$(ls /Library/Java/JavaVirtualMachines/ | grep "jdk1.8")

if [[ "$jdkCheck" == "" ]]; then

  echo "<result>Not Installed</result>"

else

  jdkCheck=$(ls /Library/Java/JavaVirtualMachines/ | grep "jdk1.8" > /tmp/JDK_Versions.txt)

  while read -r line || [[ -n "$line" ]]; do

    jdkShort=$(echo $line | sed -e 's/jdk//' -e 's/.jdk//')
    jdkVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion $jdkShort" /Library/Java/JavaVirtualMachines/$line/Contents/Info.plist)

		    echo "<result>$jdkVersion</result>"

	done < /tmp/JDK_Versions.txt

  sleep 2

      rm -f /tmp/JDK_Versions.txt

fi

exit 0
