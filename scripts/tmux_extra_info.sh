#!/bin/bash
WIDTH=$1
# Default threshold: 120 columns
if [ -z "$WIDTH" ] || [ "$WIDTH" -lt 120 ]; then
    exit 0
fi

LEFT_SEP=$(tmux show-option -gqv "@left_sep")
RIGHT_SEP=$(tmux show-option -gqv "@right_sep")

# Weather representation
WEATHER_FILE="/tmp/tmux_weather"
WEATHER_STR=""
if [ -f "$WEATHER_FILE" ]; then
    WEATHER_VAL=$(cat "$WEATHER_FILE")
    if [ ! -z "$WEATHER_VAL" ]; then
        EMOJI=$(echo "$WEATHER_VAL" | cut -d' ' -f1)
        TEMP=$(echo "$WEATHER_VAL" | cut -d' ' -f2-)
        WEATHER_STR="#[fg=#94e2d5,bg=default]${LEFT_SEP}#[fg=#181825,bg=#94e2d5,bold] ${EMOJI} ${TEMP} #[fg=#94e2d5,bg=default]${RIGHT_SEP} "
    fi
fi

# Notification representation
NOTIF_FILE="/tmp/tmux_notification"
NOTIF_STR=""
if [ -f "$NOTIF_FILE" ]; then
    NOTIF_TEXT=$(head -n 1 "$NOTIF_FILE")
    NOTIF_TIME=$(tail -n 1 "$NOTIF_FILE")
    NOW=$(date +%s)
    DIFF=$((NOW - NOTIF_TIME))
    if [ "$DIFF" -lt 12 ]; then
        NOTIF_STR="#[fg=#f38ba8,bg=default]${LEFT_SEP}#[fg=#181825,bg=#f38ba8,bold] 🔔 ${NOTIF_TEXT} #[fg=#f38ba8,bg=default]${RIGHT_SEP} "
    fi
fi

echo -n "${NOTIF_STR}${WEATHER_STR}"
