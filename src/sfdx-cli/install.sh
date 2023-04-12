#!/usr/bin/env bash
set -e

echo "Activating feature 'sfdx-cli'"

SFDX_TAR_URL=${URL:-"https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.gz"}

# See if we're on x86_64 and if so, install via apt-get, otherwise use pip3
echo "(*) Installing Salesforce CLI..."

curl -sL ${SFDX_TAR_URL} | tar -xzC /usr/local 2>&1
# curl -sL https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.gz | tar -xzC /usr/local 2>&1

export PATH=/usr/local/sfdx/bin:$PATH
PATH=/usr/local/sfdx/bin:$PATH

echo "Done!"
