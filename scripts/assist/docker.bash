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
      read -p "${BLUE} Type of Release ([minor,major,patch]) : ${NC}" RELEASE_TYPE
      perform_docker_build_action $RELEASE_TYPE-release
      ;;
    shell)
      select_dir_containing_file "Dockerfile"
      docker run --rm -it -v "${HOME}/.awsvault:/root/.awsvault" --entrypoint /bin/bash  "$IMAGE:latest"
      ;;
    run)
      select_dir_containing_file "Dockerfile"
      docker run --rm -it -v "${HOME}/.awsvault:/root/.awsvault" "${IMAGE}:latest" 
      ;;
    scan)
      docker run --rm -e "WORKSPACE=${PWD}" -v $PWD:/app shiftleft/sast-scan scan -t bash --build
      ;;
    clean)
      echo "${GREEN}Deleting .DS_Store, bash-it & make${NC}"
      rm -fr make bash-it reports
      find . -type f \( -name ".DS_Store" -o -name "._.DS_Store" \) -delete -print 2>&1 | grep -v "Permission denied"
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
  clean       -> Clean & Destroy VM
EOF
    ;;
esac
