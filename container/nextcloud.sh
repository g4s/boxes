#! /bin/bash

tailscalerepo="https://pkgs.tailscale.com/stable/fedora/tailscale.repo"

function build_nc(){
    local nczipball="https://download.nextcloud.com/server/releases/latest.zip"

    mkdir ./tmp

    echo "will install now NextCloud with nginx support..."
    container=$(buildah from fedora)
    contaiermnt=$(buildah mount ${container})

    buildah run "${container} dnf update && dnf upgrade -y"

    # deploy tailscale if necessary
    # this is a messy solution and brakes the microservice principle
    if [[ "${enable_tailscale}" == "y" ]]; then
        echo "deploy tailscale overlay on NextCloud container..."
        buildah run "${container} dnf config-manager --add ${tailscalerepo}"
        buildah run "${container} dnf install -y tailscale"
        buildah run "${container} systemctl enable --now tailscaled"
        buildah run "${container} tailscale up --authkey=${tailscale_authkey}"

        tailscale_ipv4=$(buildah run ${container} tailscale ip -4)
        echo "you can reach container over tailscale now (IPv4: ${tailscale_ipv4})"
    fi

    # installing nginx
    buildah run "${container} dnf install -y nginx"

    # fetching nextcloud zipball and copy to container
    cd ./tmp
    curl -O ${nczipball}
    unzip latest.zip

    cp -R ./nextcloud ${contaiermnt}/var/www/

    # @ToDo reconfigure nginx.conf
    # @ToDo (re)configure nextcloud
}

function main(){
    read -p "should the installation support tailscale-VPN? [y/N]: " enable_tailscale
    enable_tailscale=${enable_tailscale:-N}
    if [[ "${enable_tailscale}" == "y" ]]; then
        read -p "please provide a tailscale auth-key: " tailscale_authkey
    fi
}