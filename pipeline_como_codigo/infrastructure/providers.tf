#DEFINICIÓN DE GCP COMO PROVEEDOR
#(definición implicita)
#ROBERTO CÁRDENAS

provider "google" {
  project = var.project_id
  region  = var.region
}

