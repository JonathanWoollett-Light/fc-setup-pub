#!/bin/bash -e
SB_ID="${1:-0}" # Default to sb_id=0

ROOTFS="/home/ec2-user/alsardan/rootfs/bionic.rootfs.ext4"
KERNEL="/home/ec2-user/alsardan/rootfs/vmlinux.bin"

TAP_DEV="tap0"

KERNEL_BOOT_ARGS="console=ttyS0 reboot=k panic=1 ipv6.disable=1 i8042.nokbd 8250.nr_uarts=1 random.trust_cpu=on"

API_SOCKET="/home/ec2-user/alsardan/run/api.socket"
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

LOGFILE="/home/ec2-user/alsardan/run/firecracker.log"
touch $LOGFILE
#metricsfile="$PWD/output/fc-sb${SB_ID}-metrics"
#metricsfile="/dev/null"

#rm -f $logfile $metricsfile
#touch $logfile $metricsfile

FC_IP="172.16.0.2"
TAP_IP="172.16.0.1"
FC_MAC="06:00:AC:10:00:02"
MASK_SHORT="/30"

echo "Setting up network interfaces"
sudo ip link del "$TAP_DEV" 2> /dev/null || true
sudo ip tuntap add dev "$TAP_DEV" mode tap
sudo ip addr add "${TAP_IP}${MASK_SHORT}" dev "$TAP_DEV"
sudo ip link set dev "$TAP_DEV" up

# Setup ip forwarding
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
echo "Remove any old NAT rules"
sudo iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE || true
sudo iptables -D FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT || true
sudo iptables -D FORWARD -i tap0 -o eth0 -j ACCEPT || true

#echo "Insert rules to enable Internet access for the microVM"
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -I FORWARD 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -I FORWARD 1 -i tap0 -o eth0 -j ACCEPT

# Start Firecracker API server
#rm -f "$API_SOCKET"

sleep 0.015s

# Wait for API server to start
while [ ! -e "$API_SOCKET" ]; do
    echo "FC $SB_ID still not ready..."
    sleep 0.01s
done

curl_put '/machine-config' <<EOF
{
  "vcpu_count": 2,
  "mem_size_mib": 128,
  "cpu_template": "T2S"
}
EOF

curl_put '/boot-source' <<EOF
{
    "kernel_image_path": "${KERNEL}",
    "boot_args": "${KERNEL_BOOT_ARGS}"
}
EOF

curl_put '/drives/rootfs' <<EOF
{
    "drive_id": "rootfs",
    "path_on_host": "${ROOTFS}",
    "is_root_device": true,
    "is_read_only": false
}
EOF

curl_put '/logger' <<EOF
{
    "log_path": "${LOGFILE}",
    "level": "Debug",
    "show_level": true,
    "show_log_origin": true
}
EOF

curl_put '/network-interfaces/net1' <<EOF
{
  "iface_id": "net1",
  "guest_mac": "$FC_MAC",
  "host_dev_name": "$TAP_DEV"
}
EOF

# "version": "V1"
curl_put '/mmds/config' <<EOF
{
  "version": "V1",
  "network_interfaces": [
   "net0"
  ]
}
EOF

curl_put '/mmds' <<EOF
{
  "latest": {
    "meta-data": {
      "ami-id": "ami-87654321",
      "reservation-id": "r-79054aef"
    }
  }
}
EOF

sleep 0.015s

curl_put '/actions' <<EOF
{
    "action_type": "InstanceStart"
}
EOF
