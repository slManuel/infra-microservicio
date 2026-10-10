output "cluster_name" {
  description = "Nombre del clúster."
  value       = aws_eks_cluster.cluster_microservicio.name
}

output "cluster_arn" {
  description = "ARN del clúster para confianza Pod Identity."
  value       = aws_eks_cluster.cluster_microservicio.arn
}

output "kubernetes_version" {
  description = "Versión Kubernetes."
  value       = aws_eks_cluster.cluster_microservicio.version
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster_microservicio.endpoint
}
output "cluster_ca_data" {
  value = aws_eks_cluster.cluster_microservicio.certificate_authority[0].data
}
