# fc-dev-setup

Setup scripts for creating a firecracker dev environment on AL2 instances.

Contents of vscode-server should be copied to ~/.vscode-server after vscode-server is installed.

dev-setup.sh handles the rest of the setup.

To start a microVM run `run-fc.sh` then in a separate terminal run `start-fc.sh`.

These must be run from `/home/ec2-user` which must also bethe parent directory containing both the `fc-setu-pub` and `firecracker` directories.
