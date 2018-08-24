#!/bin/bash

# <bitbar.title>Bauer hostname and HD Status</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Ben Carter & Phil Walker August 2017</bitbar.author>
# <bitbar.author.github>retrac81</bitbar.author.github>
# <bitbar.desc>Creates a menu listing Mac OS details and HD stats. When free space on the boot volume reaches 15Gb user is warned via a graphic change in the menu.
# When the free space on boot volume is less than 5Gb a jamfHelper message is disaplyed and the menu bar changes icon and colour</bitbar.desc>
# <bitbar.image>base64 encoded for Self Service graphic</bitbar.image>
# <bitbar.dependencies>JSS Binary</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/retrac81</bitbar.abouturl>

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# VARIABLES
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#Get the logged in user
LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
userRealName=`dscl . -read /Users/$LoggedInUser | grep -A1 "RealName:" | sed -n 2p | awk '{print $2, $1}' | sed 's/,$//'`
#Get OS version
OS=$(sw_vers -productVersion)
#Get OS build
build=$(sw_vers -buildVersion)
#Get hostname
hostName=$(scutil --get ComputerName)
Mac_Model=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'["|"]' '/model/{print $4}')
#Get the IP addresses for all active adaptors
ipAddresses=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
#Get availbe disk space on Mac HD
BootVolume=`system_profiler SPSoftwareDataType | grep "Boot Volume:" | cut -d":" -f2`
macHDTotalBootDriveSize=`df -g / | awk {'print $2'} | tail -1`
macHDTotalBootDriveSizeHuman=`df -kH / | awk {'print $2'} | tail -1`
macHDAvailable=`df -g / | awk {'print $4'} | tail -1`
macHDAvailableHuman=`df -kH / | awk {'print $4'} | tail -1`
macHDPercentUsed=`df -g / | tail -1 | awk '{print $5}'`
#Get Mac uptime in days only
upTimeBasic=$(uptime | awk '{ print $3, $4 }' | grep "days" | sed 's/days/ /;s/,/ /g')
#Check for Kernal Panic
kernelPanic=`[ -f /Library/Logs/DiagnosticReports/*.panic ] && echo "Yes" || echo "No"`
#Check SMART status
smartStatus=$(diskutil info disk0 | grep SMART | awk {'print $3'})
#Generate base64 images for self service and mac models
imageMacHDIcon='iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNui8sowAAANfSURBVDiNrZRfSFtXHMc/5yYm6k0zkyydNrlZHdGMFeOKk7l1oPvjfJGN7WEIq4WyPw++FEp8EDqmMNiYPq0PPvSljK2Uwv6B6JwPZR0KxTqlMpssdQ7stLS7193qtSbx3rMXK+oie/HAD87hHD58f19+5yuklBzkUg6UBrh3HhoaGuK6rl+2LCsRCoWk4zjFVSgKuq4LVVUzoVCoY2pq6vajO7Gz5erq6uvBYPA5TdOU2dlZpJRYloXYakTioKoqQgjq6upYXFx0DMO4sbCw8HxRYDAYzLW3t3tSqRQnTrzIM08/y1tvv0k8EQXgduYO3337A3PpGcbHJxgYGGBoaChvGIa3KDCRSKw6juMzDJ2Od07R/fG7LG1cRTf/BCD02FGOlL5Mf9/XXL7yJcFgCEVR1jKZzKGiHkopWV9fp631Dc71dzD66yfYBXC5PADc+/svfi8Z51x/Dysr//DzL2Ooqrrb373AEreXsz2nuTZ3HuF4EUJBsFVCQThers2d52zPaUrcXvaO3S6gaZrUJxsoP3wf84GBLQuE/QlOtlzgZMsFwv4EtixgPjAoP3yf+mQDpmnuD7Qsi1gsyvrmXVyKB9su0Hr8DJcuDstLF4dl6/Ez2HYBl+JhffMusVgUy7J2AXd5KIRgc9NGCPd2K6sPdeLx2u39I2uEcG+9Ffsr9Pv9ZLNZVJeGI/N43GX8ND1ALPkQrc7ix6lPKXGX4sg8qksjm83i9/v3B/p8Pn67dZM7t1xoVbUU7ByKIllaWhb39CVxNHoMb2kJVeGnmJ/eZC59E5/Ptz8QwOt10/fR5xx7/D0qKvzEtUa++mKaU+2fMXHFQ6XdwevJPr7/ZgTbLqAoexBSyu2qqalZra2tlZWVT8hXWtrkxPWr8g9jRK5auvzg/Q+lQMgjVZp87dU2OTIyLJubm2UkElndyfjPT7Ft2weQy20gcPNC00vUJJ4kmawnn8/T29vL/Pw8qVQKgMHBwbW1tbVDRRUGAoFcZ2ennJmZkZFIRMbjcRmNRmU4HJaBQEB2dXXJsbEx2d3dLUdHR2VjY6OMxWK5fRXuTRuXy7VrpEzTRNM0mpqamJycZHl52SkrK7uRTqeLp83/5aEQgo2NDVZWVqioqBDl5eUZoCOdThfPw4NY/wKiXaptTtg6iAAAAABJRU5ErkJggg=='
imageSelfService='iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAE4UlEQVR42p2Wa2xTZRzGEQGNkhhjjF8wWQh+MEY/mGBi4geijuDtC7o5AoJDxWiMgMSgDBATICgMYQsanDAnyBywCR2wS3GXdmNbu1LG2Ohs161b15b1sl7O6bm855zH/zlzY8VtQd7kyWl7znl+//f5v+c9nTNnmgFgHWkQ0BRFZYw+e0mlpJWkJ0j3zbnXQTcv1jStNiWNwemvRZPnJBxDFxFK9mtMlX10/nfSx6Sn78X8ftJ2iQnyyc5tKGx6F983rsSBplwcafkAFc5v0RuyahLjebrOR4WY6PgmacHdAh5XVbW5deC0YTyT/nDuAi8lkBYkCJKMfyPcQXqO9OhsgBfTUipVavtiVoC5rwRMkXCm3onyS51ovz6A0WhSb1iEPKpJ60kLpwMc9kacKLKundH8kGU1xdSCWJzDtkMmbD14HgVF1dj7cx1+M3VgwB8BRZekJL4mv/lTzR9WNCVq6T9FRm9nGPaHHbD0l+NYx0aU2bcgkQ7DfOWmYT6d2rsGQIAhURSfmgrIF+QUznbtyai4znUUEyNN5wMJNxRFQUWNY3IGd2r/8ctIcqIWj8fzJsznkZpUTcFoygeLtxw/XdmAA425GB67CZHx6PCdw9BYjwGiCJDiRAyORFBpvobtRRcyAHsormA4gVAo9PkE4AW6KcBi18FSg1CpUr2JI/E+SCyNGB9AcUs+qm/8AJXMI5R/YDRhgBRVRfGp5gzAwbIGfYVJdrs9WzdfQNoCJS1ytN45yj/t3Alp4CxUPmhULCuC0dhQwgtBlHGi2oZdRy5CkhhCVKne4KmAWmsvOI67arPZntQBS6kh5+Vgk8bVv4xJUf4s3DleJcWmKqIB0yvu/tuPFodHbyTarnlRcLg6AxCN82okEikuKip6QAfs11QW5h1fYSqAb3kfqhSHHGgAZ86G6K0wYCyZgsLxk/FYCbTvl/rJPpScadXBYz6fL2cif5eS7AffnJsBEHqLjYoZ9SHdtRvyqA2qKGKoYDduHTsJNS1Qr2TIKQ6RWAr2Gz6crr2KHk+AopN6KisrF00ABHmkDtzl1zNnYP+Sqh2ERlVqjKOjQoYM3g2bECj80QDE/2rGwGdbEa26QNcmIdF5xlQEAoFDZD13AhCX/ZcI8FoGYFzZ46BYlwFSad/RozFE332bt8P16kpDfW+tRtRUC0WWZar++ckHTN/clISHIlo1DWBcUrCZejCI0NFfMVbXANEfAN/jgmv5O7cBb+QhdrEesViskWxvbxHpdDpPVeUR+VabsUT/A6DeqExA9KwJrhU5hpF71Udw566fNNflod/EIb/W3d29NmOD6+zsnE/U9xhjbkVOCbK/RuNtG8E1Ecy8HKK7lJYpB/8332UY3qnhnftAxXocDseS6XbquQR6lh7tTclkslIU+CAb66WH7TQtyRG9Mrhz1s8KSLY7tGg0eqKxsXHhbO+cuWaz+ZGGhoZn3G73Zo5LOqmhCqMZhCv+hGfdp9OaD24qgCwI3PDw8Ifkcffv66ysrActFssrVFkZLY5+JtOqv9ql+XcXwrPmEyP3oR17Id0a1XiebyspKVl0T38Eli1bNo+mviQYDObTFnxc4HmXNBpm0khQk3k+TtvC+ZqamqX/q/qZhslkeog2scVWq3VFa2vrmqqqqpfKysoem+n6fwD6JpzDfYBxgQAAAABJRU5ErkJggg=='
imageMacPro='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'
imageMacPro2013='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'

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Functions to be used by the script
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
function checkUpTime ()
{
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
	timeup="less than a minute"
elif [[ $DaysUp == "0" && $HrsUp == "0" ]]; then
	timeup="$MinsUp"m""
elif [[ $DaysUp == "0" ]]; then
	timeup="$HrsUp"h" $MinsUp"m""
else
	timeup="$DaysUp"d" $HrsUp"h" $MinsUp"m""
fi
}

function checkStatus ()
{
#Checks the status of the HD and then sets the icon and colour of the hostname that appears in the menu bar
if [[ $macHDAvailable -le "5" || $smartStatus == "Failed" || $upTimeBasic -ge "6" ]]; then
	status="❗️"
	statusColour="red"
	uptimeColour="red"
elif [ $macHDAvailable -le "15" ]; then
	status="⚠️"
	statusColour=""
else
	status=""
	statusColour=""
fi
#Checks the model and sets the emoji for desktop or laptop to be rendered next to the Mac OS details
if [[ $Mac_Model = *"MacBook"* ]]; then
    macModelIcon="💻"
elif [[ $Mac_Model = *"iMac"* ]]; then
    macModelIcon="🖥"
elif [[ $Mac_Model = "MacPro3,1" ]] || [[ $Mac_Model = "MacPro4,1" ]] || [[ $Mac_Model = "MacPro5,1" ]]; then
    macModelIcon="Mac OS $OS ($build) | image=$imageMacPro"
elif [[ $Mac_Model = "MacPro6,1" ]]; then
    macModelIcon="Mac OS $OS ($build) | image=$imageMacPro2013"
else
		macModelIcon=""
fi
}

#JamfHelper popup messages
function jamfHelperLowDiskSpace ()
{
#JamfHelper command when disk space is less than 5GB
HELPER2=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns -title 'Message from Bauer IT' -heading 'You are running out of disk space!' -description 'Your Mac '$hostName' is running out of space and will become unresponsive if no action is taken.

- Total size: '$macHDTotalBootDriveSizeHuman'
- Free space: '$macHDAvailableHuman'
- Percent Used: '$macHDPercentUsed'

Please call the IT Service Desk for assistance
            0345 058 4444
' -button1 "Ok" -defaultButton "1" `> /dev/null 2>&1 &
}

function menuSystem ()
{
	#Display system details for first line of sub menu
	echo "$macModelIcon Mac OS $OS ($build)"
 echo "-- Uptime $timeup | color="$uptimeColour""
}

function menuNetwork ()
{
	echo "IP Address" $ipAddresses
}
function menuStorage ()
{
	#Check for space available and change the icon that is rendered in the sub menu - less than 5GB and less than 10GB
	if [[ $macHDAvailable -le "5" ]]; then
		jamfHelperLowDiskSpace
		echo "❗️ Macintosh HD" $macHDPercentUsed "Used" $macHDAvailableHuman "Available | color=red href=https://mediavine.bauermedia.co.uk/Interact/Pages/Content/Document.aspx?id=3084"
	elif [[ $macHDAvailable -le "10" ]]; then
		echo "⚠️ Macintosh HD" $macHDPercentUsed "Used" $macHDAvailableHuman "Available | color=orange href=https://mediavine.bauermedia.co.uk/Interact/Pages/Content/Document.aspx?id=3084"
	else
		echo "Macintosh HD" $macHDPercentUsed "Used" $macHDAvailableHuman "Available | image=$imageMacHDIcon color=green href=https://mediavine.bauermedia.co.uk/Interact/Pages/Content/Document.aspx?id=3084"
	fi

	if [[ $smartStatus == "Failed" ]]; then
		echo "⚠️ SMART Status" $smartStatus "| color=red"
	fi
}

function menuFV ()
{
if [[ $Mac_Model = *"MacBook"* ]]; then
        FVStatus=$(fdesetup status | grep "FileVault" | head -1)
        FVEncryptionStatus=$(fdesetup status | grep "Encryption")
        FVDecryptionStatus=$(fdesetup status | grep "Decryption")
        if [[ "$FVStatus" == "FileVault is On." ]]; then
                echo "✅ $FVStatus |color=green"
                if [[ -n "⌛️ $FVEncryptionStatus" ]]; then
                                echo "$FVEncryptionStatus"
                fi
        else
                echo "⚠️ $FVStatus |color=red"
                if [[ -n "⌛️ $FVDecryptionStatus" ]]; then
                        echo "$FVDecryptionStatus"
                fi
        fi
fi
}

function menuHealth ()
{
	if [[ $upTimeBasic -ge "6" ]]; then
			echo "❗️ Your Mac needs a restart | color=red"
	fi
	if [[ $kernelPanic == "Yes" ]]; then
			echo "❗️ This Mac has suffered a Kernel Panic | color=red"
	fi
}
function menuUser ()
{
	if [[ $(dsmemberutil checkmembership -U "$LoggedInUser" -G admin) != *not* ]]; then
					#Show on holding alt key if user has admins
	        echo "🔓 $userRealName has admin rights | color=red alternate=true"
	else
					echo "🔒 $userRealName is a standard account | alternate=true"
	fi
}
############################################################################################################################
#First off check the status of the storage and set the required colour and icons
checkStatus
#Get the uptime of the Mac to be populated in submenu
checkUpTime
#Build the menubar
if [ -z $statusColour ]; then
        echo $status$hostName
else
        echo $status$hostName "| color="$statusColour""
fi
#Add sub menu content
echo "---"

menuSystem

echo "---"

menuNetwork

echo "---"

menuStorage

echo "---"

menuFV

echo "---"

menuHealth

echo "---"

echo "Self Service | href=selfservice://localhost image=$imageSelfService"
menuUser
