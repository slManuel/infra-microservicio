resource "aws_eks_cluster" "cluster_microservicio" {
  name     = "prueba-devops-microservicio"
  role_arn = var.cluster_role_arn
  version  = "1.36"

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

}
