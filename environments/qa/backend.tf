terraform {
  backend "s3" {
    bucket       = "tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis-qa"
    key          = "microservicio/qa/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
