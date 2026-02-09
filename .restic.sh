#!/bin/bash

HDDPATH=/run/media/fbence/LaCie
RCLONE=rclone:pharmahungarybence:mashenka-restic

echo email
for backend in \
    local:$HDDPATH/restic/email \
    $RCLONE/email
do
    echo backend: $backend
    restic backup -r $backend --password-command "pass show restic" \
        /home/fbence/.mail \
        --exclude=".notmuch/**"

    restic forget -r $backend --password-command "pass show restic" \
        --keep-within-daily 7d   \
        --keep-within-weekly 1m  \
        --keep-within-monthly 1y \
        --keep-within-yearly 75y

done

echo documents
for backend in \
    local:$HDDPATH/restic/documents \
    $RCLONE/documents
do
    echo backend: $backend
    restic backup -r $backend --password-command "pass show restic" \
        /home/fbence/Documents

    restic forget -r $backend --password-command "pass show restic" \
        --keep-within-daily 7d   \
        --keep-within-weekly 1m  \
        --keep-within-monthly 1y \
        --keep-within-yearly 75y

done

echo pictures
for backend in \
    local:$HDDPATH/restic/pictures \
    $RCLONE/pictures
do
    echo backend: $backend
    restic backup -r $backend --password-command "pass show restic" \
        /disk2/Pictures \
        /disk2/FamilyPictures \
        /disk2/PicturesÉviBence \
        /disk2/PhonePics

    restic forget -r $backend --password-command "pass show restic" \
        --keep-within-daily 7d   \
        --keep-within-weekly 1m  \
        --keep-within-monthly 1y \
        --keep-within-yearly 75y

done

echo org
for backend in \
    local:$HDDPATH/restic/org \
    $RCLONE/org
do
    echo backend: $backend
    restic backup -r $backend --password-command "pass show restic" \
        /home/fbence/org \
        /home/fbence/.task

    restic forget -r $backend --password-command "pass show restic" \
        --keep-within-daily 7d   \
        --keep-within-weekly 1m  \
        --keep-within-monthly 1y \
        --keep-within-yearly 75y

done
