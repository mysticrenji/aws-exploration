data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_caller_identity" "current" {}

locals {
  k8s_service_account_name      = "eks-svc-account"
  k8s_service_account_namespace = "default"
  eks_oidc_issuer               = "${data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer}/"
}

resource "aws_iam_role" "eks_dev_role" {
  name               = "eks_dev_role"
  assume_role_policy = data.aws_iam_policy_document.eks_dev_assume_role.json
}

data "aws_iam_policy_document" "eks_dev_iam_policy_document" {
  statement {
    sid = "1"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    effect = "Allow"
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "eks_dev_iam_policy" {
  name   = "eks_dev_iam_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.eks_dev_iam_policy_document.json
}

resource "aws_iam_role_policy_attachment" "eks_dev_iam_policy_attachment" {
  role       = aws_iam_role.eks_dev_role.name
  policy_arn = aws_iam_policy.eks_dev_iam_policy.arn
}


data "aws_iam_policy_document" "eks_dev_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer}"
      ]
    }

    # Limit the scope so that only our desired service account can assume this role
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:sub"
      values = [
        "system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_openid_connect_provider" "eks-cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url             = local.eks_oidc_issuer
}

data "tls_certificate" "cluster" {
  url = local.eks_oidc_issuer
}

# Instance Profile for Karpenter - Start
data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
  role       = module.eks-cluster.worker_iam_role_name
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
}
resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = module.eks-cluster.worker_iam_role_name
}
# Instance Profile for Karpenter - end

resource "kubernetes_service_account" "eks_dev_svc" {
  metadata {
    name      = local.k8s_service_account_name
    namespace = local.k8s_service_account_namespace
    annotations = {
      # This annotation is needed to tell the service account which IAM role it
      # should assume
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_dev_role.arn
    }
  }
}

#
# Deploy Kubernetes Pod with the Service Account that can assume an AWS IAM role
#
resource "kubernetes_pod" "iam_role_test" {
  metadata {
    name      = "iam-role-test"
    namespace = local.k8s_service_account_namespace
  }

  spec {
    service_account_name = local.k8s_service_account_name
    container {
      name  = "iam-role-test"
      image = "amazon/aws-cli:latest"
      # Sleep so that the container stays alive
      # #continuous-sleeping
      command = ["/bin/bash", "-c", "--"]
      args    = ["while true; do sleep 5; done;"]
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks-cluster" {
  depends_on = [
    module.vpc
  ]
  source          = "terraform-aws-modules/eks/aws"
  version         = "<18"
  cluster_name    = var.cluster_name
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true

  worker_groups = [
    {
      instance_type = "t2.medium"
      asg_max_size  = 1
    }
  ]

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}

