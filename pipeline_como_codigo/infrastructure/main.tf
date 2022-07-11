#TFM_UNIR_CICD_PIPELINE_COMO_CODIGO

#DEFINICION DE SERVICIOS (ACCESIBLES A TRAVÉS DE APIS) A UTILIZAR
locals {
  services = [ 
    "sourcerepo.googleapis.com", #Cloud Source Repositories API
    "cloudbuild.googleapis.com", #Cloud Build API
    "iam.googleapis.com",        #Identity and Access Management (IAM) API
    "run.googleapis.com",        #Cloud Run API

  ]
}

#RECURSO "GOOGLE PROJECT SERVICE" UTILIZADO PARA LLAMAR AUTOMATICAMANETE A LAS APIS DESDE UN SOLO RECURSO
resource "google_project_service" "activacion_de_servicios" {
  for_each = toset(local.services) #llamada a una lista para iterar de manera no secuencial
  project  = var.project_id  #proyecto en ejecucion "betops"
  service  = each.key #clave de acceso actual
}

resource "google_sourcerepo_repository" "repo" {
  depends_on = [
    google_project_service.enabled_service["sourcerepo.googleapis.com"]
  ]

  name = "${var.namespace}-repo"
} 

locals { #A
  image = "gcr.io/${var.project_id}/${var.namespace}"
  steps = [
    {
      name = "gcr.io/cloud-builders/go"
      args = ["test"]
      env  = ["PROJECT_ROOT=${var.namespace}"]
    },
    {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", local.image, "."]
    },
    {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", local.image]
    },
    {
      name = "gcr.io/cloud-builders/gcloud"
      args = ["run", "deploy", google_cloud_run_service.service.name, "--image", local.image, "--region", var.region, "--platform", "managed", "-q"]
    }

  ]
}

resource "google_cloudbuild_trigger" "trigger" {
  depends_on = [
    google_project_service.enabled_service["cloudbuild.googleapis.com"]
  ]

  trigger_template {
    branch_name = "master"
    repo_name   = google_sourcerepo_repository.repo.name
  }

  build {
    dynamic "step" {
      for_each = local.steps
      content {
        name = step.value.name
        args = step.value.args
        env  = lookup(step.value, "env", null) #B
      }
    }
  }
}

data "google_project" "project" {}

resource "google_project_iam_member" "cloudbuild_roles" {
  depends_on = [google_cloudbuild_trigger.trigger]
  for_each   = toset(["roles/run.admin", "roles/iam.serviceAccountUser"]) #A
  project    = var.project_id
  role       = each.key
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
} 

resource "google_cloud_run_service" "service" {
  depends_on = [
    google_project_service.enabled_service["run.googleapis.com"]
  ]
  name     = var.namespace
  location = var.region

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello" #A
      }
    }
  }
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "policy" {
  location    = var.region
  project     = var.project_id
  service     = google_cloud_run_service.service.name
  policy_data = data.google_iam_policy.admin.policy_data
}

