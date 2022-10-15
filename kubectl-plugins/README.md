## Install Krew plugin for Kubernetes
```
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

```

## Install Kubepug for checking cluster for deprecations
```
kubectl krew install deprecations

#Usage
kubepug --k8s-version=v1.18.6 # Will verify the current context against v1.18.6 swagger.json

```

## Install net-forward for port-forwarding the services/nodes inside the cluster to local

```
kubectl krew install net-forward

#Usage
kubectl net-forward -i 169.254.169.254 -p 3389 -l 3389
```