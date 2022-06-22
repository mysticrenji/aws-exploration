# Managing Secrets in EKS using AWS SSM
Important stuff in the process

- Create an OpenID Connect identity provider to be able to integrate IAM roles with Kubernetes ServiceAccounts
- Install Kubernetes Secrets Store CSI Driver
- Install AWS Secrets and Configuration Provider (ASCP)

## Prerequisites
You need to have the AWS Credentials exported in the environment Shell Session
```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_REGION=
```

## 1. Create EKS Cluster via Terraform
```
terraform init
terraform plan
terraform apply
```

## 2. Install Helm 3 and secrets store csi driver
```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install --set syncSecret.enabled=true --set enableSecretRotation=true csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system 
```
## 3. Install the secret store csi provider for AWS
```
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
```

## 4. Create manifest with SecretProviderClass
```
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: admin-aws-secrets
  namespace: default
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "/appdev/module1/username"
        objectType: "ssmparameter"
      - objectName: "/appdev/module1/password"
        objectType: "ssmparameter"
```

## 5. Apply the secrets to Deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-deployment
  namespace: default
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      serviceAccountName: eks-svc-account
      volumes:
      - name: secrets-store-inline
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "admin-aws-secrets"
      containers:
      - name: demo-deployment
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: secrets-store-inline
          mountPath: "/mnt/secrets-store"
          readOnly: true
```

# References

- https://blog.spikeseed.cloud/handling-aws-secrets-and-parameters-on-eks/