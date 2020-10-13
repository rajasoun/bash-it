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
      echo "${GREEN}Setting up aws-vault for Profile : ${PROFILE}${NC}"
      aws-vault --backend=file add  "$PROFILE"
      export "$(aws-vault exec "$PROFILE" --no-session -- env | grep AWS | xargs)"
      ;;
    teardown)
      echo "${GREEN}Deleting up aws-vault for Profile : ${PROFILE}${NC}"
      aws-vault --backend=file remove  "$PROFILE"
      rm -fr  bash-it reports
      ;;
    get-value)
      read -r -p "${LIGHT_BLUE} Secrets Store Environment ([prod,non-prod]) : ${NC}" ENV_TYPE
      read -r -p "${LIGHT_BLUE} Deployment Environment ([qa,stage,prod]) : ${NC}" DEPLOYMENT_ENV_TYPE
      CLIENT_ID=$(secretcli get "$SECRET_STORE/$ENV_TYPE" "$NAME_PATTERN/$DEPLOYMENT_ENV_TYPE/client-id")
      CLIENT_SECRET=$(secretcli get "$SECRET_STORE/$ENV_TYPE" "$NAME_PATTERN/$DEPLOYMENT_ENV_TYPE/client-secret")
      echo "${LIGHT_BLUE} client-id: ${CLIENT_ID}   client-secert: ${CLIENT_SECRET}  ${NC}"
      ;;
    *)
      echo "${RED}Usage: ./assist <command>${NC}"
cat <<-EOF
Commands:
---------
  setup       -> Day-0 Setup for aws-vault and aws secrets manager
  teardown    -> Teardown aws-vault and aws secerts manager
EOF
    ;;
esac
