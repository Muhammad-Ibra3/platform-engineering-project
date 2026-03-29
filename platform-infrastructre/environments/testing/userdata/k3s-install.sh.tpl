# ==============================================================================
# Install k3s and configure kubelet ECR credential provider
# ==============================================================================

# Read EC2 metadata securely using IMDSv2
TOKEN=$(curl -fsSL -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

PUBLIC_IP=$(curl -fsSL -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/public-ipv4 || true)

PRIVATE_IP=$(curl -fsSL -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

# Prefer the public IP when available so ServiceLB / ingress status can advertise
# a publicly reachable address. Fall back to the private IP if the instance has
# no public IPv4.
API_IP="${PUBLIC_IP:-${PRIVATE_IP}}"

mkdir -p /etc/rancher/k3s
mkdir -p /var/lib/rancher/credentialprovider/bin
mkdir -p /var/lib/rancher/credentialprovider

# Build the official AWS ECR kubelet credential provider binary.
# Keep this version on the same Kubernetes minor as the installed k3s version.

# Set Go environment for non-interactive shell
export GOPATH=/usr/local/go-work
export GOMODCACHE="${GOPATH}/pkg/mod"
export GOCACHE="${GOPATH}/cache"
mkdir -p "${GOMODCACHE}" "${GOCACHE}" "${GOPATH}/bin"

# Build and install ECR credential provider
GOBIN=/var/lib/rancher/credentialprovider/bin \
  go install "k8s.io/cloud-provider-aws/cmd/ecr-credential-provider@${ECR_PROVIDER_VERSION}"

chmod 0755 /var/lib/rancher/credentialprovider/bin/ecr-credential-provider

# Configure kubelet credential provider for ECR.
# ECR auth tokens are valid for 12 hours, so cache a little below that.
cat >/var/lib/rancher/credentialprovider/config.yaml <<'EOM'
apiVersion: kubelet.config.k8s.io/v1
kind: CredentialProviderConfig
providers:
  - name: ecr-credential-provider
    matchImages:
      - "*.dkr.ecr.*.amazonaws.com"
      - "*.dkr.ecr.*.amazonaws.com.cn"
    apiVersion: credentialprovider.kubelet.k8s.io/v1
    defaultCacheDuration: "11h"
EOM

chmod 0644 /var/lib/rancher/credentialprovider/config.yaml

# Write k3s config with kubelet args for the credential provider.
# node-ip stays private for in-cluster traffic.
# node-external-ip prefers the public IPv4 so Traefik / ServiceLB / ingress status
# can publish a reachable public address.
cat >/etc/rancher/k3s/config.yaml <<EOM
write-kubeconfig-mode: "0644"
node-ip: "${PRIVATE_IP}"
node-external-ip: "${API_IP}"
tls-san:
  - "${API_IP}"
kubelet-arg:
  - "image-credential-provider-bin-dir=/var/lib/rancher/credentialprovider/bin"
  - "image-credential-provider-config=/var/lib/rancher/credentialprovider/config.yaml"
EOM

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${K3S_VERSION}" sh -

systemctl enable k3s
systemctl restart k3s