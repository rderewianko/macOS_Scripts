#!/bin/bash
# <bitbar.title>Apple Magic Mouse Status</bitbar.title>
# <bitbar.version>2.0</bitbar.version>
# <bitbar.author>Phil Walker</bitbar.author>
# <bitbar.author.github>pwalker1485</bitbar.author.github>
# <bitbar.desc>Displays battery level or charge status (Magic Mouse 2 only) for an Apple Magic Mouse</bitbar.desc>
# <bitbar.image>https://i.imgur.com/7pICO5M.png</bitbar.image>

# Works with Magic Mouse and Magic Mouse 2

#Magic Mouse battery level
MAGIC_MOUSE=$(ioreg -c BNBMouseDevice |grep '"BatteryPercent" =' | grep -F -v \{ | sed 's/[^[:digit:]]//g')
#Magic Mouse 2 battery level
MAGIC_MOUSE2=$(ioreg -c AppleDeviceManagementHIDEventService -r -l | grep -i "Mouse" -A 20 | grep "BatteryPercent" | grep -F -v \{ | sed 's/[^[:digit:]]//g')
#Check if a Magic Mouse 2 is connected via USB
CHARGE=$(ioreg -p IOUSB -w0 | sed 's/[^o]*o //; s/@.*$//' | grep -v '^Root.*' | grep "Magic*")

function chargeStatus() {
#display lightning icon if Magic Mouse 2 is connected via USB
if [[ $CHARGE == "Magic Mouse 2" ]]; then
  echo "⚡️"
fi
}

function magicMouse() {
#Set the colour based on the remaining charge for either mouse
if [ $MAGIC_MOUSE ]; then
  if [ $MAGIC_MOUSE -le 20 ]; then
    echo "🖱$MAGIC_MOUSE% | color=red"
  else
    echo "🖱$MAGIC_MOUSE%"
  fi
elif [ $MAGIC_MOUSE2 ]; then
  if [ $MAGIC_MOUSE2 -le 20 ]; then
    echo "🖱$MAGIC_MOUSE2% | color=red"
  else
    echo "🖱$MAGIC_MOUSE2%"
  fi
fi
}

function chargeRequired() {
#If using an Apple Magic Mouse 2 show additional info if the battery level is low
if [ $MAGIC_MOUSE2 ]; then
  if [ $MAGIC_MOUSE2 -le 20 -a $MAGIC_MOUSE2 -ge 11 ]; then
  echo "🔋Level Low | color=red"
elif [ $MAGIC_MOUSE2 -le 10 ]; then
  echo "🔋Level Critical | color=red"
  echo "⚡️Charge Required | color=red"
  fi
fi
}

echo "$(chargeStatus)$(magicMouse)"
echo "---"
echo "$(chargeRequired)"
