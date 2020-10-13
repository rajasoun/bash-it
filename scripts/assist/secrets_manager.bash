#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

complete -C "$(command -v  aws_completer)" aws
eval "$(aws-vault --completion-script-bash)"

check_precondition aws-vault
check_precondition aws
check_precondition secretcli

opt="$1"
action=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )

case $action in
    setup)
      echo "${GREEN}Setting up aws-vault for Profile : $_AWS_PROFILE ${NC}"
      aws-vault --backend=file add  "$_AWS_PROFILE"
      ;;
    test)
      echo "${GREEN}Test aws-vault for Profile : $_AWS_PROFILE ${NC}"
      aws-vault --backend=file list
      aws-vault --backend=file exec $_AWS_PROFILE -- aws s3 ls
      ;;
    teardown)
      echo "${GREEN}Deleting up aws-vault for Profile : $_AWS_PROFILE${NC}"
      aws-vault --backend=file remove  $_AWS_PROFILE
      ;;
    set-value) # For Debugging
      read -r -p "${LIGHT_BLUE} Secrets Store Environment ([prod,non-prod]) : ${NC}" ENV_TYPE
      read -r -p "${LIGHT_BLUE} Deployment Environment ([qa,stage,prod]) : ${NC}" DEPLOYMENT_ENV_TYPE

      #aws-vault --backend=file exec -- secretcli init "$_AWS_SECRET_STORE/$ENV_TYPE"
      aws-vault --backend=file exec $_AWS_PROFILE -- secretcli set "$_AWS_SECRET_STORE/$ENV_TYPE" "$_AWS_SECRET_STORE_NAME_PATTERN/$DEPLOYMENT_ENV_TYPE/client-id" -s
      aws-vault --backend=file exec $_AWS_PROFILE -- secretcli set "$_AWS_SECRET_STORE/$ENV_TYPE" "$_AWS_SECRET_STORE_NAME_PATTERN/$DEPLOYMENT_ENV_TYPE/client-secret" -s
      echo "${LIGHT_BLUE} client-id: ${CLIENT_ID}   client-secert: ${CLIENT_SECRET}  ${NC}"
      ;;
    get-value)  # For Debugging
      read -r -p "${LIGHT_BLUE} Secrets Store Environment ([prod,non-prod]) : ${NC}" ENV_TYPE
      read -r -p "${LIGHT_BLUE} Deployment Environment ([qa,stage,prod]) : ${NC}" DEPLOYMENT_ENV_TYPE

      read -r -p "${LIGHT_BLUE}${UNDERLINE} Get Value For Key ([client-id,client-secret]) : ${NC}" KEY
      echo "${GREEN}Getting value for Key : $_AWS_SECRET_STORE_NAME_PATTERN/$DEPLOYMENT_ENV_TYPE/client-secret"
      
      VALUE=$(aws-vault --backend=file exec $_AWS_PROFILE -- secretcli get "$_AWS_SECRET_STORE/$ENV_TYPE" "$_AWS_SECRET_STORE_NAME_PATTERN/$DEPLOYMENT_ENV_TYPE/$KEY" | tr -d "")
      echo "${LIGHT_BLUE} $KEY -> $VALUE ${NC}"
      ;;
    clean)
      rm -fr  bash-it reports
      ;;
    *)
      echo "${RED}Usage: ./assist <command>${NC}"
cat <<-EOF
Commands:
---------
  setup       -> Day-0 Setup for aws-vault and aws secrets manager
  test        -> Test the setup
  teardown    -> Teardown aws-vault and aws secerts manager
  clean       -> Remove bash-it
EOF
    ;;
esac
