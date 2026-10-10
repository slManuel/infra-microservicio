module "microservicio" {
  source    = "../.."
  providers = { aws = aws }

  environment        = "development"
  cluster_name       = "prueba-devops-microservicio-development"
  node_instance_type = "t3.medium"
  node_disk_size_gib = 20
}
