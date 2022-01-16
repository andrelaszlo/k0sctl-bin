#!/usr/bin/env bash

set -euo pipefail

[ -n "${DEBUG-}" ] && set -x

export GH_REPO="k0sproject/k0sctl"

function check_cmd {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "Error: The $1 command is required to run this script."; exit 1; }
}

function download {
    download_command=""
    command -v "curl" >/dev/null 2>&1 && download_command="curl"
    if [ -z "$download_command" ]; then
        command -v "wget" >/dev/null 2>&1 && download_command="wget"
    fi

    if [ -z "$download_command" ]; then
        echo >&2 "Error: A download command needs to be installed (curl or wget)."
        exit 1
    fi

    if [ "$download_command" = "curl" ]; then
        curl "$1" --location --max-redirs 3 --silent --output "$2"
    else
        wget "$1" --quiet --output-document="$2"
    fi
}

check_cmd "gh"
check_cmd "jq"
check_cmd "awk"
check_cmd "sed"

tmp_dir=$(mktemp -d -t "k0sctl-bin-aur-update-XXXX")

release_metadata=$(gh release view --json assets,tagName)

checksum_url=$(echo "$release_metadata" | jq -r '.["assets"][] | select(.name == "checksums.txt").url')
[ -z "$checksum_url" ] && { echo >&2 "Error: Could not find checksums file."; exit 1; }

version=$(echo "$release_metadata" | jq -r '.tagName')
package_version="${version//v/}"

[ -z "$checksum_url" ] && { echo >&2 "Error: Could not find checksums file."; exit 1; }
checksums="${tmp_dir}/checksums.txt"
download "$checksum_url" "$checksums"
checksum=$(grep "\*k0sctl-linux-x64" "$checksums" | awk '{ print $1 }')
[ -z "$checksum" ] && { echo >&2 "Error: Could not find checksum in ${checksum_url}."; exit 1; }

echo "Checksum: ${checksum}"
echo "Version: ${version}"
echo "Package version: ${package_version}"

cp PKGBUILD_TEMPLATE PKGBUILD
sed -i "s/%PACKAGE_VERSION%/$package_version/g" PKGBUILD
sed -i "s/%CHECKSUM%/$checksum/g" PKGBUILD

rm -rf "$tmp_dir"


