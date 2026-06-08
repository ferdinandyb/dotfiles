#!/bin/bash

HDDPATH=/run/media/fbence/LaCie
RCLONE=rclone:pharmahungarybence:mashenka-restic

export RESTIC_PASSWORD_COMMAND="pass show restic"

FORGET_OPTS=(
    --keep-within-daily 7d
    --keep-within-weekly 1m
    --keep-within-monthly 1y
    --keep-within-yearly 75y
)

run_backup() {
    local backend=$1; shift
    echo "backend: $backend"
    restic backup -r "$backend" "$@"
    restic forget -r "$backend" "${FORGET_OPTS[@]}"
}

run_named_backup() {
    local name=$1; shift
    run_backup "local:$HDDPATH/restic/$name" "$@"
    # run_backup "$RCLONE/$name"               "$@"
}

echo email
run_named_backup email \
    /home/fbence/.mail \
    --exclude=".notmuch/**"

echo documents
run_named_backup documents \
    /home/fbence/Documents

echo pictures
run_named_backup pictures \
    /disk2/Pictures \
    /disk2/FamilyPictures \
    /disk2/PicturesÉviBence \
    /disk2/PhonePics

echo org
run_named_backup org \
    /home/fbence/org \
    /home/fbence/.task

echo gdrive
run_named_backup gdrive \
    /disk2/gdrive
