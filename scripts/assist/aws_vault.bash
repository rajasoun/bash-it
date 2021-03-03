#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

complete -C "$(command -v  aws_completer)" aws
eval "$(aws-vault --completion-script-bash)"

check_precondition aws-vault
check_precondition aws

opt="$1"
action=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )

case $action in
    setup)
      echo "${GREEN} aws-vault current setup ${NC}"
      aws-vault --backend=file list
      prompt_confirm "Do you want to continue with setup ?" && \
        choose_aws_profile && \
        echo "${GREEN}Setting up aws-vault for Profile : $_AWS_PROFILE ${NC}" && \
        aws-vault --backend=file add  "$_AWS_PROFILE"
      ;;
    check)
      echo "${GREEN} aws-vault current setup ${NC}"
      aws-vault --backend=file list
      prompt_confirm "Do you want to continue with aws-vault setup check ?" && \
        choose_aws_profile && \
        echo "${GREEN}Checking aws-vault for Profile : $_AWS_PROFILE ${NC}" && \
        aws-vault --backend=file exec $_AWS_PROFILE -- aws sts get-caller-identity
      ;;
    teardown)
      echo "${GREEN} aws-vault current setup ${NC}"
      aws-vault --backend=file list
      prompt_confirm "Do you want to continue with teardown ?" && \
        choose_aws_profile && \
        echo "${GREEN}Removing profile : $_AWS_PROFILE from aws-vault${NC}" && \
        aws-vault clear && \
        aws-vault --backend=file remove $_AWS_PROFILE
      ;;
    clean)
      clean_all
      ;;
    *)
      echo "${RED}Usage: ./assist <command>${NC}"
cat <<-EOF
Commands:
---------
  setup       -> Setup aws-vault 
  check       -> Check if aws-vault is correctly setup  
  teardown    -> Teardown aws-vault 
  clean       -> Clean Dangling and Tagged Docker Images
EOF
    ;;
esac
