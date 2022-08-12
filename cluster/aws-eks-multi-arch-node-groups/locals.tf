data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "eks-cluster" {
  name = aws_eks_cluster.eks-cluster.name
}
data "aws_partition" "current" {}

locals {
  partition             = data.aws_partition.current.id
  account_id            = data.aws_caller_identity.current.account_id
  oidc = trimprefix(data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://")
  oidc_provider_name    = trimprefix(data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://")
  oidc_provider_arn     = "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.oidc_provider_name}"
}