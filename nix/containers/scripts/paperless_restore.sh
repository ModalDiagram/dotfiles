# This script is just for reference and must be adapted
#
# 1)
# Login to container
sudo nixos-container root-login paperless
# Stop paperless service
systemctl stop paperless-web.service
# 2) Leave container and get snapshot
