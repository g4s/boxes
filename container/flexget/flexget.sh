#! /bin/bash

function help(){
    echo "this script is for building an oci container containing flexget"
    echo ""
    echo "flexget.sh [OPTION]"
    echo ""
    echo "OPTIONS:"
    echo "    -a <author>   the author of the container"
    echo "    -m <mail>     mail adress of the author"
    ehco "    -t version    the version of the fedora base image"
    echo "    -?            this help"
}


function main(){
    baseimg="fedora"

    containerdoku="https://github.com/g4s/boxes/container/flexget/Readme.md"
    cntauthor="${author:-null}"
    cntauthormail="${authormail:-null}"
    cntreg="https://ghcr.io/g4s"
    origdocs="https://flexget.com/Configuration"

    basedir=${BASH_SOURCE}

    conf="/etc/flexget/config.yml"
    log="/var/log/flexget.log"
    startpara="-c ${conf} -d --autoreload-config --logfile ${log}"

    cnt=$(buildah from ${basimg})
    cntmount=$(buildah mount ${cnt})

    # updating system and install prequesites
    buildah run "${cnt} dnf update -y && dnf upgrade -y"
    buildah run "${cnt} dnf install -y python3"
    buildah run "${cnt} dnf install -y python3-pip"

    # installing flexget with pip
    buildah run "${cnt} pip3 install flexget"
    buildah run "${cnt} mkdir /etc/flexget"

    fg_path=$(buildah run "{cnt} command -v flexget")

    ##
    # configure container
    buildah config --label org.opencontainers.image.documentation="${containerdoku}" ${cnt}
    buildah config --label org.opencontainers.image.authors="${cntauthor} <${cntauthormail}> ${cnt}"
    buildah config --label org.opencontainers.image.url="${cntreg}/flexget:latest"
    buildah config --label org.opencontainers.image.source="https://github.com/g4s/boxes/container/flexget"
    #buildah config --annotation requirements="${requirements}" ${cnt}
    buildah config --annotation docs="${origdocs}" ${cnt}

    buildah config --entrypoint "${fg_path} start ${startpara}" ${cnt}
}

## enter mainloop
while getopts a:t: opt; do
    case $opt in
        a) author="${OPTARG}";;
        m) author_mail="${OPTARG}";;
        t) imagetag="${OPTARG}";;
        ?) help;;
        *) help;;
    esac
done
main