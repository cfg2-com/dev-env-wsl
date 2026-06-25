#!/bin/bash

TO="${1}"
MSG="${2}"

if [[ -z "$TO" ]]; then
    curl -s -X POST http://127.0.0.1:8080/api/v1/rpc \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"listGroups","id":1,"params":{}}' \
        | jq -r '.result[] | select(.name != null) | "\(.id) : \(.name)"'
        
    read -rp "Enter the recipients group ID: " TO
fi

if [[ -z "$MSG" ]]; then
    read -rp "Enter the message you would like to send: " MSG
fi

# If TO doesn't end with "=", try to match by group name (case insensitive)
if [[ "$TO" != *= ]]; then
    MATCHED_ID=$(curl -s -X POST http://127.0.0.1:8080/api/v1/rpc \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"listGroups","id":1,"params":{}}' \
        | jq -r --arg to "${TO,,}" '.result[] | select(.name | ascii_downcase == $to) | .id' | head -1)
    
    if [[ -n "$MATCHED_ID" ]]; then
        TO="$MATCHED_ID"
    fi
fi

curl -s -X POST http://127.0.0.1:8080/api/v1/rpc \
  -H "Content-Type: application/json" \
  -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"send\",
    \"id\": 1,
    \"params\": {
      \"groupId\": [\"$TO\"],
      \"message\": \"$MSG\"
    }
  }"
