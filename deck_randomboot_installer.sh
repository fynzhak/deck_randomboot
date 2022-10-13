#!/usr/bin/env bash



USER_SYSTEMD_DIR=$HOME/.config/systemd/user
SERVICE_FILE_NAME=deck_randomboot.service
SERVICE_FILE_PATH=$USER_SYSTEMD_DIR/$SERVICE_FILE_NAME
DEFAULT_VIDEO_DIR=$HOME/Videos/boot
VIDEO_DIR=$HOME/Videos/boot

create_service() {
SYSTEMD_SERVICE=$(cat <<EOF
[Unit]
Description=Pick a random boot video for the next boot
After=default.target

[Service]
ExecStartPre=-/usr/bin/mkdir $HOME/.steam/root/config/uioverrides/movies
ExecStartPre=-/usr/bin/rm $HOME/.steam/root/config/uioverrides/movies/deck_startup.webm
ExecStart=/usr/bin/sh -c 'find "$1"/*.webm -maxdepth 0 -type f | sort -R | head -1 | xargs -i ln -s {} $HOME/.steam/root/config/uioverrides/movies/deck_startup.webm'
Type=oneshot

[Install]
WantedBy=default.target
EOF
)
}

do_install() {
    echo "Select video directory (default $DEFAULT_VIDEO_DIR): "
    read VIDEO_DIR

    if [ -z "$VIDEO_DIR" ]; then
        VIDEO_DIR=$DEFAULT_VIDEO_DIR
    fi

    create_service "$VIDEO_DIR"

    echo "Installing service file to: $SERVICE_FILE_PATH"
    echo "$SYSTEMD_SERVICE" > "$SERVICE_FILE_PATH"
    systemctl --user daemon-reload
    systemctl --user enable $SERVICE_FILE_NAME
}

do_uninstall() {
    echo "Removing service file at: $SERVICE_FILE_PATH"
    systemctl --user disable $SERVICE_FILE_NAME
    rm "$SERVICE_FILE_PATH"
    systemctl --user daemon-reload
}

PS3="Select an option for Deck Random Boot: "

select op in install uninstall quit; do
    case $op in
        install) do_install ;;
        uninstall) do_uninstall ;;
        quit) break ;;
    esac
    break
done < /dev/tty
