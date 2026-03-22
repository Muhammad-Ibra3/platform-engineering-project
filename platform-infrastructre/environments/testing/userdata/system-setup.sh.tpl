# ==============================================================================
# OS package installation and kernel/network preparation for Kubernetes
# ==============================================================================

retry apt-get update -y
retry apt-get install -y \
  curl \
  ca-certificates \
  jq \
  git \
  unzip \
  bash-completion

# Disable swap because Kubernetes requires it
swapoff -a || true
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab || true

# Load required kernel modules
modprobe overlay || true
modprobe br_netfilter || true

cat >/etc/modules-load.d/k3s.conf <<'EOM'
overlay
br_netfilter
EOM

# Configure sysctl values required for container networking
cat >/etc/sysctl.d/99-kubernetes.conf <<'EOM'
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOM

sysctl --system