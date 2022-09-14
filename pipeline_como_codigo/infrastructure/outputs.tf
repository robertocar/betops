#TFM_UNIR_CICD_PIPELINE_COMO_CODIGO

output "urls" {
  value = {
    repo = google_sourcerepo_repository.repo.url
    app  = google_cloud_run_service.service.status[0].url
  }
}


