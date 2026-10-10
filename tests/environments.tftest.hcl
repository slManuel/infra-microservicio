# Solo planes simulados: no credenciales ni llamadas a AWS/S3.
mock_provider "aws" {
  override_during = plan

  mock_data "aws_iam_user" {
    defaults = {
      arn = "arn:aws:iam::022907376152:user/manuel-dev"
    }
  }

  mock_data "aws_eks_cluster" {
    defaults = {
      vpc_config = [{ cluster_security_group_id = "sg-0123456789abcdef0" }]
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::022907376152:role/mock-eks"
    }
  }

  mock_resource "aws_eks_cluster" {
    defaults = {
      arn                   = "arn:aws:eks:us-east-1:022907376152:cluster/mock"
      certificate_authority = [{ data = "bW9jay1jYQ==" }]
      vpc_config            = { cluster_security_group_id = "sg-0123456789abcdef1" }
    }
  }
}

override_data {
  target = module.microservicio.data.terraform_remote_state.red_compartida
  values = {
    outputs = {
      private_subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
      private_subnet_ids_by_az = {
        "us-east-1a" = "subnet-0123456789abcdef0"
        "us-east-1b" = "subnet-0123456789abcdef1"
      }
    }
  }
}

variables {
  aws_account_id = "022907376152"
}

run "development" {
  command = plan
  module {
    source = "./environments/development"
  }
  assert {
    condition     = output.cluster_name == "prueba-devops-microservicio-development"
    error_message = "Development debe crear su propio clúster."
  }
  assert {
    condition     = output.node_group_name == "prueba-devops-microservicio-development-nodos"
    error_message = "El node group debe pertenecer a development."
  }
}

run "qa" {
  command = plan
  module {
    source = "./environments/qa"
  }
  assert {
    condition     = output.cluster_name == "prueba-devops-microservicio-qa" && output.cluster_name != run.development.cluster_name
    error_message = "QA debe crear un clúster distinto a development."
  }
  assert {
    condition     = output.node_group_name == "prueba-devops-microservicio-qa-nodos"
    error_message = "El node group debe pertenecer a qa."
  }
}

run "production" {
  command = plan
  module {
    source = "./environments/production"
  }
  assert {
    condition     = output.cluster_name == "prueba-devops-microservicio-production" && output.cluster_name != run.development.cluster_name && output.cluster_name != run.qa.cluster_name
    error_message = "Production debe crear un tercer clúster independiente."
  }
  assert {
    condition     = output.node_group_name == "prueba-devops-microservicio-production-nodos"
    error_message = "El node group debe pertenecer a production."
  }
}
