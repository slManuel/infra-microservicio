module "iam_roles" {
  source       = "./modules/iam_roles"
  cluster_name = var.cluster_name
  providers    = { aws = aws }
}

module "cluster" {
  source                      = "./modules/cluster"
  cluster_name                = var.cluster_name
  providers                   = { aws = aws }
  cluster_role_arn            = module.iam_roles.cluster_role_arn
  private_subnet_ids          = data.terraform_remote_state.red_compartida.outputs.private_subnet_ids
  administrator_principal_arn = data.aws_iam_user.administrador_cluster.arn
  jenkins_security_group_id   = data.aws_eks_cluster.herramientas.vpc_config[0].cluster_security_group_id
}

module "red_pods" {
  source       = "./modules/red_pods"
  providers    = { aws = aws }
  cluster_name = module.cluster.cluster_name
  cluster_arn  = module.cluster.cluster_arn
}

module "nodos" {
  source                   = "./modules/nodos"
  instance_type            = var.node_instance_type
  disk_size_gib            = var.node_disk_size_gib
  providers                = { aws = aws }
  cluster_name             = module.red_pods.cluster_name_for_nodes
  kubernetes_version       = module.cluster.kubernetes_version
  node_role_arn            = module.iam_roles.node_role_arn
  private_subnet_ids_by_az = data.terraform_remote_state.red_compartida.outputs.private_subnet_ids_by_az
}
