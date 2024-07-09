#! /bin/bash

if [[ -f '/etc/ntp.conf']]; then
  grep "^pool" /etc/ntp.conf | cut -d ' ' -f 2 > ./ntp-server.tmp
fi