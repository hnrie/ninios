#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="${ROOT_DIR}/packages"
DIST_DIR="${ROOT_DIR}/dist/packages"
WORK_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

mkdir -p "${DIST_DIR}"

for package_dir in "${PACKAGES_DIR}"/*; do
    if [[ ! -d "${package_dir}/debian" ]]; then
        continue
    fi

    package_name="$(basename "${package_dir}")"
    echo "Building ${package_name}"

    build_package_dir="${WORK_DIR}/${package_name}"
    cp -R "${package_dir}" "${build_package_dir}"
    find "${build_package_dir}" -type d -exec chmod 0755 {} +
    find "${build_package_dir}" -type f -exec chmod 0644 {} +
    chmod 0755 "${build_package_dir}/debian/rules"

    (
        cd "${build_package_dir}"
        dpkg-buildpackage -us -uc -b
    )

    find "${WORK_DIR}" -maxdepth 1 -type f \
        \( -name "${package_name}_*.deb" -o -name "${package_name}_*.buildinfo" -o -name "${package_name}_*.changes" \) \
        -exec mv -f {} "${DIST_DIR}/" \;
done

verify_apt_source_keyring() {
    local source_deb keyring_deb signed_by
    source_deb="$(find "${DIST_DIR}" -maxdepth 1 -name 'nonla-apt-source_*.deb' | head -n 1)"
    keyring_deb="$(find "${DIST_DIR}" -maxdepth 1 -name 'nonla-repo-keyring_*.deb' | head -n 1)"

    if [[ -z "${source_deb}" || -z "${keyring_deb}" ]]; then
        return 0
    fi

    signed_by="$(dpkg-deb --fsys-tarfile "${source_deb}" \
        | tar -xO ./etc/apt/sources.list.d/nonla.sources \
        | awk '/^Signed-By:/ {print $2}')"

    if [[ -z "${signed_by}" ]]; then
        echo "nonla-apt-source ships no Signed-By path" >&2
        exit 1
    fi

    # The APT entry is only trustworthy if nonla-repo-keyring actually installs
    # the keyring at the exact path referenced by Signed-By. A mismatch would
    # break "apt update" on every user machine, so fail the build here instead.
    if ! dpkg-deb -c "${keyring_deb}" | grep -q " \.${signed_by}$"; then
        echo "Signed-By path ${signed_by} is not shipped by nonla-repo-keyring" >&2
        exit 1
    fi

    echo "Verified Signed-By ${signed_by} is shipped by nonla-repo-keyring"
}

verify_apt_source_keyring

echo "Packages written to ${DIST_DIR}"
