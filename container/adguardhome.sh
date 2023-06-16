#! /usr/bin/bash
#
# -----
# @brief:   buildig a "distroless" oci-compliant container for adguard Home.
# @author:  Gregor A. Segner
# @license: BSD-3
# @repo:    https://github.com/g4s/boxes
# @issues:  https://github.com/g4s/boxes/issues
#
# last modification: 2023-06-16
# -----
#
# -----
# Additional bash libs required:
#   * g4s/collecction/nix/lib/system.sh
#   * g4s/collecction/nix/lib/container.sh
# 
# You should ensure, that the required bash-libs are present on your system
# and can be refferenced in this script. By default this script will check
# '$HOME/.local/share/bash-lib/' for the needed scripts. 
# -----
#
# If you use this container, you should mount some volumes like the config-file

## check if advancedLogger function (part of system.sh) is present
#  if necessary source system.sh
if ! [[ type advancedLogger &> /dev/null ]]; then
	>&2 echo "could not find function advanced Logger"

	if [[ -e $HOME + '/.local/share/bash-lib/system.h' ]]; then
		source $HOME + '/.local/share/bash-lib/system.h'
	else
		>&2 echo 'could not load system.sh'
		exit 1
fi

## loading container-lib
if ! [[ -f $HOME + '.local/share/bash-lib/container.sh' ]]; then
	declare -g containerLib=""
else
	declare -g containerLib=$HOME + '.local/share/bash-lib/container.sh'
fi
source ${containerLib}

## defining some global variables
debug=true
logging=true

repo="AdGuardTeam/AdGuardHome"
arch="amd64"
package=""

###################
# cleanup() will do all the cleanup stuff at the end
#
# Globals:
#	None
#
# Arguments:
#	None
#
# Outputs:
# 	None
#
# Returns:
#	None
function cleanup () {
	advancedLogger "start cleanup process"

	if [[ -e ${package} ]]; then
		$(command -v rm) /tmp/${package}
	fi
}


###################
# trap helper function, if SIGINT is received
# ctrl_c will initiate the cleanup process
#
# Globals:
# 	package
#
# Arguments:
# 	None
#
# Outputs:
# 	None
#
# Returns:
#	None
function ctrl_c () {
	advancedLogger "received SIGING (ctrl-c)..."
	cleanup
	exit 0
}


###################
function makeDistroless () {
	removeSmylinks="find /sbin /bin /usr/bin /usr/local/bin -type 1 -exec rm -rf {} \;; \\"
	buildah run ${1} ${removeSmylinks}
	buildah run ${1} busybox rm /sbin/apk /bin/busybox
}


## defining traps
trap "echo '[ERROR] An error occured during excution. For detailed information consult ${logfile}' >&3" ERR
trap ctrl_c INT


if [[ command -v buildah]]; then
	advancedLogger "starting build-process in rootless mode on host arch $(getHostArch)"
	advancedLogger "buildhost is: $(hostname --fqdn)"
	advancedLogger "user for building is: ${USER}"
	advancedLogger "contaienr arch will be ${arch}"
	# enable building in rootless mode
	buildah unshare

	advancedLogger "building container from latest alpine container"
	container=$(buildah from alpine:latest)
	containermnnt=$(buildah mount ${container})

	# fetch latest x86_64 adGuard Home archive from GitHub
	latestRelease=$(getGitHubRelease ${repo})
	package="AdGuardHome_linux_${arch}.tar.gz"
	dlurl="https://github.com/${repo}/releases/download/${latestRelease}/${package}"

	debug=false
	advancedLogger "file" "retrieve download URL for adGuard Home -> ${dlurl}"
	debug=true

	advancedLogger "fetching latest adGuard Home release (${latestRelease}) for arch ${arch}"
	curl ${dlurl} --output "/tmp/${package}"

	# extracting AdGuard Home to container
	advancedLogger "extracting relese to container"
	tar xf "/tmp/${package}" -C "${containermnnt}/opt/"
	chmod +x "${containermnnt}/opt/AdGuardHome/AdGuardHome"

	## defining some meta information on container
	adguardparam="--config /etc/AdGuardHome/adguardhome.yml"
	adguardparam+=" --service start"
	adguardparam+=" --no-check-update"
	buildah config --entrypoint "/opt/AdGuard/AdGuardHome ${adguardparam}"

	# finally we will enter the last step - cleanup
	# 	* make container distroless 
	# 	* remove unnecessarc build artefacts
	makeDistroless ${container}
	buildah umount ${container}
	cleanup
fi