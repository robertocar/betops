variable "project_id" {
  description = "ID del proyecto de GPC"
  type        = string
}

variable "region" {
  default     = "us-central1"
  description = "Región a utilizar de GCP"
  type        = string
}

variable "namespace" {
  description = "Namespace para identificar a los recursos del proyecto "
  type        = string
} 
