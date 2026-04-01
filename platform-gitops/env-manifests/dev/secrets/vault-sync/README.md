# Vault bootstrap for External Secrets

This directory defines:

- `ClusterSecretStore` named `vault-backend`
- `ExternalSecret` resources that recreate existing Kubernetes secrets from Vault values

## 1) Preferred: configure auto-unseal (AWS KMS)

Vault values already include an AWS KMS seal stanza and expect this Kubernetes secret in namespace `secrets`:

```sh
kubectl -n secrets create secret generic vault-kms-creds \
  --from-literal=AWS_ACCESS_KEY_ID='<AWS_ACCESS_KEY_ID>' \
  --from-literal=AWS_SECRET_ACCESS_KEY='<AWS_SECRET_ACCESS_KEY>'
```

Also replace the placeholder `kms_key_id` in:

- `platform-helm/envs/dev/platform/secrets/vault/values.yaml`

With auto-unseal enabled, Vault still needs **one-time init**, but no manual unseal on restarts.

## 2) Initialize Vault (first time only)

```sh
kubectl -n secrets exec -it vault-0 -- vault operator init
```

Store unseal keys and root token in a secure password manager (not in Git).

## 3) Enable Kubernetes auth and policy for ESO

```sh
export VAULT_ADDR="http://127.0.0.1:8200"
kubectl -n secrets exec -it vault-0 -- sh

# Inside vault pod:
vault login <ROOT_TOKEN>
vault auth enable kubernetes

vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"

cat <<'EOF' > /tmp/eso-policy.hcl
path "secret/data/dev/*" {
  capabilities = ["read", "list"]
}
EOF

vault policy write eso-sync /tmp/eso-policy.hcl

vault write auth/kubernetes/role/eso-sync \
  bound_service_account_names="external-secrets" \
  bound_service_account_namespaces="secrets" \
  policies="eso-sync" \
  ttl="1h"
```

## 4) Write secret values into Vault (KV v2)

```sh
vault secrets enable -path=secret kv-v2 || true

vault kv put secret/dev/database/postgresql-auth \
  postgres-password='postgres' \
  password='postgres'

vault kv put secret/dev/microservices/writer-db-secret \
  POSTGRES_PASSWORD='postgres'

vault kv put secret/dev/database/mongodb-auth \
  mongodb-root-password='admin'

vault kv put secret/dev/microservices/mongo-uri-secret \
  MONGO_URI='mongodb://admin:admin@mongodb.database.svc.cluster.local:27017/products?authSource=admin'

vault kv put secret/dev/observability/grafana-admin \
  admin-user='admin' \
  admin-password='admin'

vault kv put secret/dev/database/redis-auth \
  redis-password='StrongPassword123!'

vault kv put secret/dev/identity/keycloak-auth \
  admin-password='StrongAdminPassword123!'

vault kv put secret/dev/identity/keycloak-postgresql-auth \
  postgres-password='StrongPostgresPassword123!' \
  password='StrongAppUserPassword123!'
```

## 5) Validate sync and rotation

```sh
kubectl -n secrets get pods
kubectl -n secrets get externalsecret
kubectl -n database get secret postgresql-auth mongodb-auth redis-auth
kubectl -n dev-microservices get secret writer-db-secret mongo-uri-secret
kubectl -n observability get secret grafana-admin
kubectl -n identity get secret keycloak-auth keycloak-postgresql-auth
```

Rotation test example:

```sh
kubectl -n secrets exec -it vault-0 -- sh -lc \
  "vault kv put secret/dev/database/redis-auth redis-password='NewStrongPassword456!'"

kubectl -n database get secret redis-auth -o jsonpath='{.data.redis-password}' | base64 -d && echo
```

For applications consuming secrets through environment variables, restart workloads after credential rotation to pick up new values.

## 6) Retire manual secret workflow

Remove the manual `kubectl create secret ...` runbook once ESO sync is validated in all namespaces.
