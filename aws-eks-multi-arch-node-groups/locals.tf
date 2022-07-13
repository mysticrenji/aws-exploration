data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  oidc = trimprefix(data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://")
}


# Required for Windows Node Enablement in the Cluster

data "aws_eks_cluster" "eks-cluster" {
  name = aws_eks_cluster.eks-cluster.name
}

data "aws_eks_cluster_auth" "eks-cluster-auth" {
  name = aws_eks_cluster.eks-cluster.name
}


data "aws_ami" "win_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Core-EKS_Optimized-1.22-*"]
  }
}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = data.aws_eks_cluster.eks-cluster.id
      cluster = {
        certificate-authority-data = data.aws_eks_cluster.eks-cluster.certificate_authority[0].data
        server                     = data.aws_eks_cluster.eks-cluster.endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = data.aws_eks_cluster.eks-cluster.id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.eks-cluster-auth.token
      }
    }]
  })
}