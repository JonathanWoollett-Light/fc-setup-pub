#!/bin/bash -e
SB_ID="${1:-0}" # Default to sb_id=0

API_SOCKET="/home/ec2-user/alsardan/run/api.socket"
SNAP_FILE="/home/ec2-user/alsardan/run/firecracker.snap"
SNAP_MEM_FILE="/home/ec2-user/alsardan/run/firecracker.mem"

CURL=(curl --silent --show-error --unix-socket "${API_SOCKET}" --write-out "HTTP %{http_code}")

curl_put() {
    local URL_PATH="$1"
    local OUTPUT RC
    OUTPUT="$("${CURL[@]}" -X PUT --data @- "http://localhost/${URL_PATH#/}" 2>&1)"
    RC="$?"
    if [ "$RC" -ne 0 ]; then
        echo "Error: curl PUT ${URL_PATH} failed with exit code $RC, output:"
        echo "$OUTPUT"
        return 1
    fi
    # Error if output doesn't end with "HTTP 2xx"
    if [[ "$OUTPUT" != *HTTP\ 2[0-9][0-9] ]]; then
        echo "Error: curl PUT ${URL_PATH} failed with non-2xx HTTP status code, output:"
        echo "$OUTPUT"
        return 1
    fi
}

curl_patch() {
    local URL_PATH="$1"
    local OUTPUT RC
    OUTPUT="$("${CURL[@]}" -X PATCH --data @- "http://localhost/${URL_PATH#/}" 2>&1)"
    RC="$?"
    if [ "$RC" -ne 0 ]; then
        echo "Error: curl PATCH ${URL_PATH} failed with exit code $RC, output:"
        echo "$OUTPUT"
        return 1
    fi
    # Error if output doesn't end with "HTTP 2xx"
    if [[ "$OUTPUT" != *HTTP\ 2[0-9][0-9] ]]; then
        echo "Error: curl PATCH ${URL_PATH} failed with non-2xx HTTP status code, output:"
        echo "$OUTPUT"
        return 1
    fi
}

curl_patch '/vm' <<EOF
{
    "state": "Paused"
}
EOF

sleep 0.5s

curl_put '/snapshot/create' <<EOF
{
    "snapshot_type": "Full",
    "snapshot_path": "${SNAP_FILE}",
    "mem_file_path": "${SNAP_MEM_FILE}",
    "version": "1.0.0"
}
EOF

sleep 0.5s

curl_patch '/vm' <<EOF
{
    "state": "Resumed"
}
EOF
