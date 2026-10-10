data "terraform_remote_state" "red_compartida" {
  backend = "s3"

  config = {
    bucket = "tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis"
    key    = "red-compartida/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_iam_user" "administrador_cluster" {
  user_name = "manuel-dev"
}

data "aws_eks_cluster" "herramientas" {
  name = "prueba-devops-jenkins-vault"
}
