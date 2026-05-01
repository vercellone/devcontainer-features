#!/usr/bin/env bash
SF_ROOT=/usr/local/sf
VERSION="${VERSION:-"latest"}"
USERNAME="${_CONTAINER_USER:-"automatic"}"

set -e

echo "Activating feature 'sf-cli'"

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Install curl, tar, and other dependencies if missing
check_packages curl ca-certificates tar

# Detect architecture
ARCH=$(uname -m)
case "${ARCH}" in
    x86_64)  SF_ARCH="x64" ;;
    aarch64) SF_ARCH="arm64" ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

# Resolve the download URL from the Salesforce stable channel
SF_TAR="https://developer.salesforce.com/media/salesforce-cli/sf/channels/stable/sf-linux-${SF_ARCH}.tar.gz"

# Create sf group to the user's UID or GID to change while still allowing access to sf
if ! cat /etc/group | grep -e "^sf:" > /dev/null 2>&1; then
    groupadd -r sf
fi
usermod -a -G sf ${USERNAME}

echo "(*) Installing Salesforce sf CLI..."
echo "   architecture: ${ARCH} (${SF_ARCH})"
echo "   from ${SF_TAR}"

# Idempotent: remove any previous installation before extracting
rm -rf "${SF_ROOT}"
mkdir -p "${SF_ROOT}"

curl -fsSL -o /tmp/sf.tar.gz "${SF_TAR}"
tar -xzf /tmp/sf.tar.gz -C "${SF_ROOT}" --strip-components=1
rm -f /tmp/sf.tar.gz

chown -R "${USERNAME}:sf" "${SF_ROOT}"
chmod -R g+r+w "${SF_ROOT}"
PATH=/usr/local/sf/bin:$PATH

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
