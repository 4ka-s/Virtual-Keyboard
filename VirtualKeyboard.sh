#!/bin/bash

sleep 2

monitors=$(hyprctl monitors -j | jq -r '.[].name')

for mon in $monitors; do
    hyprctl dispatch focusmonitor "$mon"
    quickshell -p ./Notification.qml &
    sleep 1
done

for mon in $monitors; do
    hyprctl dispatch focusmonitor "$mon"
    break
done