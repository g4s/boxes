#! /bin/bash

if [[ -f '/etc/ntp.conf']]; then
  rm -rf ./ntp-server.tmp
  grep "^pool" /etc/ntp.conf | cut -d ' ' -f 2 > ./ntp-server.tmp
fi