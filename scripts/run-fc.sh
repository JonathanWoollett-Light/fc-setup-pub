#!/bin/bash -e
SB_ID="${1:-0}" # Default to sb_id=0

FC_BIN="/home/ec2-user/alsardan/src/firecracker/build/cargo_target/x86_64-unknown-linux-musl/debug/firecracker"
API_SOCKET="/home/ec2-user/alsardan/run/api.socket"

#metricsfile="$PWD/output/fc-sb${SB_ID}-metrics"
#metricsfile="/dev/null"

#rm -f $logfile $metricsfile
#touch $logfile $metricsfile

#FC_IP="172.16.0.2"
#TAP_IP="172.16.0.1"
#FC_MAC="02:FC:00:00:00:02"
#MASK_SHORT="/30"

#ip link del "$TAP_DEV" 2> /dev/null || true
#ip tuntap add dev "$TAP_DEV" mode tap
#ip addr add "${TAP_IP}${MASK_SHORT}" dev "$TAP_DEV"
#ip link set dev "$TAP_DEV" up

# Setup ip forwarding
#sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
#echo "Remove any old NAT rules"
#iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
#iptables -D FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#iptables -D FORWARD -i tap0 -o eth0 -j ACCEPT

#echo "Insert rules to enable Internet access for the microVM"
#sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#sudo iptables -I FORWARD 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#sudo iptables -I FORWARD 1 -i tap0 -o eth0 -j ACCEPT

# Start Firecracker API server
#rm -f "$API_SOCKET"

sudo setfacl -m u:${USER}:rw /dev/kvm
rm -f $API_SOCKET
$FC_BIN --api-sock "$API_SOCKET" --id "${SB_ID}" --no-seccomp
#screen -dmLS "fc-sb${SB_ID}" /usr/bin/env "/home/ec2-user/firecracker/build/cargo_target/x86_64-unknown-linux-musl/debug/firecracker" --api-sock "$API_SOCKET" --id "57b56f96-257a-4239-87ce-d149a221f962" --seccomp-level 0

