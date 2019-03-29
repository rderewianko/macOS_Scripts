#!/bin/bash
# <bitbar.title>Apple Wireless or Magic Keyboard Status</bitbar.title>
# <bitbar.version>2.0</bitbar.version>
# <bitbar.author>Phil Walker</bitbar.author>
# <bitbar.author.github>pwalker1485</bitbar.author.github>
# <bitbar.desc>Displays battery level or charge status (Magic Keyboard only) for an Apple Wireless or Magic Keyboard</bitbar.desc>
# <bitbar.image>http://i.imgur.com/CtqV89Y.jpg</bitbar.image>

#Apple Wireless Keyboard battery level
WIRELESS_KEYBOARD=$(ioreg -c AppleBluetoothHIDKeyboard | grep "BatteryPercent" | grep -F -v \{ | sed 's/[^[:digit:]]//g')
#Apple Magic Keyboard battery level
MAGIC_KEYBOARD=$(ioreg -c AppleDeviceManagementHIDEventService -r -l | grep -i "Keyboard" -A 20 | grep "BatteryPercent" | grep -F -v \{ | sed 's/[^[:digit:]]//g')
#Check if a Magic Keyboard is connected via USB
CHARGE=$(ioreg -p IOUSB -w0 | sed 's/[^o]*o //; s/@.*$//' | grep -v '^Root.*' | grep "Magic*")

function chargeStatus() {
#Display lightning icon if Magic Keyboard is connected via USB
if [[ $CHARGE == "Magic Keyboard" ]]; then
  echo "⚡️"
fi
}

function appleKeyboard() {
#Set the colour based on the remaining charge for either keyboard
if [ $WIRELESS_KEYBOARD ]; then
  if [ $WIRELESS_KEYBOARD -le 20 ]; then
    echo "⌨️$WIRELESS_KEYBOARD% | color=red"
  else
    echo "⌨️$WIRELESS_KEYBOARD%"
  fi
elif [ $MAGIC_KEYBOARD ]; then
  if [ $MAGIC_KEYBOARD -le 20 ]; then
    echo "⌨️$MAGIC_KEYBOARD% | color=red"
  else
    echo "⌨️$MAGIC_KEYBOARD%"
  fi
fi
}

function chargeRequired() {
#If using an Apple Magic Keyboard show additional info if the battery level is low
if [ $MAGIC_KEYBOARD ]; then
  if [ $MAGIC_KEYBOARD -le 20 -a $MAGIC_KEYBOARD -ge 11 ]; then
  echo "🔋Level Low | color=red"
elif [ $MAGIC_KEYBOARD -le 10 ]; then
  echo "🔋Level Critical | color=red"
  echo "⚡️Charge Required | color=red"
  fi
fi
}

echo "$(chargeStatus)$(appleKeyboard)"
echo "---"
echo "$(chargeRequired)"
