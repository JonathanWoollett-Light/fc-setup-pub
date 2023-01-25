#!/bin/bash -e
SB_ID="${1:-0}" # Default to sb_id=0

sudo systemctl start docker
sudo ./firecracker/tools/devtool build

FC_BIN="/home/ec2-user/firecracker/build/cargo_target/x86_64-unknown-linux-musl/debug/firecracker"
API_SOCKET="/home/ec2-user/firecracker-api.socket"

sudo setfacl -m u:${USER}:rw /dev/kvm
rm -f $API_SOCKET
$FC_BIN --api-sock "$API_SOCKET" --id "${SB_ID}" --no-seccomp
#screen -dmLS "fc-sb${SB_ID}" /usr/bin/env "/home/ec2-user/firecracker/build/cargo_target/x86_64-unknown-linux-musl/debug/firecracker" --api-sock "$API_SOCKET" --id "57b56f96-257a-4239-87ce-d149a221f962" --seccomp-level 0

