module "microservicio" {
  source    = "../.."
  providers = { aws = aws }

  environment        = "production"
  cluster_name       = "prueba-devops-microservicio-production"
  node_instance_type = "t3.medium"
  node_disk_size_gib = 20
}
