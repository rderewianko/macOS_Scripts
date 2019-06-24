#!/bin/bash

########################################################################
#             Current Version of Oracle JDK 8 Installed                #
################## Written by Phil Walker June 2019 ####################
########################################################################

jdk8_check=$(ls /Library/Java/JavaVirtualMachines/ | grep "1.8" 2>/dev/null | awk 'END { print NR }')

if [[ "$jdk8_check" -gt "0" ]]; then

  echo "<result>$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/jdk//' -e 's/.jdk//')</result>"

else

  echo "<result>Not Installed</result>"

fi

exit 0
