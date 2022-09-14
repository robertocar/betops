#TFM_UNIR_CICD_PIPELINE_COMO_CODIGO
#ROBERTO CÁRDENAS V.
#DEFINICION DE SERVICIOS (ACCESIBLES A TRAVÉS DE APIS) A UTILIZAR

locals {
  services = [ #Servicios de Google Cloud Plataform Utilizados 
    "sourcerepo.googleapis.com", #($) Cloud Source Repositories API: acceso a repositorios de código fuente
    "cloudbuild.googleapis.com", #($) Cloud Build API : continua contrucción pruebas y desppliegue
    "iam.googleapis.com",        #Identity and Access Management (IAM) API : administración de identificación y control de acceso a GCP
    "run.googleapis.com",        #Cloud Run API : agilidad para desplegar aplicaciones en contenedores en ambientes serverless

  ]
}

###################HABILITACIÓN DE APIS###################
#RECURSO "PROJECT SERVICE" UTILIZADO PARA LLAMAR AUTOMATICAMANETE A LAS APIS DESDE UN SOLO RECURSO

resource "google_project_service" "enabled_service" {
  for_each = toset(local.services) #llamada a una lista para iterar de manera no secuencial
  project  = var.project_id  #proyecto en ejecucion "betops"
  service  = each.key #clave de acceso actual
}

 
#RECURSO "SOURCE REPO REPOSITORY"
#CREACIÓN DE REPOSITORIO  
#> ETAPA 1 CI/CD: CREACIÓN DE REPO (COMMIT)
resource "google_sourcerepo_repository" "repo" {
  depends_on = [ google_project_service.enabled_service["sourcerepo.googleapis.com"] ]
  name = "${var.namespace}-repo"#devops-repo
} 

#RECURSO "CLOUD BUILD TRIGGER" 
#SE HABILITAN UNA VEZ QUE SE VERIFIQUE UN CAMBIO EN EL REPOSITORIO
#> ETAPA 2 -3 CI/CD: PRUEBAS Y CONSTRUCCIÓN
#> ETAPA 4 CI/CD: RELEASE

# PASOS REQUERIDOS PARA CLOUD BUILD y  EL USO DE  BLOQUES DINÁMICOS
locals { 
  image = "gcr.io/${var.project_id}/${var.namespace}"
  steps = [
    {
      name = "gcr.io/cloud-builders/go"
      #["1. TEST"]
      args = ["test"]
      env  = ["PROJECT_ROOT=${var.namespace}"]
    },
    {
      name = "gcr.io/cloud-builders/docker"
      #["2. CONSTRUCCIÓN"]
      args = ["build", "-t", local.image, "."]
    },
    {
      name = "gcr.io/cloud-builders/docker"
      #["3. RELEASE/LANZAMIENTO/PRESENTACIÓN"]
      args = ["push", local.image]
    },
    {
      name = "gcr.io/cloud-builders/gcloud"
      #["4. DESPLIEGUE"]
      args = ["run", "deploy", google_cloud_run_service.service.name, "--image", local.image, "--region", var.region, "--platform", "managed", "-q"]
    }
  ]
}

resource "google_cloudbuild_trigger" "trigger" {
  depends_on = [ google_project_service.enabled_service["cloudbuild.googleapis.com"] ]

  trigger_template {
    branch_name = "master"
    repo_name   = google_sourcerepo_repository.repo.name ##Detección de cambio en repositorio
  }

  build {
    dynamic "step" {
      for_each = local.steps
      content {
        name = step.value.name
        args = step.value.args
        env  = lookup(step.value, "env", null) #requerido para los pasos que no cuentan con variables de entorno "env"
      }
    }
  }
}




#RECURSO "PROJECT IAM MEMBER" 
#REQUERIDA PARA ASIGNAR ROLES Y QUE GOOGLE CLOUD BUILD PUEDA IMPLEMENTAR SERVICIOS SOBRE GOOGLE CLOUD RUN
data "google_project" "project" {}
resource "google_project_iam_member" "cloudbuild_roles" {
  depends_on = [google_cloudbuild_trigger.trigger]
  for_each   = toset(["roles/run.admin", "roles/iam.serviceAccountUser"]) #A
  project    = var.project_id
  role       = each.key
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
} 


#RECURSO "CLOUD RUN SERVICE": Para ejecutar el contenedor sin servidor (una vez que se haya contruido con cloud build)
resource "google_cloud_run_service" "service" {
  depends_on = [ google_project_service.enabled_service["run.googleapis.com"] ]
  name     = var.namespace
  location = var.region

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello" #IMagen Demo:colocada para que en el despliegue de terraform no de error
      }
    }
  }
}

#EXPONER LA IMAGEN A INTERNET: HABILITACIÓN DE USUARIO NO AUTENTICADOS
data "google_iam_policy" "admin" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

#RECURSO "CLOUD RUN SERVICE IAM POLICY"
resource "google_cloud_run_service_iam_policy" "policy" {
  location    = var.region
  project     = var.project_id
  service     = google_cloud_run_service.service.name
  policy_data = data.google_iam_policy.admin.policy_data
}

