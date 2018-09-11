#!/bin/bash
# <bitbar.title>Mac Details</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Phil Walker</bitbar.author>
# <bitbar.author.github>pwalker1485</bitbar.author.github>
# <bitbar.desc>Displays Mac model icon/OS version/HostName/LastBoot/adminRightsCheck</bitbar.desc>
# <bitbar.image></bitbar.image>

#MacModel=$(system_profiler SPHardwareDataType | grep "Model Identifier" | awk '{print $3}')
#or
MODEL=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'["|"]' '/model/{print $4}')
OS=$(sw_vers -productVersion)
BUILD=$(sw_vers -buildVersion)
HOST=$(scutil --get ComputerName)
IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
SYSPROF=$(system_profiler SPSoftwareDataType | grep "Time")
LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
#RealName=$(dscl . read /Users/$LoggedInUser | grep RealName | awk '{ print $2 }') #Local Users
RealName=$(dscl . -read /Users/$LoggedInUser | grep -A1 "RealName:" | sed -n '2p' | awk '{print $2, $1}' | sed s/,//) #Mobile Users

MacPro='iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAKT2lDQ1BQaG90b3Nob3AgSUNDIHByb2ZpbGUAAHjanVNnVFPpFj333vRCS4iAlEtvUhUIIFJCi4AUkSYqIQkQSoghodkVUcERRUUEG8igiAOOjoCMFVEsDIoK2AfkIaKOg6OIisr74Xuja9a89+bN/rXXPues852zzwfACAyWSDNRNYAMqUIeEeCDx8TG4eQuQIEKJHAAEAizZCFz/SMBAPh+PDwrIsAHvgABeNMLCADATZvAMByH/w/qQplcAYCEAcB0kThLCIAUAEB6jkKmAEBGAYCdmCZTAKAEAGDLY2LjAFAtAGAnf+bTAICd+Jl7AQBblCEVAaCRACATZYhEAGg7AKzPVopFAFgwABRmS8Q5ANgtADBJV2ZIALC3AMDOEAuyAAgMADBRiIUpAAR7AGDIIyN4AISZABRG8lc88SuuEOcqAAB4mbI8uSQ5RYFbCC1xB1dXLh4ozkkXKxQ2YQJhmkAuwnmZGTKBNA/g88wAAKCRFRHgg/P9eM4Ors7ONo62Dl8t6r8G/yJiYuP+5c+rcEAAAOF0ftH+LC+zGoA7BoBt/qIl7gRoXgugdfeLZrIPQLUAoOnaV/Nw+H48PEWhkLnZ2eXk5NhKxEJbYcpXff5nwl/AV/1s+X48/Pf14L7iJIEyXYFHBPjgwsz0TKUcz5IJhGLc5o9H/LcL//wd0yLESWK5WCoU41EScY5EmozzMqUiiUKSKcUl0v9k4t8s+wM+3zUAsGo+AXuRLahdYwP2SycQWHTA4vcAAPK7b8HUKAgDgGiD4c93/+8//UegJQCAZkmScQAAXkQkLlTKsz/HCAAARKCBKrBBG/TBGCzABhzBBdzBC/xgNoRCJMTCQhBCCmSAHHJgKayCQiiGzbAdKmAv1EAdNMBRaIaTcA4uwlW4Dj1wD/phCJ7BKLyBCQRByAgTYSHaiAFiilgjjggXmYX4IcFIBBKLJCDJiBRRIkuRNUgxUopUIFVIHfI9cgI5h1xGupE7yAAygvyGvEcxlIGyUT3UDLVDuag3GoRGogvQZHQxmo8WoJvQcrQaPYw2oefQq2gP2o8+Q8cwwOgYBzPEbDAuxsNCsTgsCZNjy7EirAyrxhqwVqwDu4n1Y8+xdwQSgUXACTYEd0IgYR5BSFhMWE7YSKggHCQ0EdoJNwkDhFHCJyKTqEu0JroR+cQYYjIxh1hILCPWEo8TLxB7iEPENyQSiUMyJ7mQAkmxpFTSEtJG0m5SI+ksqZs0SBojk8naZGuyBzmULCAryIXkneTD5DPkG+Qh8lsKnWJAcaT4U+IoUspqShnlEOU05QZlmDJBVaOaUt2ooVQRNY9aQq2htlKvUYeoEzR1mjnNgxZJS6WtopXTGmgXaPdpr+h0uhHdlR5Ol9BX0svpR+iX6AP0dwwNhhWDx4hnKBmbGAcYZxl3GK+YTKYZ04sZx1QwNzHrmOeZD5lvVVgqtip8FZHKCpVKlSaVGyovVKmqpqreqgtV81XLVI+pXlN9rkZVM1PjqQnUlqtVqp1Q61MbU2epO6iHqmeob1Q/pH5Z/YkGWcNMw09DpFGgsV/jvMYgC2MZs3gsIWsNq4Z1gTXEJrHN2Xx2KruY/R27iz2qqaE5QzNKM1ezUvOUZj8H45hx+Jx0TgnnKKeX836K3hTvKeIpG6Y0TLkxZVxrqpaXllirSKtRq0frvTau7aedpr1Fu1n7gQ5Bx0onXCdHZ4/OBZ3nU9lT3acKpxZNPTr1ri6qa6UbobtEd79up+6Ynr5egJ5Mb6feeb3n+hx9L/1U/W36p/VHDFgGswwkBtsMzhg8xTVxbzwdL8fb8VFDXcNAQ6VhlWGX4YSRudE8o9VGjUYPjGnGXOMk423GbcajJgYmISZLTepN7ppSTbmmKaY7TDtMx83MzaLN1pk1mz0x1zLnm+eb15vft2BaeFostqi2uGVJsuRaplnutrxuhVo5WaVYVVpds0atna0l1rutu6cRp7lOk06rntZnw7Dxtsm2qbcZsOXYBtuutm22fWFnYhdnt8Wuw+6TvZN9un2N/T0HDYfZDqsdWh1+c7RyFDpWOt6azpzuP33F9JbpL2dYzxDP2DPjthPLKcRpnVOb00dnF2e5c4PziIuJS4LLLpc+Lpsbxt3IveRKdPVxXeF60vWdm7Obwu2o26/uNu5p7ofcn8w0nymeWTNz0MPIQ+BR5dE/C5+VMGvfrH5PQ0+BZ7XnIy9jL5FXrdewt6V3qvdh7xc+9j5yn+M+4zw33jLeWV/MN8C3yLfLT8Nvnl+F30N/I/9k/3r/0QCngCUBZwOJgUGBWwL7+Hp8Ib+OPzrbZfay2e1BjKC5QRVBj4KtguXBrSFoyOyQrSH355jOkc5pDoVQfujW0Adh5mGLw34MJ4WHhVeGP45wiFga0TGXNXfR3ENz30T6RJZE3ptnMU85ry1KNSo+qi5qPNo3ujS6P8YuZlnM1VidWElsSxw5LiquNm5svt/87fOH4p3iC+N7F5gvyF1weaHOwvSFpxapLhIsOpZATIhOOJTwQRAqqBaMJfITdyWOCnnCHcJnIi/RNtGI2ENcKh5O8kgqTXqS7JG8NXkkxTOlLOW5hCepkLxMDUzdmzqeFpp2IG0yPTq9MYOSkZBxQqohTZO2Z+pn5mZ2y6xlhbL+xW6Lty8elQfJa7OQrAVZLQq2QqboVFoo1yoHsmdlV2a/zYnKOZarnivN7cyzytuQN5zvn//tEsIS4ZK2pYZLVy0dWOa9rGo5sjxxedsK4xUFK4ZWBqw8uIq2Km3VT6vtV5eufr0mek1rgV7ByoLBtQFr6wtVCuWFfevc1+1dT1gvWd+1YfqGnRs+FYmKrhTbF5cVf9go3HjlG4dvyr+Z3JS0qavEuWTPZtJm6ebeLZ5bDpaql+aXDm4N2dq0Dd9WtO319kXbL5fNKNu7g7ZDuaO/PLi8ZafJzs07P1SkVPRU+lQ27tLdtWHX+G7R7ht7vPY07NXbW7z3/T7JvttVAVVN1WbVZftJ+7P3P66Jqun4lvttXa1ObXHtxwPSA/0HIw6217nU1R3SPVRSj9Yr60cOxx++/p3vdy0NNg1VjZzG4iNwRHnk6fcJ3/ceDTradox7rOEH0x92HWcdL2pCmvKaRptTmvtbYlu6T8w+0dbq3nr8R9sfD5w0PFl5SvNUyWna6YLTk2fyz4ydlZ19fi753GDborZ752PO32oPb++6EHTh0kX/i+c7vDvOXPK4dPKy2+UTV7hXmq86X23qdOo8/pPTT8e7nLuarrlca7nuer21e2b36RueN87d9L158Rb/1tWeOT3dvfN6b/fF9/XfFt1+cif9zsu72Xcn7q28T7xf9EDtQdlD3YfVP1v+3Njv3H9qwHeg89HcR/cGhYPP/pH1jw9DBY+Zj8uGDYbrnjg+OTniP3L96fynQ89kzyaeF/6i/suuFxYvfvjV69fO0ZjRoZfyl5O/bXyl/erA6xmv28bCxh6+yXgzMV70VvvtwXfcdx3vo98PT+R8IH8o/2j5sfVT0Kf7kxmTk/8EA5jz/GMzLdsAAAAgY0hSTQAAeiUAAICDAAD5/wAAgOkAAHUwAADqYAAAOpgAABdvkl/FRgAAA89JREFUeNp8lM1vVFUYxn/nzL0tM+0I/WIcCVOgxi74iMYOWOKqpIIGDS4lrIwr49INCzfu+Qs0rliQSOLCpLIwiGEn1YWQVIPaoR067WAGynSmc8/X6+LOTDqa+CYn9yQn+b3veZ7nXCUiXL16FQDnHMVikUKh8PHa2toH2Ww2lMunf3z48OG1O3d+2K7X60xNTTE7O8v8/Dz1ep3V1QrLy8vcvPk1ABrg0KFDlEolisXiO7udjiwtLX14/fr1bx89WlsfHR39bHJy8sbIyAjWGra3t+l0Oiil0FojIoQQ6FUEcPToUTKZDNba96rVKi8Wiysfzc0tnDhx8rxSmunp6QuXL18xlcrq3Vpt404mE90KIdxrNpvx8+fb+0XC3wNAay0iQqPR8LlcjrcWF6+0Wy2cdzR3mpjEkM3ui0+dOrVw/PiJhWfPnn7unFuL4yF7+HBpZnx8/BrwaR8oIjjnGB7eRz6fR0RIjCEeGkKCICK02m12dnbwIYCAc7Z0sFBgZmaGarV6cmBCpRRaKZQCaw1RnEVrjXMe5zzee1AQfCAEj/cB7z1JYjCJoZN0MgNA7z2iNVpr1tfXSZKE3d1dpo8cYXxiEt/xAIQQCCGFOecIwaO1xiRGBoA9l7z3KoRAHMc455AgWGPTvUjfUWMMQQLBB5TSWGsHXY6iiCiK8N6r3qG1FutSmO0CFdBsNmnvthnJjRAkoFSa3wHgnu7KGINSKgWaFNpLgQJarRbt3TZRFAGkt7D/AnrvuyY4kiTpZRJjDdakK3SBPYhJ0sbEYEzCfzS01pLNZjlw4AC1Wg3f1coYizEWkdQQrTXZXK5vjlIK55waAG5ubqK1ZmxsDBFJRe82McZgrEkl8Z4ggoSA877/9UEGJ5ybm+PJkzqPH2/QaDTwIeBsql1vSRcUuk5LCAiCd44o049h+nMol8tcuvQ+udyI2trawnuPdQ5nHa7rtHcO730/iyKgUGRzuTT4e4GlUonbt2+z09oREWEojoF0Et/VyndBWmny+TzFYpGDhQITE5M0Go3BYG9tbalz585JuXw6Ozv7Ckpr4igmk8ngfSCKIsbHxhneN0yr1aK2scG9ez81K5VKO45j2Xhc/X4ACLwAFPKj+WPPmy2Wvlu6q1CtixffnX/1tdf3P200+PmXZbuysvLbX3/+cb9SqfzunHsAbAI1YLV/ZxEBGAJGp6YOXl5cPL929uybjYmJyZULF97e/OLLr+TMmTduAWXgpT1DDFTvcSgRSQO6p4rF4sKxYy9/4pxV9x/8+k271b4BGP6nuoPxzwDs45iERlzziwAAAABJRU5ErkJggg=='
MacPro2013='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'

function osVersion() {
#find OS and build version
if [[ $OS = *"10.11"* ]]; then
	echo "Mac OS X: $OS ($BUILD)"
else
	echo "macOS: $OS ($BUILD)"
fi
}

function macModel() {
if [[ $MODEL = *"MacBook"* ]]; then
	echo "💻 $(osVersion)"
elif [[ $MODEL = *"iMac"* ]]; then
	echo "🖥 $(osVersion)"
elif [[ $MODEL = "MacPro3,1" ]] || [[ $MODEL = "MacPro4,1" ]] || [[ $MODEL = "MacPro5,1" ]]; then
	echo "$(osVersion)|image=$MacPro"
elif [[ $MODEL = "MacPro6,1" ]]; then
	echo "$(osVersion)|image=$MacPro2013"
else
	echo "$(osVersion)"
fi
}

function adminRightsCheck() {
#Check for admin rights
if [[ $(dsmemberutil checkmembership -U "$LoggedInUser" -G admin) != *not* ]]; then
  echo "🔓 $RealName is an admin user | color=red alternate=true"
else
  echo "🔒 $RealName is a standard user | alternate=true"
fi
}

function uptimeCheck() {
#Check Machine Uptime - Method 1

timecheck=$(uptime | awk {'print $4'})

if [ $timecheck = "secs," ]; then
  result=$(uptime | awk '{print $3 "s"}' | sed 's/,//g')
  echo "$result"

elif [ $timecheck = "min," ] || [ $timecheck = "mins," ]; then
  result=$(uptime | awk '{print $3 "m"}' | sed 's/,//g')
  echo "$result"

elif [ $timecheck = "hour," ]; then
  result=$(uptime | awk '{print $3 "h"}' | sed 's/,//g')
  ehco "$result"

elif [ $timecheck = "hrs," ]; then
	result=$(uptime | awk '{print $3 $4 "m"}' | sed 's/:/h /g' | sed 's/,//g')
	echo "$result"

elif [ $timecheck = "day," ]; then
  result=$(uptime | awk '{print $3 $4 "\ " $5 "m"}' | sed 's/day,/d/g' | sed 's/:/h /g' | sed 's/,//g')
  echo "$result"

elif [ $timecheck = "days," ]; then
  result=$(uptime | awk '{print $3 $4 "\ " $5 "m"}' | sed 's/days,/d/g' | sed 's/:/h /g' | sed 's/,//g')
  echo "$result"
fi
}

function uptimeCheck2() {
#Check Machine Uptime - Method 2
timeNow=$(date +"%s")
upTimeSecs=$(sysctl kern.boottime | awk -F'[= |,]' '{print $6}')
upTimeHours=$(($((timeNow-upTimeSecs))/60/60))
  echo "Uptime: $upTimeHours Hours"

}

function uptimeCheck3() {
#Check Machine Uptime - Method 3
daysVal="86400"
hrsVal="3600"
minsVal="60"

## Get uptime in seconds from sysctl
secUp=$(sysctl kern.boottime | awk '{print $5}' | sed 's/,//')

## Get epoch time in seconds
epochTime=$(date +%s)

## Calculate adjusted uptime for computer
upTime=$(($epochTime-$secUp))

## Calculate uptime in days, hours and minutes
DaysUp=$(($upTime/$daysVal))
HrsUp=$(($upTime/$hrsVal%24))
MinsUp=$(($upTime%$hrsVal/$minsVal))

if [[ $DaysUp == "0" && $HrssUp == "0" && $MinsUp == "0" ]]; then
	echo "less than a minute"
elif [[ $DaysUp == "0" && $HrsUp == "0" ]]; then
	echo "$MinsUp"m""
elif [[ $DaysUp == "0" ]]; then
	echo "$HrsUp"h" $MinsUp"m""
else
	echo "$DaysUp"d" $HrsUp"h" $MinsUp"m""
fi

}


echo "$HOST"
echo "---"
macModel
echo "--Uptime: $(uptimeCheck) | color=black"
echo "---"
echo "IP Address:" $IP
echo "---"
adminRightsCheck
echo "---"
