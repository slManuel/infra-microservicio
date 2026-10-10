resource "aws_eks_access_entry" "administrador" {
  cluster_name  = aws_eks_cluster.cluster_microservicio.name
  principal_arn = var.administrator_principal_arn
  # Entrada general para una identidad IAM (usuario o rol), distinta de los tipos para nodos.
  # STANDARD no concede administración; los permisos provienen de la política asociada abajo.
  type = "STANDARD"
}

resource "aws_eks_access_policy_association" "administrador" {
  cluster_name  = aws_eks_access_entry.administrador.cluster_name
  principal_arn = aws_eks_access_entry.administrador.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
