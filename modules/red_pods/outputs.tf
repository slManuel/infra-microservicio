output "cluster_name_for_nodes" {
  description = "Nombre disponible tras preparar la asociación CNI; no espera salud de addons."
  value       = aws_eks_pod_identity_association.vpc_cni.cluster_name
}

output "pod_identity_agent_id" {
  description = "Agente Pod Identity creado."
  value       = aws_eks_addon.pod_identity_agent.id
}
