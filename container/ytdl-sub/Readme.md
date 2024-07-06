#ytdl-sub

This is a simple OCI-container for utilizing yt-dl

## continer build
It's highly recommended to use the pypyr-pipeline for
managing the container (building, deploying).

## container deploy
Deploying the container is simple as building. Also we will utilize
the pypyr-pipelin with an additional parameter:

```bash
pypyr ./build.yaml mode=deploy
```

The pipelie will also suiteable systemd units (a service and a timer).
The created an deployed container is designed to run as an oneshot command,
if you use it in conjunction with the provided systemd-timer, it's possible
to initiate a fresh jellyfin library scan.