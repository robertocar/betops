#DEFINICIÓN DE VERSIONES DE TERRAFORM & GOOGLE
#ROBERTO CÁRDENAS

terraform {
  required_version = ">= 0.15"
  required_providers {
      google = {
          source = "hashicorp/google"
          version = "~> 3.56"
      }
  }
}

