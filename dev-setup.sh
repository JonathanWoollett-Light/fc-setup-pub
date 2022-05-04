#!/bin/bash

sudo yum install -y git docker

sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo systemctl enable docker

mkdir -p /home/ec2-user/alsardan/src
mkdir -p /home/ec2-user/alsardan/run
mkdir -p /home/ec2-user/alsardan/rootfs
mkdir -p /home/ec2-user/alsardan/src/scripts

mv scripts/*-fc.sh /home/ec2-user/alsardan/src/scripts/

git clone https://github.com/firecracker-microvm/firecracker.git /home/ec2-user/alsardan/src/firecracker 
mkdir -p /home/ec2-user/alsardan/src/firecracker/.vscode
cp vscode/firecracker/* /home/ec2-user/alsardan/src/firecracker/.vscode

cd /home/ec2-user/alsardan/rootfs
wget https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/x86_64/kernels/vmlinux.bin
wget https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/x86_64/rootfs/bionic.rootfs.ext4

cd ~
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
sh rustup.sh -y
source $HOME/.cargo/env
