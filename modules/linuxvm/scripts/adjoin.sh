#!/bin/bash
. /etc/os-release
echo "OS: $ID"

set -e

# ---------------------------
# Check for Required Arguments
# ---------------------------
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <env> <ssh_access_groups> <admin_access_groups>"
  echo "Example: $0 'dev' 'linux-ssh-users ad-ssh' 'linux-admins ad-sudoers'"
  exit 1
fi

ENV=$1          # e.g. 'nonprod', 'sbx', 'prod'
SSH_ACCESS_GROUPS=$2   # e.g. 'linux-ssh-users ad-ssh'
ADMIN_ACCESS_GROUPS=$3 # e.g. 'linux-admins ad-sudoers'

# ---------------------------
# Configuration
# ---------------------------
DOMAIN="2join.us"
KEYVAULT_NAME="kv-ccoe-cc-${ENV}"
USERNAME="b1001332a1"
SECRET_PASSWORD="domain-join-password"
AD_DNS="10.0.0.4" # Replace with your AD DNS server
HOSTNAME_PREFIX="ubuntu-vm"
NEW_HOSTNAME="${HOSTNAME_PREFIX}-$(date +%s)"


install_packages() {
    local max_attempts="$1"
    shift
    local package_names="$@"
    local attempt_num=1
    local success=false

    while [ "$success" = false ] && [ "$attempt_num" -le "$max_attempts" ]; do
        echo "Try to install for $package_names"
        if [ "$ID" = "ubuntu" ]; then
            DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install "$@" > /dev/null
        else
            yum -y install "$@" > /dev/null
        fi
        # Check the exit code of the command
        if [ $? -eq 0 ]; then
            echo "Install for $package_names succeeded"
            success=true
        else
            echo "Attempt $attempt_num for $package_names failed. Sleeping for 3 seconds and trying again..."
            sleep 3
            ((attempt_num++))
        fi
    done
}


# Wait until cloud-init finishes
echo "[+] Waiting for cloud-init to finish..."
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo "Waiting 5seconds for cloud-init to finish..."
    sleep 5
done
echo "[+] cloud-init has finish..."

# ---------------------------
# Install Required Packages
# ---------------------------
# echo "[+] Installing packages..."
# apt update
# DEBIAN_FRONTEND=noninteractive apt install -y realmd sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit krb5-user jq curl gnupg2
# if we wait for cloud-init to finish, we can skip the packagekit install
# install_packages 20 realmd sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir krb5-user jq curl gnupg2
# if [ "$ID" = "ubuntu" ]; then
#     curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
#     AZ_REPO=$(lsb_release -cs)
#     echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list
#     apt update && apt install -y azure-cli
# else
#     curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/yum.repos.d/microsoft.gpg > /dev/null
#     echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1" | sudo tee /etc/yum.repos.d/azure-cli.repo
#     yum install -y azure-cli
# fi
# ---------------------------
# Set Hostname
# ---------------------------
# echo "[+] Setting hostname to ${NEW_HOSTNAME}"
# hostnamectl set-hostname "$NEW_HOSTNAME"

# ---------------------------
# Set DNS to AD Controller
# ---------------------------
# echo "[+] Configuring DNS to point to AD controller ($AD_DNS)"
# echo "nameserver $AD_DNS" > /etc/resolv.conf

# Optional: persist DNS through netplan (Ubuntu 24 uses Netplan)
# cat <<EOF > /etc/netplan/01-ad-dns.yaml
# network:
#   version: 2
#   ethernets:
#     eth0:
#       nameservers:
#         addresses: [$AD_DNS]
#       dhcp4: yes
# EOF

# netplan apply

# ---------------------------
# Login with Managed Identity
# ---------------------------
echo "[+] Authenticating with Azure using managed identity..."
/usr/bin/az login --identity > /dev/null

# ---------------------------
# Retrieve Secrets from Key Vault
# ---------------------------
echo "[+] Fetching credentials from Key Vault: $KEYVAULT_NAME"
#USERNAME=$(az keyvault secret show --vault-name "$KEYVAULT_NAME" --name "$SECRET_USERNAME" --query "value" -o tsv)
PASSWORD=$(az keyvault secret show --vault-name "$KEYVAULT_NAME" --name "$SECRET_PASSWORD" --query "value" -o tsv)

if [[ -z "$USERNAME" || -z "$PASSWORD" ]]; then
    echo "[-] Failed to retrieve credentials from Key Vault"
    exit 1
fi

echo "[+] Retrieved username: $USERNAME"

# ---------------------------
# Join the Domain
# ---------------------------
echo "[+] Attempting to join domain $DOMAIN"
echo "$PASSWORD" | realm join --user="$USERNAME" "$DOMAIN"

# ---------------------------
# Enable mkhomedir and restart SSSD
# ---------------------------
echo "[+] Enabling home directory creation on login..."
pam-auth-update --enable mkhomedir

# ---------------------------
# SSH Access Restriction via sshd_config
# ---------------------------
echo "[+] Restricting SSH access to groups: $SSH_ACCESS_GROUPS"
SSH_CONFIG="/etc/ssh/sshd_config"

# Backup first
cp "$SSH_CONFIG" "${SSH_CONFIG}.bak"

# Clean old AllowGroups entries
sed -i '/^AllowGroups/d' "$SSH_CONFIG"

# Add new AllowGroups line
echo "AllowGroups azureadmin admin sudo $SSH_ACCESS_GROUPS" >> "$SSH_CONFIG"

# Restart SSH
systemctl restart ssh

# ---------------------------
# Add Admin Groups to Sudo
# ---------------------------
echo "[+] Granting sudo access to admin groups: $ADMIN_ACCESS_GROUPS"
for GROUP in $ADMIN_ACCESS_GROUPS; do
    echo "%$GROUP ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${GROUP}"
    chmod 440 "/etc/sudoers.d/${GROUP}"
done

# ---------------------------
# Restart SSSD
# ---------------------------
echo "[+] Restarting SSSD..."
systemctl restart sssd

# ---------------------------
# Done
# ---------------------------
echo "[+] Domain join and access setup complete!"
realm list