#!/bin/bash
if [ "$1" == "patch" ]; then
  patch cfs_checksum_vuln/cFS/apps/CS/fsw/src/cs_compute.c checksum_app.patch
elif [ "$1" = "vuln" ]; then
  patch -R cfs_checksum_vuln/cFS/apps/CS/fsw/src/cs_compute.c checksum_app.patch
fi
