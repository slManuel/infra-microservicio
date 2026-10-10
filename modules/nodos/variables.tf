variable "cluster_name" {
  description = "Clúster recibido tras crear la asociación Pod Identity CNI."
  type        = string
  nullable    = false
}

variable "kubernetes_version" {
  description = "Versión Kubernetes del clúster."
  type        = string
  nullable    = false
}

variable "node_role_arn" {
  description = "Rol de nodos recibido tras asociar políticas."
  type        = string
  nullable    = false
}

variable "private_subnet_ids_by_az" {
  description = "Subred privada por AZ."
  type        = map(string)
  nullable    = false
}
