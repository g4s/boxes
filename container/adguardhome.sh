#! /usr/bin/bash
#
# -----
# @brief:   buildig a "distroless" oci-compliant container for adguard Home.
# @author:  Gregor A. Segner
# @license: BSD-3
# @repo:    https://github.com/g4s/boxes
# @issues:  https://github.com/g4s/boxes/issues
#
# last modification: 2023-06-15
# -----

function getGitHubRelease () {
	echo=$(curl -sL "https://api.github.com/repos/${1}/releases/latest" | jq -r ".tag_name")
}

if [[ command -v buildah]]; then
	buildah unshare

	# create container from latest alpine image
	container=$(buildah from alpine:latest)
	containermnnt=$(buildah mount ${container})

	# fetch latest x86_64 adGuard Home archive from GitHub
	arch="amd64"
	repo="AdGuardTeam/AdGuardHome"
	latestRelease=$(getGitHubRelease ${repo})
	package="AdGuardHome_linux_${arch}.tar.gz"
	ghbaseurl="https://github.com/${repo}/releases/download/${latestRelease}/${package}"

	curl ${dlurl} --output "/tmp/${package}"

	# extracting AdGuard Home to container
	tar xf "/tmp/${package}" -C "${containermnnt}/opt/"
	chmod +x "${containermnnt}/opt/AdGuardHome/AdGuardHome"

	## defining some meta information on container
	adguardparam="--config /etc/AdGuardHome/adguardhome.yml"
	adguardparam+=" --service start"
	adguardparam+=" --no-check-update"
	buildah config --entrypoint "/opt/AdGuard/AdGuardHome --config /etc/AdGuardHome/adguardhome.yml --service start"

	# cleanup process - also make cleanup container fro busybox
	removeSmylinks="find /sbin /bin /usr/bin /usr/local/bin -type 1 -exec rm -rf {} \;; \\"
	buildah run ${container} ${removeSmylinks}
	buildah run ${container} busybox rm /sbin/apk /bin/busybox

	rm "/tmp/${package}"
fi