#! /bin/bash

function main(){
    local baseimg="fedora"
    local jellyroller_repo="https://github.com/LSchallot/JellyRoller.git"
    local gh_base="https://github.com/g4s/boxes/container/jellyroller"

    local containerdoku="${gh_base}/Readme.md"
    local cntname="jellyroller"
    local cntauthor="${author:-null}"
    local cntauthormail="${author_mail:-null}"
    local origdocs="https://github.com/LSchallot/JellyRoller"

    local basedir=${BASH_SOURCE}

    if [[ -n "${dnf_cache}" ]]; then
        if [[ -f "${basedir}/dnf_local.conf" ]];
          dnf_conf="${basedir}/dnf_local.conf"
        fi
    fi

    # creating base container
    local cnt=$(buildah from ${baseimg})
    local cnt_mnt=$(buildah mount ${cnt})

    # configure DNF for shared cache if possible
    if [[ -n "${dnf_cache}" ]]; then
        cp "${dnf_conf}" "${cnt_mnt}/etc/dnf/plugin/local.conf"
        buildah run "${cnt}" dnf --no-docs -y install python3-dnf-plugin-local
        buildah run "${cnt}" dnf -y clean all

        ln -s "${dnf_cache}" "${cnt_mnt}/${dnf_cache}"
    fi

    buildah run "${cnt}" dnf update -y
    buildah run "${cnt}" dnf upgrade -y

    # installing rust and cargo
    buildah run "${cnt}" dnf --no-docs -y install rust
    buildah run "${cnt}" dnf --no-docs -y install cargo

    # fetch jellyroller repo
    git init "${jellyroller_repo}" "${cnt_mnt}/opt/jellyroller"
    buildah run "${cnt}" "cd /opt/jellyroller && cargo build"
    buildah run "${cnt}" "ln -s /opt/jellyroller/jellyroller /usr/bin/jellyroller"

    ## finalizing container
    buildah config --label org.opencontainers.image.documenenntation="${containerdoku}" "${cnt}"
    buildah config --label org.opencontainers.image.authors="${cntauthot}" "${cnt}"
    buildah config --label org.opencontainers.image.source="${gh_base}"
    buildah config --annotation docs="${origdocs}" "${cnt}"
    
    buildah config --entrypoint "/bin/bash" "${cnt}"
    
    if [[ -n "${dnf_cache}" ]]; then
        rm -rf "${cnt_mnt}/{${dnf_cache}"

        buildah run "${cnt}" mkdir -p "${dnf_cache}"
        buildah config --volume "${dnf_cache}" "${cnt}"
    fi
}

## enter the script
while getopts a:t: opt; do
    case $opt in
        a) author="${OPTARG}";;
        c) dnf_cache="${OTARG}";;
        m) author_mail="${OPTARG}";;
        t) imagetag="${OPTARG}";;
        ?) help;;
        *) help;;
    esac
done
main