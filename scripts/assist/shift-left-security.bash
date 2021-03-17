#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'


check_precondition docker
check_precondition awk

opt="$1"
action=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )

case $action in
    sast)
      docker run --rm -e "WORKSPACE=${PWD}" -v "$PWD:/app" shiftleft/sast-scan scan -t bash --build
      ;;
    clean)
      clean_all
      ;;
    *)
      echo "${RED}Usage: ./assist <command>${NC}"
cat <<-EOF
Commands:
---------
  sast        -> Static Application Security Testing - Source code with static analysis 
  clean       -> Clean Dangling and Tagged Docker Images
EOF
    ;;
esac
