#!/bin/bash

TO="${1}"
MSG="${2}"

if [[ -z "$TO" ]]; then
    read -rp "Enter the recipients phone number in E.164 format (ex: +14142224455): " TO
fi

if [[ -z "$MSG" ]]; then
    read -rp "Enter the message you would like to send: " MSG
fi

curl -s -X POST http://127.0.0.1:8080/api/v1/rpc \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"send\",
    \"id\": 1,
    \"params\": {
      \"recipient\": [\"$TO\"],
      \"message\": \"$MSG\"
    }
  }"
