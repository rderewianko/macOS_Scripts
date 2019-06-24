#!/bin/bash

########################################################################
#       Find all inactive versions of Java Development Kit 8           #
################## Written by Phil Walker June 2019 ####################
########################################################################

jdk8_check=$(ls /Library/Java/JavaVirtualMachines/ | grep "1.8" 2>/dev/null | awk 'END { print NR }')

if [[ "$jdk8_check" -gt "0" ]]; then

  java_home=$(/usr/libexec/java_home | cut -d '/' -f5)
    if [[ "$java_home" =~ "1.8." ]]; then
      jdk_current=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/jdk//' -e 's/.jdk//')
    else
      jdk_current=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/jdk-//' -e 's/.jdk//')
    fi

  jdk8_previous=$(ls /Library/Java/JavaVirtualMachines/ | grep "jdk1.8" | sed -e 's/jdk//' -e 's/.jdk//' | grep -v "$jdk_current" > /var/tmp/jdk8_previous_versions.txt)

  echo "<result>"
    while read -r line || [[ -n "$line" ]]; do
      echo "$line"
    done < /var/tmp/jdk8_previous_versions.txt
  echo "</result>"

      sleep 2

      rm -f /var/tmp/jdk8_previous_versions.txt

else

  echo "<result>None</result>"

fi

exit 0
