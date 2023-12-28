#!/bin/bash

brightness_step=5
notification_timeout=1000

# Функция для получения текущего уровня яркости
get_brightness() {
    brightnessctl -m | awk -F ',' '/backlight/ {print $4}' | tr -d '%'
}

# Функция для отправки уведомления о яркости
send_brightness_notification() {
    current_brightness=$(get_brightness)
    dunstify -a "changeBrightness" -u low -h string:x-dunst-stack-tag:brightness \
    -h int:value:"$current_brightness" -t $notification_timeout " Brightness: ${current_brightness}%"
}

# Обработка параметров
while getopts ":div:" opt; do
    case $opt in
        d)
            brightnessctl -q s "${brightness_step}%-"
            send_brightness_notification
            ;;
        i)
            brightnessctl -q s "${brightness_step}%+"
            send_brightness_notification
            ;;
	v)
            brightness_step=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

