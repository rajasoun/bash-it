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

function prompt_confirm(){
    # call with a prompt string or use a default
    local response msg="${1:-Do you want to continue} (y/[n])? "; shift
    read -r $* -p "$msg" response || echo
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Replace a line of text that matches the given regular expression in a file with the given replacement.
# Only works for single-line replacements.
function file_replace_text {
  local -r original_text_regex="$1"
  local -r replacement_text="$2"
  local -r file="$3"

  local args=()
  args+=("-i")

  if os_is_darwin; then
    # OS X requires an extra argument for the -i flag (which we set to empty string) which Linux does no:
    # https://stackoverflow.com/a/2321958/483528
    args+=("")
  fi

  args+=("s|$original_text_regex|$replacement_text|")
  args+=("$file")

  sed "${args[@]}" > /dev/null
}

# Returns true (0) if this is an OS X server or false (1) otherwise.
function os_is_darwin {
  [[ $(uname -s) == "Darwin" ]]
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
        file_replace_text "bumped to version" "build(release-image): bumped to version" "make/Makefile"
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
  find . -type f -name "$file_name" | xargs -I {} dirname {} | xargs -I {} basename {} | sort | uniq
}

function select_dir_containing_file(){
  file_name=$1
  list_dirs_containing_file "$file_name"
  read -r -p "${BLUE} $file_name Directoris (choose from above) : ${NC}" FILE_DIR
  # shellcheck disable=SC2034
  IMAGE="$USER/$FILE_DIR"
}

function clean_all(){
  echo "${GREEN}Deleting .DS_Store, bash-it & make${NC}"
  rm -fr make bash-it reports
  find . -type f \( -name ".DS_Store" -o -name "._.DS_Store" \) -delete -print 2>&1 | grep -v "Permission denied"
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