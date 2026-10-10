resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = var.cluster_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.10-eksbuild.3"
}

resource "aws_eks_pod_identity_association" "vpc_cni" {
  cluster_name         = var.cluster_name
  namespace            = "kube-system"
  service_account      = "aws-node"
  role_arn             = aws_iam_role.rol_vpc_cni.arn
  disable_session_tags = false

  depends_on = [
    aws_iam_role_policy_attachment.permisos_vpc_cni
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = var.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.22.4-eksbuild.3"
  resolve_conflicts_on_create = "OVERWRITE"

  # La asociación se prepara antes del CNI; no se usa service_account_role_arn de IRSA.
  depends_on = [
    aws_eks_pod_identity_association.vpc_cni
  ]
}
