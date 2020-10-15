#!/usr/bin/env bash


function set_registry(){
  opt="$1"
  type=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )

  case $type in
    aws)
      set_aws_ecr_registry
    ;;
    docker)
      set_docker_io_registry
    ;;
    *)
      raise_error "${RED}Invalid Registry Type${NC}"
    ;;
  esac
}

function set_aws_ecr_registry(){
  export AWS_VAULT_BACKEND="file"
  export "$(aws-vault exec cx-api  --no-session -- env | grep AWS | xargs)"
  AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity | jq '.Account' | tr -d '"' )
	REGISTRY_HOST_URL=${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com
}

function set_docker_io_registry(){
	# shellcheck disable=SC2034
	REGISTRY_HOST_URL=docker.io
}