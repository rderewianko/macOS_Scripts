#!/bin/bash

########################################################################
#       Find all previous versions of Oracle JDK 8 installed           #
################## Written by Phil Walker June 2019 ####################
########################################################################

jdk8Check=$(ls /Library/Java/JavaVirtualMachines/ | grep "1.8" 2>/dev/null | awk 'END { print NR }')

if [[ "$jdk8Check" -gt "1" ]]; then

  jdk8_current=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/jdk//' -e 's/.jdk//')
  jdk8_previous=$(ls /Library/Java/JavaVirtualMachines/ | grep "jdk1.8" | sed -e 's/jdk//' -e 's/.jdk//' | grep -v "$jdk8_current" > /var/tmp/jdk8_previous_versions.txt)

  echo "<result>"

    while read -r line || [[ -n "$line" ]]; do

      echo "$line"

    done < /var/tmp/jdk8_previous_versions.txt

  echo "</result>"

      sleep 2

      rm -f /var/tmp/jdk8_previous_versions.txt

else

  echo "<result>Not Installed</result>"

fi

exit 0
