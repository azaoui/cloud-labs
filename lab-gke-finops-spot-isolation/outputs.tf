output "cluster_name" {
  description = "GKE cluster name."
  value       = google_container_cluster.demo.name
}

output "get_credentials_command" {
  description = "Command to fetch kubeconfig credentials for the demo cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.demo.name} --zone ${google_container_cluster.demo.location} --project ${var.project_id}"
}

output "on_demand_node_pool_name" {
  description = "Name of the on-demand node pool."
  value       = google_container_node_pool.on_demand.name
}

output "spot_node_pool_name" {
  description = "Name of the spot node pool."
  value       = google_container_node_pool.spot.name
}