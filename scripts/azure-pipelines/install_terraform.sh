#!/usr/bin/env bash

set -euo pipefail

terraform_version="${1:?terraform version is required}"
if [[ ! "${terraform_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Terraform version must be a stable major.minor.patch release." >&2
  exit 1
fi
os="linux"
arch="$(uname -m)"
install_root="${AGENT_TEMPDIRECTORY:-${RUNNER_TEMP:-/tmp}}/terraform-bin"

case "${arch}" in
  x86_64)
    arch="amd64"
    ;;
  aarch64|arm64)
    arch="arm64"
    ;;
  *)
    echo "Unsupported architecture: ${arch}" >&2
    exit 1
    ;;
esac

temp_dir="$(mktemp -d)"
trap 'rm -rf "${temp_dir}"' EXIT

archive_name="terraform_${terraform_version}_${os}_${arch}.zip"
zip_path="${temp_dir}/${archive_name}"
release_url="https://releases.hashicorp.com/terraform/${terraform_version}"

mkdir -p "${install_root}"
curl --proto '=https' --tlsv1.2 -fsSL --retry 3 "${release_url}/${archive_name}" -o "${zip_path}"
curl --proto '=https' --tlsv1.2 -fsSL --retry 3 \
  "${release_url}/terraform_${terraform_version}_SHA256SUMS" -o "${temp_dir}/SHA256SUMS"
(
  cd "${temp_dir}"
  awk -v archive="${archive_name}" '$2 == archive { print }' SHA256SUMS > archive.sha256
  if [[ "$(wc -l < archive.sha256)" -ne 1 ]]; then
    echo "Expected exactly one checksum for ${archive_name}." >&2
    exit 1
  fi
  sha256sum --check --strict archive.sha256
)
unzip -oq "${zip_path}" -d "${temp_dir}"
install -m 0755 "${temp_dir}/terraform" "${install_root}/terraform"

echo "##vso[task.prependpath]${install_root}"

"${install_root}/terraform" version
