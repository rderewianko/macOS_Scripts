#!/bin/bash

#Kill the loginwindow process to force the login window to use NoMAD Login AD settings set via CP
loginWindowPID=$(ps -Ajc | grep loginwindow | awk '{print $2}')

echo "Killing loginwindow process..."
killall loginwindow
#Wait for the loginwindow process to be restarted before continuing
while [[ $(ps -Ajc | grep loginwindow | awk '{print $2}') == "$loginWindowPID" ]]; do
  echo "loginwindow process being restarted..."
  sleep 1;
done
echo "Login window process restarted"

exit 0
