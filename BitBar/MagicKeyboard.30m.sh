#!/bin/bash
# <bitbar.title>Apple Wireless or Magic Keyboard Status</bitbar.title>
# <bitbar.version>2.0</bitbar.version>
# <bitbar.author>Phil Walker</bitbar.author>
# <bitbar.author.github>pwalker1485</bitbar.author.github>
# <bitbar.desc>Displays battery percentage for an Apple Wireless or Magic Keyboard</bitbar.desc>
# <bitbar.image>http://i.imgur.com/CtqV89Y.jpg</bitbar.image>

# Works with the Apple Wireless Keyboard or Apple Magic Keyboard

WIRELESS_KEYBOARD=$(ioreg -c AppleBluetoothHIDKeyboard | grep "BatteryPercent" | grep -F -v \{ | sed 's/[^[:digit:]]//g')
MAGIC_KEYBOARD=$(system_profiler SPBluetoothDataType | grep -A 6 "Magic Keyboard" | grep "Battery Level" | awk '{print $3}' | sed 's/%//g')
CHARGE=$(ioreg -p IOUSB -w0 | sed 's/[^o]*o //; s/@.*$//' | grep -v '^Root.*' | grep "Magic*")

function chargeStatus() {
#display lightning icon if Magic Keyboard is charging
if [[ $CHARGE == "Magic Keyboard" ]]; then
  echo "⌨️⚡️"
fi
}

function appleKeyboard() {
#Wireless/Magic Keyboard Battery Percentage
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
