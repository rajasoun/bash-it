#!/usr/bin/env bash

function aws_vault_exec() {
  if ! which aws-vault >/dev/null; then
    echo You must have 'aws-vault' installed. See https://github.com/99designs/aws-vault/
    return 1
  fi
  local list=$(grep '^[[]profile' <~/.aws/config | awk '{print $2}' | sed 's/]$//')
  if [[ -z $list ]]; then
    echo You must have AWS roles and profiles set up to use this. See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-cli.html
    return 1
  fi
  local nlist=$(echo "$list" | nl)
  while [[ -z $AWS_PROFILE ]]; do
      local AWS_PROFILE=$(read -p "AWS profile? `echo $'\n\r'`$nlist `echo $'\n> '`" N; echo "$list" | sed -n ${N}p)
  done
  echo AWS Profile: $AWS_PROFILE. CTRL-D to exit.
  AWS_VAULT=
  aws-vault exec $AWS_PROFILE --no-session -- 
}

function choose_aws_profile() {
  if ! which aws-vault >/dev/null; then
    echo You must have 'aws-vault' installed. See https://github.com/99designs/aws-vault/
    return 1
  fi
  local list=$(grep '^[[]profile' <~/.aws/config | awk '{print $2}' | sed 's/]$//')
  if [[ -z $list ]]; then
    echo You must have AWS roles and profiles set up to use this. See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-cli.html
    return 1
  fi
  local nlist=$(echo "$list" | nl)
  while [[ -z $AWS_PROFILE ]]; do
      local AWS_PROFILE=$(read -p "AWS profile? `echo $'\n\r'`$nlist `echo $'\n> '`" N; echo "$list" | sed -n ${N}p)
  done
  export _AWS_PROFILE=$AWS_PROFILE 
  echo AWS Profile: $AWS_PROFILE. 
}
