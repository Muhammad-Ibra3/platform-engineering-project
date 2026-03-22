# ==============================================================================
# Clean up completed k3s addon helm-install jobs and leftover pods
# ==============================================================================

cleanup_k3s_helm_jobs() {
  echo "Cleaning up completed k3s helm-install jobs in kube-system..."

  local jobs
  jobs=$(/usr/local/bin/kubectl -n kube-system get jobs --no-headers 2>/dev/null | awk '/^helm-install-/ {print $1}' || true)

  if [ -n "${jobs}" ]; then
    echo "${jobs}" | xargs -r /usr/local/bin/kubectl -n kube-system delete job
  fi

  local pods
  pods=$(/usr/local/bin/kubectl -n kube-system get pods --no-headers 2>/dev/null | awk '/^helm-install-/ {print $1}' || true)

  if [ -n "${pods}" ]; then
    echo "${pods}" | xargs -r /usr/local/bin/kubectl -n kube-system delete pod --ignore-not-found=true
  fi
}

cleanup_k3s_helm_jobs