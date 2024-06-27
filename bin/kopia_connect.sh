#!/usr/bin/env bash


runuser -u $USERNAME -- kopia repo connect server  --url=https://10.0.0.5:51515 --override-username=uploaders --override-hostname=containers --server-cert-fingerprint=ad802bc80288aa7a1df5d2f2a29a5196a09a6a57553192f7d556d70eb7e0bdc4
