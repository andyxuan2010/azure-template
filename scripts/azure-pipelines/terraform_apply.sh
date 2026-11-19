#!/usr/bin/env bash

set -euo pipefail

backend_resource_group_name="${1:?backend resource group name is required}"
backend_storage_account_name="${2:?backend storage account name is required}"
backend_container_name="${3:?backend container name is required}"
backend_key="${4:?backend key is required}"
plan_file="${5:?plan file path is required}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/terraform_common.sh"
configure_arm_auth

if [[ ! -f "${plan_file}" ]]; then
  echo "Terraform plan file not found: ${plan_file}" >&2
  exit 1
fi

terraform version
terraform_init_with_retry \
  -reconfigure \
  -input=false \
  -no-color \
  -backend-config="resource_group_name=${backend_resource_group_name}" \
  -backend-config="storage_account_name=${backend_storage_account_name}" \
  -backend-config="container_name=${backend_container_name}" \
  -backend-config="key=${backend_key}"
terraform apply -input=false -no-color -auto-approve "${plan_file}"
bash "${script_dir}/../terraform_change_summary.sh" "${plan_file}" "Terraform apply summary"
