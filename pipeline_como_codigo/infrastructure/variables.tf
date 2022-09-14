#DEFINICIÓN DE VARIABLES PIPELINE CI/CD AS CODE
#ROBERTO CÁRDENAS

variable "project_id" {
  description = "ID del proyecto de GPC"
  type        = string
}
variable "region" {
  default     = "southamerica-east1"
  description = "Región a utilizar de GCP"
  type        = string
}
variable "namespace" {
  description = "Namespace para identificar y gestionar a los recursos del proyecto "
  type        = string
}


