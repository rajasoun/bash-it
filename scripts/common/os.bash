#!/usr/bin/env bash

NC=$'\e[0m' # No Color
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'

# Checks if required env variables for instance is all set
function raise(){
  echo "${1}" >&2
}

function raise_error(){
  echo "${1}" >&2
  exit 1
}

function check_precondition() {
  command=$1
  if ! [ -x "$(command -v $command)" ]; then
    echo "${RED}Error: $command is not installed.${NC}" >&2
    exit 1
  fi
}

function init_make() {
  if [ ! -d "make" ]
  then
      echo "${GREEN}Initializing Make System${NC}"
      mkdir -p make
      if [ ! -d "make/Makefile" ]
      then
        wget -q -P make -O make/Makefile "https://raw.githubusercontent.com/mvanholsteijn/docker-makefile/master/Makefile"
      fi

      if [ ! -d ".make-release-support" ]
      then
        wget -q -P make -O make/.make-release-support "https://raw.githubusercontent.com/mvanholsteijn/docker-makefile/master/.make-release-support"
      fi
  fi
}

function list_dirs_containing_file(){
  file_name=$1
  echo "${BLUE} Directories With $file_name ${NC}"
  basename $(find . -type f -name "$file_name" | xargs dirname | sort | uniq)
}

function perform_docker_build_action(){
  action=$1
  list_dirs_containing_file "Dockerfile"
  read -p "${BLUE} Directory of the Dockerfile (choose from above) : ${NC}" DOCKER_FILE_DIR
  IMAGE="$USER/$DOCKER_FILE_DIR"
  cd $DOCKER_FILE_DIR && make $action && cd -
}