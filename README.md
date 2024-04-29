<!--- 
    @author: Gregor A. Segner <gregor.segner@gmail.com>
    @license: BSD-3
--->

# Boxes
This repository contains various recipes for building OCI-compliant container 
with buildah or virtual machines with packer and a supportet hypervisor.

This means, that the hard dependencies are
  * Harshicorps [packer](https://www.packer.io)
  * [buildah](https://buildah.io)

## OCI-compliant container
All of this container can be deployed to an OCI-compliant container engine 
(e.g. docker, podman, cri-o,...) after building. The collection includes
at the moment the following services:
  * [adgurdhome](./container/adguardhome.sh)
  * [influxdb](./container/influxdb.sh)
  * [mowquitto MQTT broker](./container/mosquitt.sh)
  * [NextCloud](./container/nextcloud)

## virtual-machines with packer
  * [homecontrol](./packer/homecontrol/README.md) - a logic node for smarthomes on steroids