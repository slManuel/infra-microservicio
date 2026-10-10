terraform {
  backend "s3" {
    bucket       = "tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis-production"
    key          = "microservicio/production/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
