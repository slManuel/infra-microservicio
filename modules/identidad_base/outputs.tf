output "cluster_role_arn" {
  description = "Rol del clúster con política asociada."
  value       = aws_iam_role.rol_cluster_eks.arn
  depends_on  = [aws_iam_role_policy_attachment.permisos_cluster_eks]
}

output "node_role_arn" {
  description = "Rol de nodos con ambas políticas asociadas."
  value       = aws_iam_role.rol_nodos_eks.arn
  depends_on  = [aws_iam_role_policy_attachment.permisos_nodos_eks, aws_iam_role_policy_attachment.descarga_imagenes_nodos]
}
