#!/bin/bash

HDDPATH=/home/fbence/mounted/lacie

echo email
for backend in \
    local:$HDDPATH/restic/email \
    rclone:onedrive:mashenka-restic/mail
do
    echo backend: $backend
    restic backup -r $backend --password-command "pass show restic" \
        /home/fbence/.mail

    restic forget -r $backend --password-command "pass show restic" \
        --keep-within-daily 7d   \
        --keep-within-weekly 1m  \
        --keep-within-monthly 1y \
        --keep-within-yearly 75y

done

echo documents
for backend in \
    local:$HDDPATH/restic/documents \
    rclone:onedrive:mashenka-restic/documents
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
    rclone:onedrive:mashenka-restic/pictures
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
