resource "aws_iam_role" "rol_vpc_cni" {
  name = "${var.cluster_name}-vpc-cni"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
      Condition = {
        StringEquals = {
          "aws:RequestTag/eks-cluster-arn"            = var.cluster_arn
          "aws:RequestTag/kubernetes-namespace"       = "kube-system"
          "aws:RequestTag/kubernetes-service-account" = "aws-node"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "permisos_vpc_cni" {
  role       = aws_iam_role.rol_vpc_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
