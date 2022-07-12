The repo has been forked from https://github.com/erozedguy/Terraform-EKS-Cluster-with-Node-Group.

- Added custom node group with arm64 architecture

## Update kubeconfig for eks cluster
```
aws eks --region us-west-2 update-kubeconfig --name eks-cluster
```