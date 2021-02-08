#!/bin/zsh

########################################################################
#                 Remove previous versions of JDK 8                    #
################## Written by Phil Walker June 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Find total number of JDK versions installed
jdk8Check=$(find /Library/Java/JavaVirtualMachines -iname "*jdk1.8*" -maxdepth 1 | awk 'END {print NR}')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$jdk8Check" -gt "0" ]]; then
    # Get the active JDK version
    activeJDK=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    echo "Active version of Java: ${activeJDK}"
    # Get the full paths for inactive JDK 8 versions installed
    jdk8PreviousPath=$(find /Library/Java/JavaVirtualMachines -iname "*jdk1.8*" -maxdepth 1 | grep "jdk1.8" | grep -v "$activeJDK")
    if [[ "$jdk8PreviousPath" != "" ]]; then
        for jdk8 in ${(f)jdk8PreviousPath}; do
            rm -rf "$jdk8"
            jdk8Removed=$(echo "$jdk8" | awk -F/ '{print $NF}' | sed -e 's/jdk//' -e 's/.jdk//')
            echo "Removed Java 8 Version: ${jdk8Removed}"
        done
    else
        echo "No previous versions of Java 8 found"
    fi
else
    echo "No previous versions of Java 8 found"
fi
exit 0