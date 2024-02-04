#! /usr/bin/bash
#
# -----
# @brief:   buildig a "distroless" oci-compliant container for mosquitto.
# @author:  Gregor A. Segner
# @license: BSD-3
# @repo:    https://github.com/g4s/boxes
# @issues:  https://github.com/g4s/boxes/issues
#

fedora_version="39"

image_author= "Gregor A. Segner <gregor.segner@gmail.com>"
image_title= "fedora-mqtt"
image_description= "simple Fedora v${fedora_version} based container with installe mosquitto"

if [[ $(command -v buildah) ]]; then
    container = $(buildah from scratch)
    containermnt = $(buildah mount ${container})

    if [[ $(commnd -v yum) ]]; then
        yum install -y --releasever=${fedora_version} --installroot=${containermnt} fedora-release-container
        yum install -y mosquitto
    fi

    # installing tailscale
    buildah run ${container} dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo -y
    buildah run ${contaienr} dnf install -y tailscale
    buildah run ${container} systemctl enable --now tailscale.service

    if [[ -z $TAILSCALE_AUTHKEY ]]; then
        echo "Found tailscale authorization key: container will be exposed to tailscale"
        buildah run ${container} tailscale up --authkey=${TALSCALE_AUTHKEY} --hostname="${CONTAINER_HOSTNAME:=mosquitto}"
    fi

    buildah config --entrypoint "/usr/sbin/mosquitto" ${container}
    buildah config --port 1883 ${container}
    buildah config --port 1884 ${container}
    buildah config --arch $(arch) ${container}
    buildah config --author "Gregor A. Segner" ${container}
    buildah config --hotname "${CONTAINER_HOSTNAME:=mosquitto}" ${container}
    buildah config --label org.opencontainers.image.authors="${image_author}" ${container}
    buildah oonfig --label org.opencontainers.image.title="${image_title}"
    buildah config --label org.opencontainers.image.description="${image_description}"

    # finalizing the container and submit to local registry
    buildah umount ${container}
    buildah commit ${container} ${image_title}
fi