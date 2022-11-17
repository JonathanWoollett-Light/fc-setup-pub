# fc-dev-setup

Setup scripts for creating a firecracker dev environment on AL2 instances.

Contents of vscode-server should be copied to ~/.vscode-server after vscode-server is installed.

dev-setup.sh handles the rest of the setup.

To start a microVM change
```
FC_BIN="/home/ec2-user/alsardan/bin/release-v1.1.1-x86_64/firecracker-v1.1.1-x86_64"
API_SOCKET="/home/ec2-user/alsardan/run/api.socket"
```
and
```
ROOTFS="/home/ec2-user/alsardan/rootfs/bionic.rootfs.ext4"
KERNEL="/home/ec2-user/alsardan/rootfs/vmlinux.bin"
```
then run `run-fc.sh` then `start-fc.sh`
