#!/bin/bash

brightness_step=5
notification_timeout=1000

# Функция для получения текущего уровня яркости
get_brightness() {
    light -G | awk '{print int($1)}'
}

# Функция для отправки уведомления о яркости
send_brightness_notification() {
    current_brightness=$(get_brightness)
    dunstify -a "changeBrightness" -u low -h string:x-dunst-stack-tag:brightness \
    -h int:value:"$current_brightness" -t $notification_timeout " Brightness: ${current_brightness}%"
}

# Обработка параметров
while getopts ":di" opt; do
    case $opt in
        d)
            light -U $brightness_step
            send_brightness_notification
            ;;
        i)
            light -A $brightness_step
            send_brightness_notification
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
