provider "aws" {
  region = var.aws_region

  # Rechaza operaciones si las credenciales pertenecen a otra cuenta.
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Project     = "prueba-devops"
      Environment = "development"
      ManagedBy   = "terraform"
      Component   = "microservicio"
    }
  }
}
