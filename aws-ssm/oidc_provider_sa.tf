data "aws_partition" "current_testing" {}

data "aws_caller_identity" "current_testing" {}

data "aws_eks_cluster" "cluster_testing" {
  name = var.cluster_name
}

locals {
  partition          = data.aws_partition.current_testing.id
  account_id         = data.aws_caller_identity.current_testing.account_id
  oidc_provider_arn  = replace(data.aws_eks_cluster.cluster_testing.identity[0].oidc[0].issuer, "https://", "")
  oidc_provider_name = "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.oidc_provider_arn}"
  eks_sa_namespace   = "testing"
  eks_sa_name        = "tester"
}

resource "aws_iam_role" "role" {
  name               = "new-sa-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        local.oidc_provider_arn,
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_name}:sub"
      values = [
        "system:serviceaccount:${local.eks_sa_namespace}:${local.eks_sa_name}"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_name}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

## aws iam list-open-id-connect-providers 