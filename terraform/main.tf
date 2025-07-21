terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.45.2"
    }
  }
  required_version = ">= 1.5.0"
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = var.gcp_credentials
}

# ---------------------------
# GKE Cluster (no default node pool)
# ---------------------------
resource "google_container_cluster" "live_talking" {
  name     = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  # Cluster-wide node config - only used by default node pool if created
  node_config {
    machine_type = var.default_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

# ---------------------------
# Default CPU Node Pool
# ---------------------------
resource "google_container_node_pool" "default_pool" {
  name     = "default-pool"
  location = var.zone
  cluster  = google_container_cluster.live_talking.name

  node_config {
    machine_type = var.default_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  initial_node_count = var.default_node_count

  autoscaling {
    min_node_count = var.default_min_nodes
    max_node_count = var.default_max_nodes
  }
}

# ---------------------------
# GPU Node Pool
# ---------------------------
resource "google_container_node_pool" "gpu_pool" {
  name     = "gpu-pool"
  location = var.zone
  cluster  = google_container_cluster.live_talking.name

  node_config {
    machine_type = var.gpu_machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    guest_accelerator {
      type  = var.gpu_type  # e.g. "nvidia-tesla-t4"
      count = var.gpu_count # e.g. 1
    }

    taint {
      key    = "nvidia.com/gpu"
      value  = "present"
      effect = "NO_SCHEDULE"
    }
  }

  autoscaling {
    min_node_count = var.gpu_min_nodes
    max_node_count = var.gpu_max_nodes
  }

  initial_node_count = var.gpu_initial_nodes
}

# ---------------------------
# Install NVIDIA Device Plugin
# ---------------------------
resource "null_resource" "nvidia_plugin" {
  depends_on = [
    google_container_node_pool.gpu_pool
  ]

  provisioner "local-exec" {
    command = <<EOT
    gcloud container clusters get-credentials ${var.cluster_name} --zone=${var.zone} --project=${var.project_id}
    kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.5/nvidia-device-plugin.yml
    EOT
  }
}
