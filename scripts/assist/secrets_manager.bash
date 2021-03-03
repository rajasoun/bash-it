#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

complete -C "$(command -v  aws_completer)" aws
eval "$(aws-vault --completion-script-bash)"

check_precondition aws-vault
check_precondition aws
check_precondition secretcli

function _play_secret_store(){
  action=$( tr '[:upper:]' '[:lower:]' <<<"$3" )
  case $action in
  setup)
    read -r -p "${LIGHT_BLUE} Secrets Store Environment ([prod,non-prod]) : ${NC}" ENV_TYPE
    echo "${GREEN}Setup Secret Store : $_AWS_SECRET_STORE/$ENV_TYPE ${NC}"
    aws-vault --backend=file exec $_AWS_PROFILE -- secretcli init "$_AWS_SECRET_STORE/$ENV_TYPE" -d "Secret Store For : $_AWS_SECRET_STORE/$ENV_TYPE"
    ;;
  set-value) # For Debugging
    read -r -p "${LIGHT_BLUE} Secrets Store Environment ([prod,non-prod]) : ${NC}" ENV_TYPE
    read -r -p "${LIGHT_BLUE} Deployment Environment ([qa,stage,prod]) : ${NC}" DEPLOYMENT_ENV_TYPE

    aws-vault --backend=file exec $_AWS_PROFILE -- secretcli set "$_AWS_SECRET_STORE/$ENV_TYPE" "$_AWS_SECRET_STORE_NAME_PATTERN/$DEPLOYMENT_ENV_TYPE/client-id" -s
    aws-vault --backend=file exec $_AWS_PROFILE -- secretcli set "$_AWS_SECRET_STORE/$ENV_TYPE" "$_AWS_SECRET_STORE_NAME_PATTERN/$DEPLOYMENT_ENV_TYPE/client-secret" -s
    echo "${LIGHT_BLUE} client-id: ${CLIENT_ID}   client-secert: ${CLIENT_SECRET}  ${NC}"
    ;;
  get-value)  # For Debugging
    read -r -p "${LIGHT_BLUE} Secrets Store Environment ([prod,non-prod]) : ${NC}" ENV_TYPE
    read -r -p "${LIGHT_BLUE} Deployment Environment ([qa,stage,prod]) : ${NC}" DEPLOYMENT_ENV_TYPE

    read -r -p "${LIGHT_BLUE}${UNDERLINE} Get Value For Key ([client-id,client-secret]) : ${NC}" KEY
    echo "${GREEN}Getting value for Key : $_AWS_SECRET_STORE_NAME_PATTERN/$DEPLOYMENT_ENV_TYPE/$KEY From $_AWS_SECRET_STORE/$ENV_TYPE ${NC}"
    
    VALUE=$(aws-vault --backend=file exec $_AWS_PROFILE -- secretcli get "$_AWS_SECRET_STORE/$ENV_TYPE" "$_AWS_SECRET_STORE_NAME_PATTERN/$DEPLOYMENT_ENV_TYPE/$KEY" | tr -d "")
    echo "${LIGHT_BLUE} $KEY -> $VALUE ${NC}"
    ;;
  teardown)
    read -r -p "${LIGHT_BLUE} Secrets Store Environment ([prod,non-prod]) : ${NC}" ENV_TYPE
    echo "${GREEN}Teardown Secret Store : $_AWS_SECRET_STORE/$ENV_TYPE ${NC}"
    aws-vault --backend=file exec $_AWS_PROFILE -- aws secretsmanager delete-secret --secret-id $_AWS_SECRET_STORE/$ENV_TYPE --force-delete-without-recovery
    ;;
    *)
    cat <<-EOF
Play  commands:
----------------
  setup     -> Setup AWS secrets store
  set-value -> Set [Key,Value] for client-id and client-secrets
  get-value -> Get Value for Key    
  teardown  -> Tewardown AWS secrets store                           
EOF
    ;;
  esac
}

opt="$1"
action=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )

case $action in
    setup)
      echo "${GREEN} aws-vault current setup ${NC}"
      aws-vault --backend=file list
      prompt_confirm "Do you want to continue with setup ?" && choose_aws_profile
      echo "${GREEN}Setting up aws-vault for Profile : $_AWS_PROFILE ${NC}"
      aws-vault --backend=file add  "$_AWS_PROFILE"
      ;;
    check)
      echo "${GREEN} aws-vault current setup ${NC}"
      aws-vault --backend=file list
      prompt_confirm "Do you want to continue with aws-vault setup check ?" && \
        echo "${GREEN}Checking aws-vault for Profile : $_AWS_PROFILE ${NC}" && \
        aws-vault --backend=file exec $_AWS_PROFILE -- aws sts get-caller-identity
      ;;
    play)
      _play_secret_store "$@" 
      ;;
    teardown)
      echo "${GREEN} aws-vault current setup ${NC}"
      aws-vault --backend=file list
      prompt_confirm "Do you want to continue with teardown ?" && choose_aws_profile
      echo "${GREEN}Removing profile : $_AWS_PROFILE from aws-vault${NC}"
      aws-vault --backend=file remove  $_AWS_PROFILE
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
  play        -> Setup AWS Secrets Store, Put value, Get Value and Teardown using secretcli Library
EOF
    ;;
esac
