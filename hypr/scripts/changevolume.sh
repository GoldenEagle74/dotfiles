#!/bin/bash

# Путь к иконкам
msgTag=volume
volume_step=5
notification_timeout=1000

# Функция для получения имени микрофона
get_microphone_name() {
    source_list=$(pamixer --list-sources)
    source_name=$(echo "$source_list" | grep -oP '(?<=\d ")(alsa_input[^"]+)' | head -n 1)
    echo "$source_name"
}

# Функция для отправки уведомления о громкости
send_volume_notification() {
    current_volume=$(pamixer --get-volume-human | sed 's/[^0-9]*//g')
    mute_status=$(pamixer --get-mute)

    if [[ $mute_status == "true" ]]; then
        dunstify -a "changeVolume" -u low -h string:x-dunst-stack-tag:$msgTag " Volume muted"
    else
        if [ "$current_volume" -lt 50 ]; then
            volume_icon=""
        else
            volume_icon=""
        fi

        dunstify -a "changeVolume" -u low -h string:x-dunst-stack-tag:$msgTag \
        -h int:value:"$current_volume" -t $notification_timeout "$volume_icon Volume: ${current_volume}%"
    fi
}

# Функция для отправки уведомления о муте микрофона
send_microphone_notification() {
    mute_status=$(pamixer --source "$microphone_name" --get-mute)
    current_microphone_volume=$(pamixer --source "$microphone_name" --get-volume-human | sed 's/[^0-9]*//g')

    if [[ $mute_status == "true" ]]; then
        dunstify -a "changeVolume" -u low -h string:x-dunst-stack-tag:$msgTag " Microphone muted"
    else
        dunstify -a "changeVolume" -u low -h string:x-dunst-stack-tag:$msgTag \
        -h int:value:"$current_microphone_volume" -t $notification_timeout " Microphone: ${current_microphone_volume}%"
    fi
}

# Обработка параметров
while getopts ":o:i:" opt; do
    case $opt in
        o)
            case $OPTARG in
                m)
                    pamixer --toggle-mute
                    send_volume_notification
                    ;;
                d)
                    pamixer --decrease $volume_step
                    send_volume_notification
                    ;;
                i)
                    pamixer --increase $volume_step
                    send_volume_notification
                    ;;
                *)
                    echo "Invalid option argument for -o"
                    exit 1
                    ;;
            esac
            ;;
        i)  
            microphone_name=$(get_microphone_name)
            case $OPTARG in
                m)
                    pamixer --source "$microphone_name" --toggle-mute
                    send_microphone_notification
                    ;;
                d)
                    pamixer --source "$microphone_name" --decrease $volume_step
                    send_microphone_notification
                    ;;
                i)
                    pamixer --source "$microphone_name" --increase $volume_step
                    send_microphone_notification
                    ;;
                *)
                    echo "Invalid option argument for -i"
                    exit 1
                    ;;
            esac
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
