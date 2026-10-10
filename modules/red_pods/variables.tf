variable "cluster_name" {
  description = "Nombre del clúster."
  type        = string
  nullable    = false
}

variable "cluster_arn" {
  description = "ARN del clúster para confianza Pod Identity."
  type        = string
  nullable    = false
}
