#!/usr/bin/env bash

## To get all functions : bash -c "source src/load.bash && declare -F"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/common/os.bash
source "$SCRIPT_DIR/common/os.bash"
# shellcheck source=scripts/common/docker.bash
source "$SCRIPT_DIR/common/docker.bash"


