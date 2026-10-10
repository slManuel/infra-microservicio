module "microservicio" {
  source    = "../.."
  providers = { aws = aws }

  environment        = "qa"
  cluster_name       = "prueba-devops-microservicio-qa"
  node_instance_type = "t3.medium"
  node_disk_size_gib = 20
}
