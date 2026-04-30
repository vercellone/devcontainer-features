#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "version" sf version | grep '@salesforce/cli/'

# Report result
reportResults
