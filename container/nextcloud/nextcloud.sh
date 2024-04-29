#! /bin/bash
# -----
# @brief:   build and optional deploy a NextCloud container based installation
# @author:  Gregor A. Segner
# @license: BSD-3
# @repo:    https://github.com/g4s/boxes
# @issues:  https://github.com/g4s/boxes/issues
#
# last modification: 2024-04-29
# -----
#
# @description:
#   This script can build a plenty of container for running a fully configured
#   NextCloud installation. Also it's possible to configure tailscale as a
#   VPN solution and teleport as a zero-trust access control.
#   
#   There are two big options if you run this script: the first one is to only
#   build necessary container for NextClould with the help of buildah. The
#   second one is to deploy this container on the build-host with the help
#   of podman.
#
# ATTENTION: DO NOT USE THIS SCRIPT AT THE MOMENT - STILL DRAFT!!!

function build_nc(){
    local nczipball="https://download.nextcloud.com/server/releases/latest.zip"

    echo "will install now NextCloud with nginx support..."
    container=$(buildah from fedora)
    contaiermnt=$(buildah mount ${container})

    buildah run "${container} dnf update && dnf upgrade -y"

    # installing nginx
    buildah run "${container} dnf install -y nginx"

    # fetching nextcloud zipball and copy to container
    cd ./tmp
    curl -O ${nczipball}
    unzip latest.zip

    cp -R ./nextcloud ${contaiermnt}/var/www/

    cd ..

    # @ToDo reconfigure nginx.conf
    # @ToDo (re)configure nextcloud
}

function main(){
    # defining some local functions
    function pckg_manager(){
        if [[ $(command -v dnf) ]]; then
            echo "dnf"
        fi

        if [[ $(command -v apt-get) ]]; then
            echo "apt"
        fi
    }

    function checkinst_buildah(){
        if [[ ! $(command -v buildah) ]]; then
            echo "could not find buildah on host - will install buildah..."
            case $(pckg_manager) in
                dnf )
                    sudo dnf install -y buildah
                apt )
                    sudo apt-get install -y buildah
            esac
        fi
        echo "found buildah on system..."
    }

    function deploy_container(){
        if [[ ! $(command -v podman) ]]; then
            echo "could not find podman - will install on host..."
            case $(pckg_manager) in
                dnf )
                    sudo dnf install -y podman
                apt )
                    sudo apt-get install -y podman
            esac
        fi

        # start the container 
        podman run postgresql
        podman run nextcloud

        configer_remote
    }

    function configer_remote(){
        local tailscalerepo="https://pkgs.tailscale.com/stable/fedora/tailscale.repo"
        local teleportinstaller="https://goteleport.com/static/install.sh"
        local teleportversion="15.2.2"
        local teleportedition="oss"

        while true; do
            read -p "should tailscale VPN configured on this host? [y/N] " enable_tailscale
            case $enable_tailscale in
                [yY] )
                    read -p "please provide the tailscale auth-key: " tailscale_authkey
                    sudo dnf config-manager --add ${tailscalerepo}
                    sudo dnf install -y tailscale
                    sudo systemctl enable --now tailscaled
                    sudo tailscale up --authkey=${tailscale_authkey}
                    break;;
                [nN] )
                    break;;
            esac
        done

        while true; do
            read -p "should teleport zero-trust access configured on this host? [y/N] " enable_teleport
            case $enable_teleport in
                [yY] )
                    sudo curl ${teleportinstaller} | bash -s ${teleportversion} ${teleportedition}
                    sudo systemctl enable --now teleport
                    break;;
                [nN] )
                    break;;
            esac
        done
    }

    # let's check if we can build container images on this host
    checkinst_buildah

    mkdir ./tmp

    build_nc

    # ask if container should be deployed on the same host
    while true; do
        read -p "do you want deploy the created container on this host? [y/N]: " local_deploy
        case $local_deploy in
            [yY] )
                deploy_container
                break;;
            [nN] )
                break;;
        esac
    done

    rm -rf ./tmp
}