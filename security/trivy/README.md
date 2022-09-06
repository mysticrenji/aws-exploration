# Install Trivy as Kubernetes Operator
```
helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update
helm install trivy-operator aqua/trivy-operator \
   --namespace trivy-system \
   --create-namespace \
   --set="trivy.ignoreUnfixed=true" \
   --version 0.0.3
```
## Options
```
Inspect created VulnerabilityReports by:

    kubectl get vulnerabilityreports --all-namespaces -o wide

Inspect created ConfigAuditReports by:

    kubectl get configauditreports --all-namespaces -o wide

Inspect created CISKubeBenchReports by:

    kubectl get ciskubebenchreports -o wide

Inspect the work log of trivy-operator by:

    kubectl logs -n trivy-system deployment/trivy-operator
```