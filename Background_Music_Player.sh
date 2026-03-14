#!/bin/bash

# --- Initial Setup ---
if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_NAME=$(basename "$SCRIPT_PATH")
CURR_TTY="/dev/tty1"
REAL_USER=${SUDO_USER:-$USER}
MUSIC_DIR="/roms/music"
TEMP_M3U="/tmp/current_playlist.m3u"


# Detect Player (mpv for ArkOS, cvlc for dArkOS)
if command -v mpv &> /dev/null; then
    ACTIVE_PLAYER="mpv"
else
    ACTIVE_PLAYER="vlc"
fi

exec > $CURR_TTY 2>&1
printf "\033c" > "$CURR_TTY"
export TERM=linux
export XDG_RUNTIME_DIR="/run/user/$(id -u)"


# Controller Setup
pkill -9 -f gptokeyb || true
if [ -f "/opt/inttools/gptokeyb" ]; then
    [[ -e /dev/uinput ]] && chmod 666 /dev/uinput 2>/dev/null || true
    export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
    /opt/inttools/gptokeyb -1 "$SCRIPT_NAME" -c "/opt/inttools/keys.gptk" >/dev/null 2>&1 &
fi


# --- Functions ---

ExitScript() {
    pkill -f "gptokeyb -1 $SCRIPT_NAME" || true
    printf "\033c\e[?25h" > "$CURR_TTY"
    exit 0
}
trap ExitScript EXIT SIGINT SIGTERM
printf "\e[?25l" > "$CURR_TTY"

pick_song() {
    local files=()
    local i=1
    while IFS= read -r line; do
        files+=("$i" "$(basename "$line")")
        ((i++))
    done < <(find "$MUSIC_DIR" -maxdepth 1 -type f \( -name "*.mp3" -o -name "*.ogg" -o -name "*.wav" -o -name "*.flac" \) | sort)
    
    if [ ${#files[@]} -eq 0 ]; then
        dialog --msgbox "No music files found in $MUSIC_DIR" 10 40
        return
    fi

    choice=$(dialog --backtitle "Background Music Player by SjslTech ($ACTIVE_PLAYER)" --title " SELECT STARTING TRACK " --menu "Choose a song:" 15 55 10 "${files[@]}" --output-fd 1)
    [ $? -ne 0 ] && { echo "CANCELLED"; return; }
    local index=$(( (choice - 1) * 2 + 1 ))
    echo "$MUSIC_DIR/${files[$index]}"
}


# --- Main Menu ---

while true; do
    MAIN_CHOICE=$(dialog --backtitle "Background Music Player by SjslTech ($ACTIVE_PLAYER)" --title " MAIN MENU " \
        --menu "Select an option:" 12 45 5 \
        1 "Play Music" \
        2 "Stop Music" \
        3 "Exit" --output-fd 1)

    case "$MAIN_CHOICE" in
        1)
            SELECTED_SONG=$(pick_song)
            [ "$SELECTED_SONG" == "CANCELLED" ] && continue

            MODE=$(dialog --backtitle "Background Music Player by SjslTech" --title " PLAYBACK MODE " \
                --menu "Choose playback style:" 12 40 4 \
                1 "Shuffle (Random)" \
                2 "In Order (Linear)" --output-fd 1)
            [ $? -ne 0 ] && continue

            pkill mpv 2>/dev/null
            pkill vlc 2>/dev/null
            
            if [ "$ACTIVE_PLAYER" == "mpv" ]; then
                # ArkOS Logic
                [ "$MODE" == "1" ] && PLAY_MODE="--shuffle" || PLAY_MODE="--no-shuffle"
                INDEX=$(find "$MUSIC_DIR" -maxdepth 1 -type f | sort | grep -nF "$(basename "$SELECTED_SONG")" | cut -d: -f1 | awk '{print $1-1}')
                sudo -u "$REAL_USER" mpv --no-video --loop-playlist $PLAY_MODE --volume=70 --audio-device=alsa/plug:dmixer --playlist-start="$INDEX" "$MUSIC_DIR/" >/dev/null 2>&1 &
            else
                # dArkOS Logic
                echo "$SELECTED_SONG" > "$TEMP_M3U"
                if [ "$MODE" == "1" ]; then
                    find "$MUSIC_DIR" -maxdepth 1 -type f \( -name "*.mp3" -o -name "*.ogg" -o -name "*.wav" -o -name "*.flac" \) | grep -vF "$SELECTED_SONG" | shuf >> "$TEMP_M3U"
                else
                    find "$MUSIC_DIR" -maxdepth 1 -type f \( -name "*.mp3" -o -name "*.ogg" -o -name "*.wav" -o -name "*.flac" \) | sort | grep -vF "$SELECTED_SONG" >> "$TEMP_M3U"
                fi
                sudo -u "$REAL_USER" cvlc -I dummy --no-random --loop --aout=alsa --volume 512 "$TEMP_M3U" >/dev/null 2>&1 &
            fi
            
            dialog --infobox "Starting playback..." 3 30
            sleep 1
            ;;
        2)
            pkill mpv 2>/dev/null
            pkill vlc 2>/dev/null
            rm -f "$TEMP_M3U"
            dialog --infobox "Music stopped." 3 20
            sleep 1
            ;;
        3|*)
            ExitScript
            ;;
    esac
done
