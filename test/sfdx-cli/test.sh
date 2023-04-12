#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "version" bash -c "sfdx version | grep 'sfdx-cli/'"

# Report result
reportResults
