#!/usr/bin/env bash

set -euo pipefail

configure_terraform_ci() {
  export TF_IN_AUTOMATION=true
  export TF_INPUT=0
  export CHECKPOINT_DISABLE=true
  export GIT_TERMINAL_PROMPT=0
}

configure_azure_devops_git_auth() {
  if [[ -n "${SYSTEM_ACCESSTOKEN:-}" ]]; then
    git config --global http.https://dev.azure.com/.extraheader "AUTHORIZATION: bearer ${SYSTEM_ACCESSTOKEN}"
  fi
}

create_temp_tf_data_dir() {
  export TF_DATA_DIR
  TF_DATA_DIR="$(mktemp -d)"

  cleanup_tf_data_dir() {
    rm -rf "${TF_DATA_DIR}"
  }

  trap cleanup_tf_data_dir EXIT
}

terraform_init_with_retry() {
  local max_attempts="${TERRAFORM_INIT_MAX_ATTEMPTS:-4}"
  local delay_seconds="${TERRAFORM_INIT_RETRY_DELAY_SECONDS:-20}"
  local attempt=1

  while true; do
    echo "Running terraform init, attempt ${attempt}/${max_attempts}"
    if terraform init "$@"; then
      return 0
    fi

    if (( attempt >= max_attempts )); then
      echo "terraform init failed after ${max_attempts} attempts." >&2
      return 1
    fi

    echo "terraform init failed; retrying in ${delay_seconds}s."
    sleep "${delay_seconds}"
    attempt=$((attempt + 1))
  done
}

terraform_with_retry() {
  local max_attempts="${TERRAFORM_OPERATION_MAX_ATTEMPTS:-3}"
  local delay_seconds="${TERRAFORM_OPERATION_RETRY_DELAY_SECONDS:-30}"
  local attempt=1

  while true; do
    echo "Running terraform $1, attempt ${attempt}/${max_attempts}"
    if terraform "$@"; then
      return 0
    fi

    if (( attempt >= max_attempts )); then
      echo "terraform $1 failed after ${max_attempts} attempts." >&2
      return 1
    fi

    echo "terraform $1 failed; retrying in ${delay_seconds}s."
    sleep "${delay_seconds}"
    attempt=$((attempt + 1))
  done
}

configure_arm_auth() {
  export ARM_CLIENT_ID="${servicePrincipalId:?servicePrincipalId is required}"
  export ARM_TENANT_ID="${tenantId:?tenantId is required}"
  export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

  if [[ -n "${servicePrincipalKey:-}" ]]; then
    export ARM_CLIENT_SECRET="${servicePrincipalKey}"
  fi

  if [[ -n "${idToken:-}" ]]; then
    export ARM_USE_OIDC=true
    export ARM_OIDC_TOKEN="${idToken}"
  fi

  if [[ -n "${AZURESUBSCRIPTION_SERVICE_CONNECTION_ID:-}" ]]; then
    export ARM_OIDC_AZURE_SERVICE_CONNECTION_ID="${AZURESUBSCRIPTION_SERVICE_CONNECTION_ID}"
  fi
}

configure_terraform_ci
configure_azure_devops_git_auth
