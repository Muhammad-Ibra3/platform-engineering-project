# ==============================================================================
# Helper functions used across the bootstrap process
# ==============================================================================

retry() {
  local n=1
  local max=10
  local delay=15

  until "$@"; do
    if [ "$n" -ge "$max" ]; then
      echo "Command failed after ${n} attempts: $*"
      return 1
    fi

    n=$((n + 1))
    sleep "${delay}"
  done
}

wait_for_kubectl() {
  local n=1
  local max=60

  until /usr/local/bin/kubectl get nodes >/dev/null 2>&1; do
    if [ "$n" -ge "$max" ]; then
      echo "kubectl never became ready"
      return 1
    fi

    n=$((n + 1))
    sleep 5
  done
}