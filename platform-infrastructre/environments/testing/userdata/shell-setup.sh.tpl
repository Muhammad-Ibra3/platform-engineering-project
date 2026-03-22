# ==============================================================================
# Configure kubectl for the ubuntu user and add convenience aliases/functions
# ==============================================================================

install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config
chmod 600 /home/ubuntu/.kube/config

# Put shell helpers in profile.d so they are available in new login shells
cat >/etc/profile.d/kube-env.sh <<'EOM'
export KUBECONFIG=/home/ubuntu/.kube/config
alias k='kubectl'

# Change current namespace in the active kubectl context
kn() {
  kubectl config set-context --current --namespace="$1"
}

# Switch kubectl context
alias kx='kubectl config use-context'
EOM

chmod 0644 /etc/profile.d/kube-env.sh

if ! grep -q 'source /etc/profile.d/kube-env.sh' /home/ubuntu/.bashrc; then
  echo 'source /etc/profile.d/kube-env.sh' >> /home/ubuntu/.bashrc
fi

chown ubuntu:ubuntu /home/ubuntu/.bashrc