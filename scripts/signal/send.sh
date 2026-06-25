#!/bin/bash

TO="${1}"
MSG="${2}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$TO" ]]; then
    read -rp "Enter the recipient phone number or group name: " TO
fi

if [[ -z "$MSG" ]]; then
    read -rp "Enter the message you would like to send: " MSG
fi

if [[ "$TO" == +* ]]; then
    "$SCRIPT_DIR/person.sh" "$TO" "$MSG"
else
    "$SCRIPT_DIR/group.sh" "$TO" "$MSG"
fi

