#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

if [ ! -d "make" ]; then
  check_precondition docker
  check_precondition make
  check_precondition awk
  init_make
fi 

opt="$1"
action=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )

case $action in
    build)
      perform_docker_build_action build
      ;;
    release)
      read -r -p "${BLUE} Type of Release ([minor,major,patch]) : ${NC}" RELEASE_TYPE
      perform_docker_build_action "$RELEASE_TYPE-release"
      ;;
    shell)
      select_dir_containing_file "Dockerfile"
      docker run --rm -it \
            -v "${HOME}/.awsvault:/root/.awsvault" \
            -v "${HOME}/.aws:/root/.aws" \
            --entrypoint /bin/bash  "$IMAGE:latest"
      ;;
    run)
      select_dir_containing_file "Dockerfile"
      docker run --rm -it \
            -v "${HOME}/.awsvault:/root/.awsvault" \
            -v "${HOME}/.aws:/root/.aws" \
            "${IMAGE}:latest" 
      ;;
    scan)
      docker run --rm -e "WORKSPACE=${PWD}" -v "$PWD:/app" shiftleft/sast-scan scan -t bash --build
      ;;
    clean)
      clean_all
      docker_clean
      perform_docker_build_action clean
      ;;
    *)
      echo "${RED}Usage: ./assist <command>${NC}"
cat <<-EOF
Commands:
---------
  build       -> Build Docker Image
  release     -> Release Docker Image to Docker Hub
  shell       -> Shell into Container
  run         -> Run the Container
  scan        -> Source code with static analysis 
  clean       -> Clean Dangling and Tagged Docker Images
EOF
    ;;
esac
