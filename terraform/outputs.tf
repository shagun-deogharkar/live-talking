output "cluster_name" {
  value = google_container_cluster.live_talking.name
}

output "gpu_node_pool" {
  value = google_container_node_pool.gpu_pool.name
}
