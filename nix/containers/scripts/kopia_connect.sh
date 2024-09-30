#!/usr/bin/env bash


runuser -u $USERNAME -- kopia repo connect server  --url=https://kopia.sanfio.eu:51515 --override-username=uploaders --override-hostname=containers --server-cert-fingerprint=9ad3ed8ee24fa6b77030b95bc23ba4066519d4dff3449e097ab57af9f77583b6
