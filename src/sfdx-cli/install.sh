#!/usr/bin/env bash
SFDX_ROOT=/usr/local/sfdx
SFDX_TAR=${URL:-"https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.gz"}
USERNAME="${_CONTAINER_USER:-"automatic"}"

echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

set -e

echo "Activating feature 'sfdx-cli'"

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

# Install curl, tar, git, other dependencies if missing
check_packages curl ca-certificates tar

# Create sfdx group to the user's UID or GID to change while still allowing access to sfdx
if ! cat /etc/group | grep -e "^sfdx:" > /dev/null 2>&1; then
    groupadd -r sfdx
fi
usermod -a -G sfdx ${USERNAME}

# See if we're on x86_64 and if so, install via apt-get, otherwise use pip3
echo "(*) Installing Salesforce CLI..."
echo "   from ${SFDX_TAR}"

mkdir -p ${SFDX_ROOT}
curl -fsSL -o /tmp/sfdx.tar.gz "${SFDX_TAR}"
tar -xzf /tmp/sfdx.tar.gz -C "${SFDX_ROOT}" --strip-components=1
rm -rf /tmp/sfdx.tar.gz
chown -R "${USERNAME}:sfdx" ${SFDX_ROOT}
chmod -R g+r+w ${SFDX_ROOT}
ls ${SFDX_ROOT}/bin -al
# curl -sL https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.gz | tar -xzC /usr/local 2>&1

PATH=/usr/local/sfdx/bin:$PATH
export PATH=$PATH
echo $PATH

sfdx version

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
