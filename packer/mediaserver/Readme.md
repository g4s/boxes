# Mediaserver

This collection of files will create a fresh Fedora-based vm which will
represent a fully stacked media-server. It is easy to deploy and follows
all techniques used in the [boxes repo](https://github.com/g4s/boxes).

## Features
  - a nice and clean vm
    - all services are deployed as container with podman
      - jellyfin as the main and integral media component
      - a virtual DVR based on
        - flexget
        - ytdlp-sub
        - various custom scripts
      - jellyroller for jellyfin CLI management
    - a unified mediastorage
      - which also included user-home auto import
    - a system management dashboard with cockpit
    - automatic deploy to tailscale