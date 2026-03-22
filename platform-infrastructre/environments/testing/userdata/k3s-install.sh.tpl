# ==============================================================================
# Install k3s and prepare kubeconfig
# ==============================================================================

# Read EC2 metadata securely using IMDSv2
TOKEN=$(curl -fsSL -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

PUBLIC_IP=$(curl -fsSL -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/public-ipv4 || true)

PRIVATE_IP=$(curl -fsSL -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

API_IP="${PUBLIC_IP:-${PRIVATE_IP}}"

mkdir -p /etc/rancher/k3s

# Write k3s config with a TLS SAN matching the public IP if available
cat >/etc/rancher/k3s/config.yaml <<EOM
write-kubeconfig-mode: "0644"
tls-san:
  - "${API_IP}"
EOM

# Install pinned k3s version
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${K3S_VERSION}" sh -

systemctl enable k3s
systemctl restart k3s

retry systemctl is-active --quiet k3s

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

wait_for_kubectl

# Wait until at least one node appears
echo "Waiting for node to register..."
until /usr/local/bin/kubectl get nodes | grep -q " Ready\| NotReady"; do
  sleep 5
done

# Now wait until it's Ready
/usr/local/bin/kubectl wait --for=condition=Ready node --all --timeout=300s