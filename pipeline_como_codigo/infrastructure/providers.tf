#TFM_UNIR_CICD_PIPELINE_COMO_CODIGO
#Definición de Proveedor GOOGLE (definición implicita)
provider "google" {
  project = var.project_id
  region  = var.region
}
