# Background
The kube-bench adapter periodically runs a CIS benchmark check using cron-job with a tool called kube-bench and produces a cluster-wide policy report based on the Policy Report Custom Resource Definition

# Steps for setting up Kyverno Policy Reporter, related CRDs and Kube-Bench Adapater via Helm Chart

## 1. Add policy reporter as  chart to helm repo
```
helm repo add policy-reporter https://kyverno.github.io/policy-reporter
helm repo update
```

## 2.Installation with Policy Reporter UI with  Kyverno Plugin disabled

```
helm install policy-reporter policy-reporter/policy-reporter --set kyvernoPlugin.enabled=false --set ui.enabled=true --set ui.plugins.kyverno=false -n default --create-namespace
kubectl port-forward service/policy-reporter-ui 8082:8080 -n policy-reporter
```

## 3.Installation of Policy Report CRDs - Mannual way

Add the PolicyReport CRDs to your cluster (v1alpha2):

```console
kubectl create -f https://github.com/kubernetes-sigs/wg-policy-prototypes/raw/master/policy-report/crd/v1alpha2/wgpolicyk8s.io_policyreports.yaml
```

Add the ClusterPolicyReport CRDs to your cluster (v1alpha2):

```console
kubectl create -f https://github.com/kubernetes-sigs/wg-policy-prototypes/raw/master/policy-report/crd/v1alpha2/wgpolicyk8s.io_clusterpolicyreports.yaml
```

## 4. Install Kube-bench adapter for Policy Reporter
This will install kube-bench adapater for Policy Reporter and run the kube-bench scan as cronjob

### 1. Add Helm Repository
```console
helm repo add nirmata https://nirmata.github.io/kyverno-charts/

```
### 2. Install kube-bench adapter from charts helm repo with desired parameters.
Note that EKS Cluster Master cannnot be checked using Kube-bench as control plane is abstracted ;). The check can be done for worker nodes using a simple cron job

```console
helm install kube-bench-adapter charts/kube-bench-adapter --set kubeBench.name="test-1" --set kubeBench.yaml="job.yaml" --set kubeBench.benchmark="cis-1.6" --set-cronjob.schedule="\"*/1 * * * *\""
```
### 3. Watch the jobs
```console
kubectl get jobs --watch
```
### 4. Check policyreports created through the custom resource
```console
kubectl get clusterpolicyreports
```

# References
1. https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report
2. https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report/kube-bench-adapter
3. https://github.com/kyverno/policy-reporter#readme
4. https://mritunjaysharma394.github.io/kube-bench-adapter-helm-chart/
5. https://artifacthub.io/packages/helm/kyverno-nirmata/kube-bench-adapter

