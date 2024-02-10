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
image_title= "fedora-influxdb"
image_description= "simple Fedora v${fedora_version} based container with installed influxdb"

declare -a container_ports=(8086 8088)

if [[ comand -v buildah ]]; then
    container = $(buildah from scratch)
    containermnt = $(buildah mount ${container})

    if [[ $(commnd -v yum) ]]; then
        yum install -y --releasever=${fedora_version} --installroot=${containermnt} fedora-release-container
    fi

    tee ${containermnt}/etc/yum.repos.d/influxdb.repo<<EOF
    [influxdb]
    name = InfluxDB Repository - RHEL
    basurl = https://repos.influxdata.com/rhel/8/x86_64/stable/
    enabled = 1
    gpgcheck = 1
    gpgkey = https://repos.influxdata.com/influxdata-archive_compat.key
    EOF

    buildah run ${container} dnf update -y
    buildah run ${container} dnf install -y influxdb2

    # defining entry point
    buildah config --entrypoint "/usr/sbin/influxdb2" ${container}

    # defining portforwards
    for port in container_ports; do
        buildah config --port ${port} ${container}
    done

    buildah config --author "Gregor A. Segner" ${container}
    buildah config --hotname "${CONTAINER_HOSTNAME:=influx}" ${container}
    buildah config --label org.opencontainers.image.authors="${image_author}" ${container}
    buildah oonfig --label org.opencontainers.image.title="${image_title}"
    buildah config --label org.opencontainers.image.description="${image_description}"

    # finalizing the container and submit to local registry
    buildah umount ${container}
    buildah commit ${container} ${image_title}
fi