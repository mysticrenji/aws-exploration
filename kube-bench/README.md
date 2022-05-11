## Add policy reporter as  chart to helm repo
```
helm repo add policy-reporter https://kyverno.github.io/policy-reporter
helm repo update
```

## Installation with Policy Reporter UI with  Kyverno Plugin disabled

```
helm install policy-reporter policy-reporter/policy-reporter --set kyvernoPlugin.enabled=false --set ui.enabled=true --set ui.plugins.kyverno=false -n policy-reporter --create-namespace
kubectl port-forward service/policy-reporter-ui 8082:8080 -n policy-reporter
```

## Installation of Policy Report CRDs - Mannual way

Add the PolicyReport CRDs to your cluster (v1alpha2):

```console
kubectl create -f https://github.com/kubernetes-sigs/wg-policy-prototypes/raw/master/policy-report/crd/v1alpha2/wgpolicyk8s.io_policyreports.yaml
```

Add the ClusterPolicyReport CRDs to your cluster (v1alpha2):

```console
kubectl create -f https://github.com/kubernetes-sigs/wg-policy-prototypes/raw/master/policy-report/crd/v1alpha2/wgpolicyk8s.io_clusterpolicyreports.yaml
```
Create a sample policy report resource:

```console
kubectl create -f https://github.com/kubernetes-sigs/wg-policy-prototypes/raw/master/policy-report/samples/sample-cis-k8s.yaml
```

View policy report resources:

```console
kubectl get policyreports
```

## Adding Kube-bench check to Policy reporter UI
Note that EKS Cluster Master cannnot be checked using Kube-bench as control plane is abstracted ;). The check can be done for worker nodes using a simple cron job
```
kubectl create -f kube-bench/eks-job.yaml
```

# References
 1. https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report
2. https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report/kube-bench-adapter
3. https://github.com/kyverno/policy-reporter#readme

