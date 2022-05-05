# aws-eks-secret-management

- Create an OpenID Connect identity provider to be able to integrate IAM roles with Kubernetes ServiceAccounts
- Install Kubernetes Secrets Store CSI Driver
- Install AWS Secrets and Configuration Provider (ASCP)

```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install --set syncSecret.enabled=true --set enableSecretRotation=true csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system 

```