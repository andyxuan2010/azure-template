#!/bin/bash
# Linux VM bootstrap summary
# This script is rendered by Terraform and passed to Azure as the VM custom_data cloud-init payload.
# It is the base operating system bootstrap for the linuxvm module and is intended to work best on
# Ubuntu and RHEL-family images, while degrading gracefully on other Linux images when possible.
#
# Main responsibilities:
# 1. Detect the guest OS and choose the supported package manager (apt-get, dnf, or yum).
# 2. Apply baseline Linux hardening and shell defaults, including SSH daemon settings, umask,
#    session timeout, and selected sysctl protections.
# 3. Prepare the admin account shell environment and authorized_keys layout used by the module.
# 4. Install common operational packages and tooling such as Terraform, Ansible, Git, GitHub CLI,
#    Azure CLI, Azure DevOps CLI, AzCopy, Bicep, PowerShell, .NET SDK/runtime, packaging/build tools,
#    Docker, Podman, AWS CLI, kubectl, helm, eksctl, oc, diagnostics, networking, monitoring,
#    and troubleshooting utilities.
# 5. Enable useful supporting services when present, such as time synchronization and audit logging.
# 6. Authenticate with Azure using the VM managed identity and retrieve the AD join password
#    from the shared Key Vault when domain join is expected.
# 7. Join the VM to Active Directory when the required domain join inputs and tools are available.
# 8. Grant guest OS access based on Terraform-provided groups:
#    - SSH access for user groups
#    - sudo access for admin groups
# 9. Keep distro-specific steps best-effort so unsupported commands do not cause immediate failure
#    on non-Ubuntu images.

LOG_DIR="/var/log/localization"
LOG_FILE="$LOG_DIR/init.log"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"
chmod 0600 "$LOG_FILE" || true

# Mirror output into a dedicated log while still letting cloud-init capture stdout/stderr.
exec > >(awk '{ cmd="date -u +%Y-%m-%dT%H:%M:%SZ"; cmd | getline ts; close(cmd); print "[" ts "] " $0; fflush(); }' | tee -a "$LOG_FILE") 2>&1

# Add timestamps to shell trace lines so executed commands are easier to correlate.
export PS4='+ $(date -u "+%Y-%m-%dT%H:%M:%SZ") '


. /etc/os-release
IS_UBUNTU=false
if [ "$ID" = "ubuntu" ]; then
    IS_UBUNTU=true
fi
UBUNTU_CODENAME="$${VERSION_CODENAME:-$${UBUNTU_CODENAME:-}}"
UBUNTU_VERSION_ID="$${VERSION_ID:-}"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if command_exists apt-get; then
    PKG_MANAGER="apt-get"
elif command_exists dnf; then
    PKG_MANAGER="dnf"
elif command_exists yum; then
    PKG_MANAGER="yum"
else
    PKG_MANAGER=""
fi

restart_ssh_service() {
    if command_exists systemctl; then
        if systemctl list-unit-files | grep -q '^ssh\.service'; then
            systemctl restart ssh || true
        elif systemctl list-unit-files | grep -q '^sshd\.service'; then
            systemctl restart sshd || true
        fi
    fi
}

enable_mkhomedir() {
    if command_exists pam-auth-update; then
        pam-auth-update --enable mkhomedir || true
    elif command_exists authselect; then
        authselect select sssd with-mkhomedir --force || true
    else
        echo "[!] No supported mkhomedir tool found; skipping automatic home directory enablement."
    fi
}

safe_add_alias() {
    local target_file="$1"
    local alias_line="$2"

    if [ -f "$target_file" ] && ! grep -Fqx "$alias_line" "$target_file" 2>/dev/null; then
        echo "$alias_line" >> "$target_file"
    fi
}

configure_sshd_option() {
    local key="$1"
    local value="$2"

    if grep -Eq "^[#[:space:]]*$${key}[[:space:]]+" /etc/ssh/sshd_config; then
        sed -i -E "s|^[#[:space:]]*$${key}[[:space:]].*|$${key} $${value}|" /etc/ssh/sshd_config
    else
        echo "$${key} $${value}" >> /etc/ssh/sshd_config
    fi
}

ensure_sysctl_setting() {
    local key="$1"
    local value="$2"
    local file="/etc/sysctl.d/99-linuxvm-hardening.conf"

    touch "$file"
    if grep -Eq "^[#[:space:]]*$${key}[[:space:]]*=" "$file"; then
        sed -i -E "s|^[#[:space:]]*$${key}[[:space:]]*=.*|$${key} = $${value}|" "$file"
    else
        echo "$${key} = $${value}" >> "$file"
    fi
}

enable_service_if_present() {
    local service_name="$1"

    if command_exists systemctl && systemctl list-unit-files | grep -q "^$${service_name}\\.service"; then
        systemctl enable "$service_name" || true
        systemctl start "$service_name" || true
    fi
}

configure_microsoft_apt_repos() {
    command_exists curl || return 0
    command_exists gpg || return 0
    command_exists tee || return 0
    command_exists dpkg || return 0

    if [ "$IS_UBUNTU" != "true" ]; then
        return 0
    fi

    if [ -z "$UBUNTU_CODENAME" ]; then
        echo "[!] Unable to determine Ubuntu codename; skipping Microsoft apt repo configuration."
        return 0
    fi

    if [ -z "$UBUNTU_VERSION_ID" ]; then
        echo "[!] Unable to determine Ubuntu version; skipping Microsoft apt repo configuration."
        return 0
    fi

    rm -f /etc/apt/trusted.gpg.d/microsoft.gpg
    rm -f /etc/apt/sources.list.d/azure-cli.list
    rm -f /etc/apt/sources.list.d/azure-cli.sources
    rm -f /etc/apt/sources.list.d/microsoft-prod.list
    rm -f /etc/apt/sources.list.d/microsoft-com-prod.list

    mkdir -p -m 755 /etc/apt/keyrings

    curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null || return 0
    chmod 644 /etc/apt/keyrings/microsoft.gpg || true

    cat >/etc/apt/sources.list.d/azure-cli.sources <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: $${UBUNTU_CODENAME}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/microsoft.gpg
EOF

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/$${UBUNTU_VERSION_ID}/prod $${UBUNTU_CODENAME} main" > /etc/apt/sources.list.d/microsoft-com-prod.list
}

install_terraform_cli() {
    local terraform_version
    local arch
    local zip_file
    local download_url

    command_exists curl || return 0
    command_exists unzip || return 0

    terraform_version=$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform 2>/dev/null | grep -Po '"current_version":"\K[^"]+' || true)
    if [ -z "$terraform_version" ]; then
        terraform_version="1.11.4"
    fi

    arch="$(uname -m)"
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) echo "[!] Unsupported architecture for Terraform CLI install: $arch"; return 0 ;;
    esac

    zip_file="/tmp/terraform_$${terraform_version}_linux_$${arch}.zip"
    download_url="https://releases.hashicorp.com/terraform/$${terraform_version}/terraform_$${terraform_version}_linux_$${arch}.zip"

    curl -fsSL "$download_url" -o "$zip_file" || return 0
    unzip -o -q "$zip_file" -d /tmp || return 0
    [ -f /tmp/terraform ] && install -o root -g root -m 0755 /tmp/terraform /usr/local/bin/terraform || true
    command_exists terraform && terraform version || true
}

install_azcopy_cli() {
    local arch
    local tar_file
    local download_url
    local extracted_dir

    command_exists curl || return 0
    command_exists tar || return 0

    arch="$(uname -m)"
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) echo "[!] Unsupported architecture for AzCopy install: $arch"; return 0 ;;
    esac

    tar_file="/tmp/azcopy.tar.gz"
    download_url="https://aka.ms/downloadazcopy-v10-linux"
    curl -fsSL "$download_url" -o "$tar_file" || return 0
    mkdir -p /tmp/azcopy-extract
    tar -xzf "$tar_file" -C /tmp/azcopy-extract || return 0
    extracted_dir=$(find /tmp/azcopy-extract -maxdepth 1 -type d -name "azcopy_linux_*" | head -n 1)
    [ -n "$extracted_dir" ] && [ -f "$extracted_dir/azcopy" ] && install -o root -g root -m 0755 "$extracted_dir/azcopy" /usr/local/bin/azcopy || true
    command_exists azcopy && azcopy --version || true
}

install_yq_cli() {
    local arch
    local download_url

    command_exists curl || return 0

    arch="$(uname -m)"
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) echo "[!] Unsupported architecture for yq install: $arch"; return 0 ;;
    esac

    download_url="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_$${arch}"
    curl -fsSL "$download_url" -o /usr/local/bin/yq || return 0
    chmod 0755 /usr/local/bin/yq || true
    command_exists yq && yq --version || true
}

install_kubectl_cli() {
    local arch
    local stable_version
    local download_url

    command_exists curl || return 0

    arch="$(uname -m)"
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) echo "[!] Unsupported architecture for kubectl install: $arch"; return 0 ;;
    esac

    stable_version=$(curl -L -s https://dl.k8s.io/release/stable.txt || true)
    if [ -z "$stable_version" ]; then
        echo "[!] Unable to determine latest kubectl version; skipping kubectl install."
        return 0
    fi

    download_url="https://dl.k8s.io/release/$${stable_version}/bin/linux/$${arch}/kubectl"
    curl -fsSL "$download_url" -o /tmp/kubectl || return 0
    install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl || true
    command_exists kubectl && kubectl version --client || true
}

install_arm_ttk() {
    local zip_file="/tmp/arm-ttk.zip"

    command_exists curl || return 0
    command_exists unzip || return 0

    mkdir -p /opt/arm-ttk
    curl -fsSL https://github.com/Azure/arm-ttk/archive/refs/heads/master.zip -o "$zip_file" || return 0
    unzip -o -q "$zip_file" -d /opt || return 0
    if [ -d /opt/arm-ttk-master ]; then
        rm -rf /opt/arm-ttk
        mv /opt/arm-ttk-master /opt/arm-ttk
    fi
    if command_exists pwsh && [ -f /opt/arm-ttk/arm-ttk/Test-AzTemplate.ps1 ]; then
        cat >/usr/local/bin/arm-ttk <<'EOF'
#!/bin/bash
pwsh -NoLogo -NoProfile -File /opt/arm-ttk/arm-ttk/Test-AzTemplate.ps1 "$@"
EOF
        chmod 0755 /usr/local/bin/arm-ttk || true
    fi
}

USERNAME="azureadmin"
mkdir -p /home/"$USERNAME"/.ssh /root/.ssh
touch ~/.bashrc /home/"$USERNAME"/.bashrc
echo 'export USERNAME=azureadmin' >> ~/.bashrc
echo 'export USERNAME=azureadmin' >> /home/azureadmin/.bashrc
[ -f ~/.bashrc ] && source ~/.bashrc || true

install_packages() {
    local max_attempts="$1"
    shift
    local package_names="$@"
    local attempt_num=1
    local success=false

    while [ "$success" = false ] && [ "$attempt_num" -le "$max_attempts" ]; do
        echo "Try to install for $package_names"
        if [ "$PKG_MANAGER" = "apt-get" ]; then
            DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install "$@" > /dev/null
        elif [ "$PKG_MANAGER" = "dnf" ]; then
            dnf -y install "$@" > /dev/null
        elif [ "$PKG_MANAGER" = "yum" ]; then
            yum -y install "$@" > /dev/null
        else
            echo "No supported package manager found. Skipping package install for: $package_names"
            return 0
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

install_packages_optional() {
    local max_attempts="$1"
    shift
    install_packages "$max_attempts" "$@" || true
}


# echo "Waiting for cloud-init to finish..."
# while ! cloud-init status | grep -q "done"; do
#   sleep 5
# done

wait_for_apt() {
    echo "Waiting for dpkg lock to be released..."
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
        echo "Another process is using apt/dpkg. Waiting..."
        sleep 5
    done
    echo "Lock released. Continuing..."
}


# basic setting, timezone, disable ssh password login
set -x
umask 027
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
cat >/etc/profile.d/99-linuxvm-hardening.sh <<'EOF'
umask 027
export TMOUT=900
readonly TMOUT
export HISTSIZE=5000
export HISTFILESIZE=10000
EOF

#add additional keepalive seconds to sshd
configure_sshd_option "ClientAliveInterval" "1200"
configure_sshd_option "ClientAliveCountMax" "3"
configure_sshd_option "PermitRootLogin" "no"
configure_sshd_option "X11Forwarding" "no"
configure_sshd_option "MaxAuthTries" "4"
configure_sshd_option "LoginGraceTime" "30"
#sed -i -E 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i -E 's/#?AuthenticationMethods publickey/AuthenticationMethods publickey,password/' /etc/ssh/sshd_config
#sed -i -E 's/#?PasswordAuthentication publickey/AuthenticationMethods publickey,password/' /etc/ssh/sshd_config
#echo "AuthenticationMethods publickey,password" >> /etc/ssh/sshd_config
PASSWORD_AUTH_FILES=$(grep -r PasswordAuthentication /etc/ssh -l 2>/dev/null || true)
if [ -n "$PASSWORD_AUTH_FILES" ]; then
    echo "$PASSWORD_AUTH_FILES" | xargs -r -n 1 sed -i 's/#\s*PasswordAuthentication\s.*$/PasswordAuthentication yes/; s/^PasswordAuthentication\s*no$/PasswordAuthentication yes/'
fi
restart_ssh_service

ensure_sysctl_setting "net.ipv4.conf.all.accept_redirects" "0"
ensure_sysctl_setting "net.ipv4.conf.default.accept_redirects" "0"
ensure_sysctl_setting "net.ipv4.conf.all.send_redirects" "0"
ensure_sysctl_setting "net.ipv4.conf.default.send_redirects" "0"
ensure_sysctl_setting "net.ipv4.conf.all.accept_source_route" "0"
ensure_sysctl_setting "net.ipv4.conf.default.accept_source_route" "0"
ensure_sysctl_setting "net.ipv4.tcp_syncookies" "1"
command_exists sysctl && sysctl --system >/dev/null 2>&1 || true

# install emachine key and vm keys
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIqfriZJbopqGHXo1gVfxo7LNF7rx+Yq1qSFpLeojDS4DWr/a8v2dpevDf95Xku/BGLZ16eRQFlW4/YFfhpPIy1sYVlaJQVOiALN8sk1R5OuGjLXy2e22SRVgH0LQehHCLwmszjuLhbmDO8qjNnzm0JIYHmv4+VkZ56LI8rTiPozHmKGxgKfhKhV1vh9NzdCnj7Nh/iQWAU82X5UzYU6J6t7Ape1bp4C74yPH3NOcVcV51qKZXiamfM2PfPnU11I+Wd7Ho8l1yvpUUZe0FdSBZtp7oWya+oPy5AXJlfuMCq5WjVUO9LCvpZMsJWQDhocMFuDRiNw4+0G/XnathEiRP root@emachine" >>/root/.ssh/authorized_keys
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjoftGI4Wgwc6YHGgbbUfAkMm2k4JQIkMXmlHrs24bnSa+CxNeC4eL7cFWZHgLxn6pBfqRCijsCbLpzUhlIJKMMxv2WB0TtHpezD9oUX1/9K7rC3RB4EcKmZ3vDWSsR4UBn9aVCZkQBnr+hfk39lj+Hk2qAMGloVFD0bM10j1Hhv5uMaT8lcClWK/TCcgKH8NQF3hZDqX8YADCYczvZ7B3hA+xpAZwOOZKChOv5Y2ABduD8KPcV6Uc1VLO6+xMlkDZc0MB6HkYlGZSbeMkstgPo+275SKHWVJ7B2nWMvOAyOtjU5OqHwYoNrsCX1TP380DUhQqqAqjzqDP8C0z76Gj root@vm" >>/root/.ssh/authorized_keys
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIqfriZJbopqGHXo1gVfxo7LNF7rx+Yq1qSFpLeojDS4DWr/a8v2dpevDf95Xku/BGLZ16eRQFlW4/YFfhpPIy1sYVlaJQVOiALN8sk1R5OuGjLXy2e22SRVgH0LQehHCLwmszjuLhbmDO8qjNnzm0JIYHmv4+VkZ56LI8rTiPozHmKGxgKfhKhV1vh9NzdCnj7Nh/iQWAU82X5UzYU6J6t7Ape1bp4C74yPH3NOcVcV51qKZXiamfM2PfPnU11I+Wd7Ho8l1yvpUUZe0FdSBZtp7oWya+oPy5AXJlfuMCq5WjVUO9LCvpZMsJWQDhocMFuDRiNw4+0G/XnathEiRP root@emachine" >>/home/$USERNAME/.ssh/authorized_keys
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjoftGI4Wgwc6YHGgbbUfAkMm2k4JQIkMXmlHrs24bnSa+CxNeC4eL7cFWZHgLxn6pBfqRCijsCbLpzUhlIJKMMxv2WB0TtHpezD9oUX1/9K7rC3RB4EcKmZ3vDWSsR4UBn9aVCZkQBnr+hfk39lj+Hk2qAMGloVFD0bM10j1Hhv5uMaT8lcClWK/TCcgKH8NQF3hZDqX8YADCYczvZ7B3hA+xpAZwOOZKChOv5Y2ABduD8KPcV6Uc1VLO6+xMlkDZc0MB6HkYlGZSbeMkstgPo+275SKHWVJ7B2nWMvOAyOtjU5OqHwYoNrsCX1TP380DUhQqqAqjzqDP8C0z76Gj root@vm" >>/home/$USERNAME/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCk50jdzWtnq/jYzy6D33iMSvYJxoOKcfBKhs4IU5XnrhP9zDQuP1MwulfaqWA+uWpjwMi5D02I7aFttvGCd4tLcbLg57uYYIdgQzM+dcBuP4tckf9emjF1HxQhpu++uyUOYibBv+x+CmZwU6OW0xPmcXqc1oBl9vOGnGh/18I4qwpxzTuQRlexrzlVQTUrsPHAEu4nKjtpeGNQ71HevCKaLfgsVqyxCHvoWhLDw1wZ+S5j4D+HM5C5VrWG3IrU9ku2btRpPIszUM89XfXb/nzL48IPGl8JISifZ2zCjNTD+cFf/RHmLJ2A5zLxBfISfIwM5ZB4vYC3qV9Tmfmk9B0KM7bNRbFNtf3C+EL+3FSRY61Ezp8vQ9pAWtuf5XN948myJWd0FfAfseUdDxcjm7lUYVV+IstVf9IqAefD0+tZ0ok6uj950W1Z4RRAujd5JDIQ/cuhNeg9sd9P+xxgJUNs4qkQy1YQPPn75W13kiK5xteyyGeMUt6vK0NA6x+M1lU=" >>/root/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCk50jdzWtnq/jYzy6D33iMSvYJxoOKcfBKhs4IU5XnrhP9zDQuP1MwulfaqWA+uWpjwMi5D02I7aFttvGCd4tLcbLg57uYYIdgQzM+dcBuP4tckf9emjF1HxQhpu++uyUOYibBv+x+CmZwU6OW0xPmcXqc1oBl9vOGnGh/18I4qwpxzTuQRlexrzlVQTUrsPHAEu4nKjtpeGNQ71HevCKaLfgsVqyxCHvoWhLDw1wZ+S5j4D+HM5C5VrWG3IrU9ku2btRpPIszUM89XfXb/nzL48IPGl8JISifZ2zCjNTD+cFf/RHmLJ2A5zLxBfISfIwM5ZB4vYC3qV9Tmfmk9B0KM7bNRbFNtf3C+EL+3FSRY61Ezp8vQ9pAWtuf5XN948myJWd0FfAfseUdDxcjm7lUYVV+IstVf9IqAefD0+tZ0ok6uj950W1Z4RRAujd5JDIQ/cuhNeg9sd9P+xxgJUNs4qkQy1YQPPn75W13kiK5xteyyGeMUt6vK0NA6x+M1lU=" >>/home/$USERNAME/.ssh/authorized_keys


if [ "$PKG_MANAGER" = "apt-get" ]; then
    configure_microsoft_apt_repos
    wait_for_apt
    apt-get update -y > /dev/null
    #wait_for_apt
    install_packages 20 apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common wget rsync vim tmux dnsutils less
    install_packages 20 libssl-dev net-tools pkg-config unzip zip cargo stunnel4 docker.io
    install_packages 20 nmap unzip zip nfs-common tcpdump bash-completion
    install_packages 20 python3 python3-pip python3-venv git jq wget
    install_packages_optional 20 git-lfs ripgrep netcat-openbsd traceroute iputils-ping whois mtr htop btop iotop iftop sysstat lsof ncdu strace tree httpie iproute2 screen ansible podman fail2ban lynis build-essential rpm dpkg-dev alien debhelper
    install_packages_optional 20 gh
    install_packages_optional 20 chrony auditd
    #install_packages 5 htop iotop iftop nmon net-tools sysstat lsof ncdu strace tree
    #install_packages 5 nmap traceroute tcpdump iputils-ping whois mtr
    # install packages for AD domain join
    install_packages 20 realmd sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir krb5-user
elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
    install_packages 20 ca-certificates curl gnupg2 wget rsync vim-enhanced tmux bind-utils less which procps-ng
    install_packages 20 net-tools pkg-config unzip zip docker
    install_packages 20 nmap unzip zip nfs-utils tcpdump cronie bash-completion
    install_packages 20 python3 python3-pip git jq wget
    # software-properties-common and apt-transport-https are Debian/Ubuntu packages, so keep the
    # RHEL-family path to the closest applicable package set instead of forcing unavailable names.
    install_packages_optional 20 git-lfs ripgrep iperf3 nc traceroute iputils whois mtr htop btop iotop iftop sysstat lsof ncdu strace tree httpie iproute screen ansible-core podman fail2ban lynis gcc gcc-c++ make rpm-build createrepo_c
    install_packages_optional 20 powershell
    install_packages_optional 20 gh
    install_packages_optional 20 chrony audit
    install_packages_optional 20 realmd sssd adcli oddjob oddjob-mkhomedir samba-common-tools krb5-workstation
    install_packages_optional 20 nmon
else
    echo "[!] No supported package manager detected. Continuing with best-effort bootstrap."
fi

enable_service_if_present "chrony"
enable_service_if_present "chronyd"
enable_service_if_present "auditd"

#ln -sf /usr/bin/python3.11 /usr/bin/python3
#ln -sf /usr/bin/python3.11 /usr/bin/python

export PATH=$PATH:/usr/local/go/bin
if command_exists systemctl; then
    systemctl enable docker || true
    systemctl start docker || true
fi
id "$USERNAME" >/dev/null 2>&1 && usermod -aG docker "$USERNAME" || true

# #install latest docker-compose v2.27.1
if command_exists curl; then
    LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")' || true)
    if [ -n "$LATEST_VERSION" ]; then
        curl -L "https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /tmp/docker-compose || true
        if [ -f /tmp/docker-compose ]; then
            cd /tmp/ || true
            install -o root -g root -m 0755 docker-compose /usr/local/bin/docker-compose || true
            command_exists docker-compose && docker-compose version || true
        fi
    fi
fi
safe_add_alias ~/.bashrc "alias d=docker"
safe_add_alias /home/$USERNAME/.bashrc "alias d=docker"
safe_add_alias ~/.bashrc "alias dc=docker-compose"
safe_add_alias /home/$USERNAME/.bashrc "alias dc=docker-compose"


safe_add_alias /home/$USERNAME/.bashrc "complete -C '/usr/bin/aws_completer' aws"
safe_add_alias ~/.bashrc "complete -C '/usr/bin/aws_completer' aws"
safe_add_alias ~/.bashrc "alias a=aws"
safe_add_alias /home/$USERNAME/.bashrc "alias a=aws"

[ -f /etc/profile.d/bash_completion.sh ] && source /etc/profile.d/bash_completion.sh > /dev/null || true
if [ -f /etc/bashrc ]; then
    grep -Fqx "export PROMPT_COMMAND='history -a'" /etc/bashrc || echo "export PROMPT_COMMAND='history -a'" >> /etc/bashrc
elif [ -f /etc/bash.bashrc ]; then
    grep -Fqx "export PROMPT_COMMAND='history -a'" /etc/bash.bashrc || echo "export PROMPT_COMMAND='history -a'" >> /etc/bash.bashrc
fi


# # install az cli, it would work for both ubuntu and amazon linux or redhat
# sometimes this doesn't work due to the download restriction
#curl -sL https://aka.ms/InstallAzureCLIDeb | bash
# the second option to install azure cli

if [ "$PKG_MANAGER" = "apt-get" ]; then
    configure_microsoft_apt_repos
    wait_for_apt
    #apt-get update -y > /dev/null
    DEBIAN_FRONTEND=noninteractive apt-get install -y azure-cli || true
    install_packages_optional 5 powershell dotnet-sdk-8.0 dotnet-runtime-8.0 aspnetcore-runtime-8.0
elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
    # 3. Download and install the Microsoft signing key
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/pki/rpm-gpg/microsoft.gpg || true
    # 4. Add the Azure CLI software repository
    cat >/etc/yum.repos.d/azure-cli.repo <<'EOF'
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/microsoft.gpg
EOF
    if [ "$PKG_MANAGER" = "dnf" ]; then
        dnf install -y azure-cli || true
    else
        yum install -y azure-cli || true
    fi
    install_packages_optional 5 powershell dotnet-sdk-8.0 dotnet-runtime-8.0 aspnetcore-runtime-8.0
fi

if command_exists az; then
    az extension add --name azure-devops --upgrade --only-show-errors || true
    az extension list --query "[].name" -o tsv 2>/dev/null | grep -qx "azure-devops" && echo "[+] Azure DevOps CLI extension installed" || true
    az bicep install || true
    az bicep version || true
fi

install_terraform_cli
install_azcopy_cli
install_yq_cli
install_arm_ttk


# install awscli
if command_exists curl && command_exists unzip; then
    AWSCLI_ARCH="x86_64"
    case "$(uname -m)" in
        x86_64) AWSCLI_ARCH="x86_64" ;;
        aarch64|arm64) AWSCLI_ARCH="aarch64" ;;
    esac
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$${AWSCLI_ARCH}.zip" -o awscliv2.zip || true
    if [ -f awscliv2.zip ]; then
        unzip -q awscliv2.zip || true
        [ -x ./aws/install ] && ./aws/install || true
        if ! command_exists aws; then
            [ -x /usr/local/aws-cli/v2/current/bin/aws ] && ln -sf /usr/local/aws-cli/v2/current/bin/aws /usr/local/bin/aws || true
            [ -x /usr/local/aws-cli/v2/current/bin/aws_completer ] && ln -sf /usr/local/aws-cli/v2/current/bin/aws_completer /usr/local/bin/aws_completer || true
        fi
        command_exists aws && aws --version || true
    fi
fi

# Ensure SSM installed\
# in cases where it is not available / removed
# ssm_running=$(ps -ef | grep ['a']mazon-ssm-agent | wc -l)
# if [[ $ssm_running != "0" ]]; then
#     echo -e "amazon-ssm-agent already running"
# else
#     if [[ -r "/tmp/ssm_agent_install" ]]; then
#         :
#     else mkdir -p /tmp/ssm_agent_install; fi
#     curl https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm -o /tmp/ssm_agent_install/amazon-ssm-agent.rpm
#     rpm -Uvh /tmp/ssm_agent_install/amazon-ssm-agent.rpm
#     ssm_running=$(ps -ef | grep ['a']mazon-ssm-agent | wc -l)
#     # Amazon Linux 2
#     systemctl=$(command -v systemctl | wc -l)
#     if [[ $systemctl != "0" ]]; then
#         systemctl enable amazon-ssm-agent
#         if [[ $ssm_running == "0" ]]; then
#             systemctl start amazon-ssm-agent
#         fi
#     fi
# fi

#### install kubectl & helm for the k8s
# install kubectl from the upstream release binary so it works across distro families
cd /tmp/
install_kubectl_cli
safe_add_alias ~/.bashrc "source <(kubectl completion bash)"
safe_add_alias /home/$USERNAME/.bashrc "source <(kubectl completion bash)"
safe_add_alias ~/.bashrc "alias k=kubectl"
safe_add_alias /home/$USERNAME/.bashrc "alias k=kubectl"

# second option to install kubectl in ubuntu 24 without download the package.
# if [ "$ID" = "ubuntu" ]; then
#     #curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#     curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

#     # 3. Add the Kubernetes apt repository
#     #echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-stable main" | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
#     echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

#     # 4. Update package list and install kubectl
#     apt update && apt install -y kubectl
# else
#     # install kubectl for amazon linux 2
#     # have not tested yet.
#     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#     install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#     kubectl version --client
# fi


# # install eksctl for aws eks
cd /tmp/
if command_exists curl; then
    EKSCTL_ARCH="amd64"
    case "$(uname -m)" in
        x86_64) EKSCTL_ARCH="amd64" ;;
        aarch64|arm64) EKSCTL_ARCH="arm64" ;;
    esac
    curl --silent -L "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_$${EKSCTL_ARCH}.tar.gz" -o /tmp/eksctl.tar.gz || true
    if [ -f /tmp/eksctl.tar.gz ]; then
        tar xvf /tmp/eksctl.tar.gz || true
        [ -f /tmp/eksctl ] && install -o root -g root -m 0755 /tmp/eksctl /usr/local/bin/eksctl || true
    fi
fi
safe_add_alias ~/.bashrc "alias e=eksctl"
safe_add_alias /home/$USERNAME/.bashrc "alias e=eksctl"
# cd /tmp/
# curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.22.0/2021-07-05/bin/linux/amd64/aws-iam-authenticator
# install -o root -g root -m 0755 aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
#chmod +x ./aws-iam-authenticator
#sudo mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

### install helm tool for k8s
if command_exists curl; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || true
fi
command_exists helm && helm version || true
if command_exists helm && [ -d /etc/bash_completion.d ]; then
    helm completion bash > /etc/bash_completion.d/helm || true
fi

if command_exists helm; then
    helm repo add stable https://charts.helm.sh/stable || true
    helm repo update || true
fi
safe_add_alias ~/.bashrc "alias h=helm"
safe_add_alias /home/$USERNAME/.bashrc "alias h=helm"


# install aro oc cli + kubectl
cd /tmp/
if command_exists curl; then
    if [ "$ID" = "ubuntu" ]; then
        curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux-4.18.6.tar.gz -o /tmp/openshift-client-linux.tar.gz || true
    else
        curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux-amd64-rhel9.tar.gz -o /tmp/openshift-client-linux.tar.gz || true
    fi
fi
if [ -f /tmp/openshift-client-linux.tar.gz ]; then
    tar -xvf /tmp/openshift-client-linux.tar.gz || true
    [ -f /tmp/oc ] && install -o root -g root -m 0755 /tmp/oc /usr/local/bin/oc || true
    [ -f /tmp/kubectl ] && install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl || true
fi
safe_add_alias ~/.bashrc "alias o=oc"
safe_add_alias /home/$USERNAME/.bashrc "alias o=oc"
safe_add_alias ~/.bashrc "alias k=kubectl"
safe_add_alias /home/$USERNAME/.bashrc "alias k=kubectl"

#### join AD if it's needed

#DOMAIN="2join.us"
#KEYVAULT_NAME="kv-ccoe-cc-nonprod"
#ADJOIN_USERNAME=""
#SECRET_PASSWORD="domain-join-password"

if [[ -z "${DOMAIN}" || -z "${ADJOIN_USERNAME}" || -z "${SECRET_PASSWORD}" ]]; then
    echo "[+] Domain join disabled; skipping Active Directory join."
else
    echo "[+] Authenticating with Azure using managed identity for domain join..."
    if command_exists az; then
        az login --identity > /dev/null || true
    else
        echo "[!] Azure CLI is not available; skipping Key Vault-based AD join."
    fi

    ADJOIN_PASSWORD=""
    if command_exists az; then
        ADJOIN_PASSWORD=$(az keyvault secret show --vault-name "${KEYVAULT_NAME}" --name "${SECRET_PASSWORD}" --query "value" -o tsv 2>/dev/null || true)
    fi

    if [[ -z "$ADJOIN_PASSWORD" ]] || ! command_exists realm; then
        echo "[-] Failed to retrieve credentials from Key Vault"
        echo "[-] Failed to join the domain=${DOMAIN}"
        echo "[-] Please check the Key Vault ${KEYVAULT_NAME} and try again"
        echo "[-] ADJOIN_USERNAME=${ADJOIN_USERNAME}"
        echo "[-] ADJOIN_PASSWORD=$ADJOIN_PASSWORD"
    else
        echo "[+] Attempting to join domain ${DOMAIN}"
        echo "$ADJOIN_PASSWORD" | realm join --user="${ADJOIN_USERNAME}" "${DOMAIN}" || true
        echo "[+] Enabling home directory creation on login..."
        enable_mkhomedir
        # Add Admin Groups to Sudo
        echo "[+] Granting sudo access to admin groups: ${ADMIN_ACCESS_GROUPS}"
        for GROUP in ${ADMIN_ACCESS_GROUPS}; do
            echo "%$GROUP ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$GROUP"
            chmod 440 "/etc/sudoers.d/$GROUP"
        done

        echo "[+] Restarting SSSD..."
        command_exists systemctl && systemctl restart sssd || true

        echo "[+] Domain join and access setup complete!"
        realm list || true
    fi
fi
#### join AD if it's needed

chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh /home/"$USERNAME"/.bashrc 2>/dev/null || true
chmod 700 /home/"$USERNAME"/.ssh /root/.ssh
chmod 600 /root/.ssh/authorized_keys /home/"$USERNAME"/.ssh/authorized_keys 2>/dev/null || true


#leave the apt-get update at later stage like untuntu.sh to save time
# if [ "$PKG_MANAGER" = "apt-get" ]; then
#     apt-get update -y
#     #DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade -y
# elif [ "$PKG_MANAGER" = "dnf" ]; then
#     dnf -y update > /dev/null
# elif [ "$PKG_MANAGER" = "yum" ]; then
#     yum -y update > /dev/null
# fi

#command_exists reboot && reboot || true
