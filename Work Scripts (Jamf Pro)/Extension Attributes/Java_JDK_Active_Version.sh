#!/bin/bash

########################################################################
#       Current active version of Oracle Java Development Kit          #
################## Written by Phil Walker June 2019 ####################
########################################################################

jdk_check=$(ls /Library/Java/JavaVirtualMachines/ 2>/dev/null | awk 'END { print NR }')

if [[ "$jdk_check" -gt "0" ]]; then
  java_home=$(/usr/libexec/java_home | cut -d '/' -f5)
    if [[ "$java_home" =~ "1.6." ]]; then
      jdk_current=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/.jdk//')
    elif [[ "$java_home" =~ "1.8." ]]; then
      jdk_current=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/jdk//' -e 's/.jdk//')
    else
      jdk_current=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/jdk-//' -e 's/.jdk//')
    fi

    echo "<result>$jdk_current</result>"

else

  echo "<result>Not Installed</result>"

fi

exit 0
