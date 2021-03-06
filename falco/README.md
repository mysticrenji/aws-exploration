# Falco on EKS
Falco, a cloud native security project developed initially by Sysdig makes it possible for real time monitoring and alerting based on pre-defined and custom rules. It acts as an intelligent security camera which can monitor files, process, networking events happening inside every single pod inside the cluster and alert if a behaviour steps outside specified policy.

## Falco Rules
Falco is all based on rules. Falco already has several rules implemented by default, and these rules are defined inside the file(/etc/falco/falco_rules.yaml). Once it detects the event, it sends out the appropriate message..Example rules could be:

1. Installation of packages, libraries inside any container
2. Creation, deletion, rename and modification of files and folders inside the container after it starts running
3. Execution of binaries like bash, ssh, docker binary, debian binaries, vpn client, mail binaries
4. Unusual outbound traffic
5. Any ssh connection to/from container
6. Change of container files from host machine
7.  Detect an attempt to start a pod with a container image outside of a list of allowed images.
8. Detect an attempt to start a pod with a privileged container
9. Attempt to attach/exec to a pod
10. Creation of new namespace etc.

We can define our own set of rule which is very specific for our application. Falco alerts with a real time message if any of the rules is violated.

## Prerequisites for Cluster Setup
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

## 2. Falco Installation Procedure
Falco can be installed as helm chart </br>
Note  - But unfortunately, AWS EKS is a managed Kubernetes service, and it only can send audit logs to CloudWatch. It means there is no direct way for Falco to inspect the EKS audit events.
```
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm install falco --set falco.jsonOutput=true  --set auditLog.enabled=true falcosecurity/falco
```
## 3. Export Falco reports to Policy reporter
```
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

// Install CRD for policy reporter 
kubectl create -f https://github.com/kubernetes-sigs/wg-policy-prototypes/raw/master/policy-report/crd/v1alpha2/wgpolicyk8s.io_clusterpolicyreports.yaml
kubectl create -f https://github.com/kubernetes-sigs/wg-policy-prototypes/raw/master/policy-report/crd/v1alpha2/wgpolicyk8s.io_policyreports.yaml

// Install falco, falcosidekick exporter enabled
 helm install falco falcosecurity/falco \
 --set falcosidekick.enabled=true \
 --set falcosidekick.policyreport.enabled=true  \
 --set falcosidekick.policyreport.kubeconfig=~/.kube/config \
 --set falcosidekick.policyreport.failthreshold=3 \
 --set falcosidekick.policyreport.maxevents=10 \
 --set falcosidekick.webui.enabled=true

```

## Add policy reporter as  chart to helm repo
```
helm repo add policy-reporter https://kyverno.github.io/policy-reporter
helm repo update
```

## Installation with Policy Reporter UI with  Kyverno Plugin disabled

```
helm install policy-reporter policy-reporter/policy-reporter --set kyvernoPlugin.enabled=true --set ui.enabled=true --set ui.plugins.kyverno=true
kubectl port-forward service/policy-reporter-ui 8082:8080 -n policy-reporter
```

## References
1. https://falco.org/docs/getting-started/installation/
2. https://github.com/falcosecurity/plugins
3. https://falco.org/blog/choosing-a-driver/
4. https://github.com/sysdiglabs/ekscloudwatch
5. https://faun.pub/analyze-aws-eks-audit-logs-with-falco-95202167f2e
6. https://sotoiwa.hatenablog.com/entry/2021/03/09/141019
7. https://github.com/falcosecurity/falcosidekick
8. https://github.com/kubernetes-sigs/wg-policy-prototypes/tree/master/policy-report/falco-adapter
