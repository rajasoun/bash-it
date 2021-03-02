#!/usr/bin/env bash

NC=$'\e[0m' # No Color

RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
LIGHT_BLUE=$'\e[94m'

BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'

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
  if ! [ -x "$(command -v "$command")" ]; then
    echo "${RED}Error: $command is not installed.${NC}" >&2
    exit 1
  fi
}

function init_make() {
  if [ ! -d "make" ]
  then
      echo "${GREEN}${BOLD}Initializing Make System${NC}"
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
  echo "${LIGHT_BLUE}${UNDERLINE}Directories With $file_name ${NC}"
  # shellcheck disable=SC2038
  basename "$(find . -type f -name "$file_name" | xargs -I {} dirname {} | sort | uniq)"
}

function select_dir_containing_file(){
  file_name=$1
  list_dirs_containing_file "$file_name"
  read -r -p "${BLUE} $file_name Directoris (choose from above) : ${NC}" FILE_DIR
  # shellcheck disable=SC2034
  IMAGE="$USER/$FILE_DIR"
}

function perform_docker_build_action(){
  action=$1
  select_dir_containing_file "Dockerfile"
  cd "$FILE_DIR" && make "$action" && cd - || return
}

#function set_registry(){
#  opt="$1"
#  type=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
#
#  case $type in
#    aws)
#      set_aws_ecr_registry
#    ;;
#    docker)
#      set_docker_io_registry
#    ;;
#    *)
#      raise_error "${RED}Invalid Registry Type${NC}"
#    ;;
#  esac
#}
#
#function set_aws_ecr_registry(){
#  export AWS_ACCOUNT_NUMBER=$(aws-vault exec cx-api --backend file --no-session -- aws sts get-caller-identity | jq '.Account' | tr -d '"' )
#  export $(aws-vault exec cx-api --backend file  --no-session -- env | grep AWS_REGION | xargs)
#	REGISTRY_HOST=${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com
#}
#
#function set_docker_io_registry(){
#	REGISTRY_HOST=docker.io
#}