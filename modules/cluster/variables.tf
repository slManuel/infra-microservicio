variable "cluster_role_arn" {
  description = "Rol EKS, recibido tras asociar su política."
  type        = string
  nullable    = false
}

variable "private_subnet_ids" {
  description = "Dos subredes privadas de red compartida."
  type        = list(string)
  nullable    = false
}

variable "administrator_principal_arn" {
  description = "Identidad IAM administradora."
  type        = string
  nullable    = false
}
