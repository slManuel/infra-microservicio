variable "jenkins_security_group_id" {
  description = "SG de nodos/control plane herramientas, leído de EKS."
  type        = string
}
resource "aws_vpc_security_group_ingress_rule" "api_desde_jenkins" {
  security_group_id            = aws_eks_cluster.cluster_microservicio.vpc_config[0].cluster_security_group_id
  referenced_security_group_id = var.jenkins_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "Jenkins en VPC compartida hacia API privada ${var.cluster_name}"
}
