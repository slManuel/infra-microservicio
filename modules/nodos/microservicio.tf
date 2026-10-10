resource "aws_launch_template" "microservicio" {
  name_prefix = "prueba-devops-microservicio-"

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }
}

resource "aws_eks_node_group" "microservicio" {
  cluster_name    = var.cluster_name
  node_group_name = "microservicio"
  node_role_arn   = var.node_role_arn

  subnet_ids = [
    var.private_subnet_ids_by_az["us-east-1a"],
  ]

  version         = var.kubernetes_version
  ami_type        = "AL2023_x86_64_STANDARD"
  release_version = "1.36.4-20261003"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  labels = {
    workload = "microservicio"
  }

  launch_template {
    id      = aws_launch_template.microservicio.id
    version = aws_launch_template.microservicio.latest_version
  }

}
