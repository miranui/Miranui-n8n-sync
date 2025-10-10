output "docker_app_id" {
  value       = clevercloud_docker.docker_instance.id
  description = "Clever Cloud application id for the docker instance"
}
