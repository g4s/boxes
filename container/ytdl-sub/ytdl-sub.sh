#! /bin/bash

function main(){
    local baseimg="fedora"
    local origdocs="https://ytdl-sub.readthedocs.io"
    local repo_base="https://github.com/g4s/boxes/"
    local cnt_base="${repo_base}/container/ytdl-sub/"
    local cnt_docs="${cnt_base}Readme.md"

    local cnt=$(buildah from ${baseimg})
    local cnt_mnt=$(buildah mount ${cnt})

    buildah run "${cnt}" dnf update -y
    buildah run "${cnt}" dnf upgrade -y

    buildah run "${cnt}" dnf --no-docs install -y python3-pip
    buildah run "${cnt}" pip install ytdl-sub

    ## finalizing the container
    buildah config --label org.opencontainers.image.documentation="${cnt_docs}" "${cnt}"
    buildah config --label org.opencontainers.image.authors="${cntauthor}" "${cnt}"
    buildah config --label org.opencontainers.image.source="${cnt_base}"
    buildah config --annotation docs="https://ytdl-sub.readthedocs.io"

    buildah config --entrypoint "ytdl-sub sub /etc/ytdl-sub/subscriptions.yaml"

    buildah commit "${cnt}" localhost/ytdl-sub:latest
    }

# enter main-loop
while getopts a:t: opt; do
    case $opt in
        a) author="${OPTARG}"
        m) author_mail="${OPTARG}"
    esac
done
main