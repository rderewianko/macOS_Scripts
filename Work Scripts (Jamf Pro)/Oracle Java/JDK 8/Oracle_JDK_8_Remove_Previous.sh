#!/bin/bash

########################################################################
#              Remove previous versions of Oracle JDK 8                #
################## Written by Phil Walker June 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

jdk8_check=$(ls /Library/Java/JavaVirtualMachines/ | grep "1.8" 2>/dev/null | awk 'END { print NR }')
#or
#jdk8_check=$(ls /Library/Java/JavaVirtualMachines/ | grep "1.8" 2>/dev/null | wc -l)

########################################################################
#                            Functions                                 #
########################################################################

function jdk_ActiveVersion()
{
# Print active version of JDK
java_home=$(/usr/libexec/java_home | cut -d '/' -f5)
if [[ "$java_home" =~ "1.6." ]]; then
  jdk_current=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/.jdk//')
    echo "Active Oracle JDK version: $jdk_current"
elif [[ "$java_home" =~ "1.8." ]]; then
  jdk_current=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/jdk//' -e 's/.jdk//')
    echo "Active Oracle JDK version: $jdk_current"
else
  jdk_current=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/jdk-//' -e 's/.jdk//')
    echo "Active Oracle JDK version: $jdk_current"
fi

}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$jdk8_check" -gt "0" ]]; then

jdk_ActiveVersion

  jdk_active=$(/usr/libexec/java_home | cut -d '/' -f5)
  jdk8_previous=$(ls /Library/Java/JavaVirtualMachines/ | grep "jdk1.8" | grep -v "$jdk_active")

  for jdk8 in $jdk8_previous
      do
        rm -rf "/Library/Java/JavaVirtualMachines/${jdk8}"
        jdk8_short=$(/bin/echo $jdk8 | sed -e 's/jdk//' -e 's/.jdk//')
        echo "Removed Oracle JDK 8 Version: $jdk8_short"
      done

else

  echo "No previous versions of Oracle JDK 8 found"

fi

exit 0
