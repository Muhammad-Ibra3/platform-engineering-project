# ==============================================================================
# Install Helm CLI, deploy Argo CD, wait for readiness, then apply bootstrap app
# ==============================================================================

# Install Helm CLI for operational use on the instance
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Create argocd namespace idempotently
/usr/local/bin/kubectl create namespace argocd --dry-run=client -o yaml | /usr/local/bin/kubectl apply -f -

# Install pinned Argo CD version
retry /usr/local/bin/kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/v2.14.11/manifests/install.yaml

# Wait for CRDs to be fully registered
/usr/local/bin/kubectl wait --for=condition=Established crd/applications.argoproj.io --timeout=300s
/usr/local/bin/kubectl wait --for=condition=Established crd/appprojects.argoproj.io --timeout=300s
/usr/local/bin/kubectl wait --for=condition=Established crd/applicationsets.argoproj.io --timeout=300s

# Wait for key Argo CD workloads
/usr/local/bin/kubectl rollout status deployment/argocd-server -n argocd --timeout=600s
/usr/local/bin/kubectl rollout status deployment/argocd-repo-server -n argocd --timeout=600s
/usr/local/bin/kubectl rollout status deployment/argocd-applicationset-controller -n argocd --timeout=600s
/usr/local/bin/kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=600s
/usr/local/bin/kubectl rollout status deployment/argocd-dex-server -n argocd --timeout=600s || true
/usr/local/bin/kubectl rollout status deployment/argocd-redis -n argocd --timeout=600s || true

# Checking for created Argo CD pods
echo "Waiting for Argo CD pods to be created..."

# Wait until at least one pod exists
for i in {1..60}; do
  if /usr/local/bin/kubectl get pods -n argocd --no-headers 2>/dev/null | grep -q .; then
    break
  fi
  sleep 5
done

echo "Waiting for Argo CD pods to be Ready..."

/usr/local/bin/kubectl wait \
  --for=condition=Ready pod \
  -n argocd \
  --all \
  --timeout=600s

# Wait until the API resources are actually visible before bootstrapping
until /usr/local/bin/kubectl api-resources | grep -q '^applicationsets[[:space:]]'; do
  echo "Waiting for Argo CD API resources to register..."
  sleep 5
done

# Apply your GitOps bootstrap manifest
retry /usr/local/bin/kubectl apply -f \
  https://raw.githubusercontent.com/Muhammad-Ibra3/platform-engineering-project/main/platform-gitops/argo/argo-init-dev.yaml