#!/bin/bash

########################################################################
#     Find all inactive versions of Oracle Java Development Kit 8      #
################## Written by Phil Walker June 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

jdk8_check=$(ls /Library/Java/JavaVirtualMachines/ | grep "1.8" 2>/dev/null | awk 'END { print NR }')

########################################################################
#                            Functions                                 #
########################################################################

function jdk8_Results()
{
# Read contents of file and delete after printing results

echo "<result>"
  while read -r line || [[ -n "$line" ]]; do
    echo "$line"
  done < /var/tmp/jdk8_previous_versions.txt
echo "</result>"

    sleep 2

    rm -f /var/tmp/jdk8_previous_versions.txt

}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$jdk8_check" -gt "0" ]]; then

  java_home=$(/usr/libexec/java_home | cut -d '/' -f5)

    if [[ "$java_home" =~ "1.8." ]] && [[ "$jdk8_check" -eq "1" ]]; then

      echo "<result>None</result>"

    elif [[ "$java_home" =~ "1.8." ]] && [[ "$jdk8_check" -gt "1" ]]; then

      jdk_current=$(/usr/libexec/java_home | cut -d '/' -f5 | sed -e 's/jdk//' -e 's/.jdk//')
      jdk8_previous=$(ls /Library/Java/JavaVirtualMachines/ | grep "jdk1.8" | sed -e 's/jdk//' -e 's/.jdk//' | grep -v "$jdk_current" > /var/tmp/jdk8_previous_versions.txt)

      jdk8_Results

    else

      jdk8_previous=$(ls /Library/Java/JavaVirtualMachines/ | grep "jdk1.8" | sed -e 's/jdk//' -e 's/.jdk//' > /var/tmp/jdk8_previous_versions.txt)

      jdk8_Results

  fi

else

  echo "<result>None</result>"

fi

exit 0
