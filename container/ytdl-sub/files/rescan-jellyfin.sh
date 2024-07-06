#! /binn/bash
#
# simple wrapper script, that initiate a library scan on  configured jellyfin
# instance. Can be called from systemd service-units as a ExecStop script

set -x

if [[ $(podman container exists jellyroller ) ]]; then
    podman exec jellyroller jellyroller scan-library
fi