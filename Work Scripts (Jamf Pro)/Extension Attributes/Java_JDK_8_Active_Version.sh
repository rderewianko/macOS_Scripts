#!/bin/bash

########################################################################
#           Active version of Oracle Java Development Kit 8            #
################## Written by Phil Walker June 2019 ####################
########################################################################

jdk_check=$(ls /Library/Java/JavaVirtualMachines/ 2>/dev/null | awk 'END { print NR }')

if [[ "$jdk_check" -gt "0" ]]; then

  java_home=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/jdk//' -e 's/.jdk//')
    if [[ "$java_home" =~ "1.8." ]]; then
      echo "<result>$java_home</result>"
    else
      echo "<result>Not Installed</result>"
    fi

else

  echo "<result>Not Installed</result>"

fi

exit 0
