variable "environment" {
  description = "Entorno que posee estos recursos; no comparte estado con otros entornos."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["development", "qa", "production"], var.environment)
    error_message = "El entorno debe ser development, qa o production."
  }
}

variable "cluster_name" {
  description = "Nombre exclusivo del clúster y prefijo de sus roles y plantillas."
  type        = string
  nullable    = false

  validation {
    condition     = var.cluster_name == "prueba-devops-microservicio-${var.environment}"
    error_message = "El nombre debe coincidir con prueba-devops-microservicio-<entorno>."
  }
}

variable "node_instance_type" {
  description = "Tipo de nodo fijado para este laboratorio."
  type        = string
  nullable    = false

  validation {
    condition     = var.node_instance_type == "t3.medium"
    error_message = "El alcance autorizado mantiene t3.medium."
  }
}

variable "node_disk_size_gib" {
  description = "Disco gp3 cifrado del nodo, en GiB."
  type        = number
  nullable    = false

  validation {
    condition     = var.node_disk_size_gib == 20
    error_message = "El alcance autorizado mantiene 20 GiB por nodo."
  }
}
