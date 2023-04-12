#!/usr/bin/env bash
SFDX_TAR_URL=${URL:-"https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.gz"}

set -e

echo "Activating feature 'sfdx-cli'"

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
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

# Install curl, tar, git, other dependencies if missing
check_packages curl ca-certificates gnupg2 tar

# architecture="$(uname -m)"
# case $architecture in
#     x86_64) architecture="amd64";;
#     aarch64 | armv8*) architecture="arm64";;
#     aarch32 | armv7* | armvhf*) architecture="armv6l";;
#     i?86) architecture="386";;
#     *) echo "(!) Architecture $architecture unsupported"; exit 1 ;;
# esac

# See if we're on x86_64 and if so, install via apt-get, otherwise use pip3
echo "(*) Installing Salesforce CLI..."
echo "   from ${SFDX_TAR_URL}"
mkdir -p /usr/local/sfdx
curl -fsSL -o /tmp/sfdx.tar.gz "${SFDX_TAR_URL}"
tar -xzf /tmp/sfdx.tar.gz -C "/usr/local/sfdx" --strip-components=1
rm -rf /tmp/sfdx.tar.gz
ls /usr/local/sfdx/bin -al
# chmod 0755 /usr/local/sfdx/bin/sf
# chmod 0755 /usr/local/sfdx/bin/sfdx
# curl -sL https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.gz | tar -xzC /usr/local 2>&1
export PATH=/usr/local/sfdx/bin:$PATH
PATH=/usr/local/sfdx/bin:$PATH

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
