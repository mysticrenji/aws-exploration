The repo has been forked from https://github.com/erozedguy/Terraform-EKS-Cluster-with-Node-Group.

- Added custom node group with arm64 architecture

## Update kubeconfig for eks cluster
```
aws eks --region eu-central-1 update-kubeconfig --name eks-cluster
```

## eksctl windows node provisioning
```
https://eksctl.io/usage/windows-worker-nodes/
```